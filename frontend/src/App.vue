<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import { API_BASE_URL, apiRequest } from './api'

type BootstrapPhase = {
  key: string
  name: string
  status: string
  summary: string
}

type BootstrapModule = {
  code: string
  name: string
  priority: string
  owner: string
}

type BootstrapPayload = {
  project: string
  currentPhase: string
  nextStep: string
  docsPath: string
  phases: BootstrapPhase[]
  modules: BootstrapModule[]
}

type RoleView = {
  id: number
  code: string
  name: string
}

type CurrentUserPayload = {
  userId: number
  username: string
  displayName: string
  orgId: number | null
  orgName: string | null
  roles: RoleView[]
  expiresAt: string
}

type LoginResponse = {
  tokenType: string
  accessToken: string
  expiresAt: string
  user: CurrentUserPayload
}

type DictItem = {
  id: number
  itemCode: string
  itemName: string
  itemValue: string
  sortNo: number
}

type MenuNode = {
  id: number
  parentId: number | null
  menuCode: string
  menuName: string
  routePath: string | null
  iconName: string | null
  sortNo: number
  children: MenuNode[]
}

type OrgNode = {
  id: number
  parentId: number | null
  orgCode: string
  orgName: string
  orgType: string
  regionCode: string | null
  sortNo: number
  children: OrgNode[]
}

type OrgTreePayload = {
  currentOrgId: number | null
  nodes: OrgNode[]
}

type RelicItem = {
  id: number
  objectCode: string
  objectName: string
  sourceType: string
  categoryCode: string
  surveyStatus: string
  checkStatus: string
  addressText: string
  orgName: string | null
}

const fallbackBootstrap: BootstrapPayload = {
  project: 'FS Rebuild Console',
  currentPhase: '基础平台',
  nextStep: '组织 / 菜单 / 对象列表骨架',
  docsPath: 'G:/fourSurvey/FS-doc-bundle',
  phases: [
    { key: '01', name: '基础平台', status: 'IN_PROGRESS', summary: '登录、权限、菜单、组织与基础字典' },
    { key: '02', name: '核心建模', status: 'IN_PROGRESS', summary: '普查对象、接收批次、底账与核查任务' },
    { key: '03', name: '业务闭环', status: 'PENDING', summary: '数据初始化、接收数据、采集与核查' },
    { key: '04', name: '增强能力', status: 'PENDING', summary: '地图工作台、统计导出与报送' },
    { key: '05', name: '迁移试点', status: 'PENDING', summary: '旧库迁移、试点验收与切换' },
  ],
  modules: [
    { code: 'auth', name: '登录与权限', priority: 'P0', owner: 'backend' },
    { code: 'dict', name: '基础字典', priority: 'P0', owner: 'backend' },
    { code: 'menu', name: '导航菜单', priority: 'P0', owner: 'backend' },
    { code: 'org', name: '组织树', priority: 'P0', owner: 'backend' },
    { code: 'relic', name: '普查对象列表', priority: 'P0', owner: 'backend/frontend' },
    { code: 'check', name: '质量核查', priority: 'P1', owner: 'backend/frontend' },
    { code: 'map', name: '地图工作台', priority: 'P1', owner: 'map' },
  ],
}

const loginForm = reactive({
  username: 'admin',
  password: 'Admin@123456',
})

const bootstrap = ref<BootstrapPayload>(fallbackBootstrap)
const surveyStatusItems = ref<DictItem[]>([])
const surveySourceItems = ref<DictItem[]>([])
const currentUser = ref<CurrentUserPayload | null>(null)
const menus = ref<MenuNode[]>([])
const orgTree = ref<OrgTreePayload>({ currentOrgId: null, nodes: [] })
const relicItems = ref<RelicItem[]>([])
const relicKeyword = ref('')
const connectionState = ref<'connecting' | 'online' | 'offline'>('connecting')
const loginError = ref('')
const pageError = ref('')
const loginLoading = ref(false)
const dashboardLoading = ref(false)

const isAuthenticated = computed(() => currentUser.value !== null)
const totalMenuCount = computed(() => countMenus(menus.value))

function countMenus(nodes: MenuNode[]): number {
  return nodes.reduce((sum, node) => sum + 1 + countMenus(node.children), 0)
}

function phaseLabel(status: string) {
  if (status === 'IN_PROGRESS') {
    return '进行中'
  }
  if (status === 'PENDING') {
    return '待开始'
  }
  return status
}

function formatSource(sourceType: string) {
  return surveySourceItems.value.find((item) => item.itemCode === sourceType)?.itemName ?? sourceType
}

function formatStatus(status: string) {
  return surveyStatusItems.value.find((item) => item.itemCode === status)?.itemName ?? status
}

function checkStatusLabel(value: string) {
  if (value === 'PENDING') return '待核查'
  if (value === 'IN_REVIEW') return '核查中'
  if (value === 'PASSED') return '已通过'
  if (value === 'REJECTED') return '已退回'
  return value
}

async function loadBootstrap() {
  try {
    bootstrap.value = await apiRequest<BootstrapPayload>('/api/system/bootstrap', {
      method: 'GET',
      authenticated: false,
    })
    connectionState.value = 'online'
  } catch {
    bootstrap.value = fallbackBootstrap
    connectionState.value = 'offline'
  }
}

async function loadCurrentUser() {
  currentUser.value = await apiRequest<CurrentUserPayload>('/api/auth/me', {
    method: 'GET',
  })
}

async function loadDicts() {
  const [statusItems, sourceItems] = await Promise.all([
    apiRequest<DictItem[]>('/api/dicts/survey_status/items', { method: 'GET' }),
    apiRequest<DictItem[]>('/api/dicts/survey_source/items', { method: 'GET' }),
  ])
  surveyStatusItems.value = statusItems
  surveySourceItems.value = sourceItems
}

async function loadMenus() {
  menus.value = await apiRequest<MenuNode[]>('/api/menus/current', { method: 'GET' })
}

async function loadOrgTree() {
  orgTree.value = await apiRequest<OrgTreePayload>('/api/orgs/tree', { method: 'GET' })
}

async function loadRelics() {
  const keyword = relicKeyword.value.trim()
  const query = keyword ? `?keyword=${encodeURIComponent(keyword)}` : ''
  relicItems.value = await apiRequest<RelicItem[]>(`/api/relic-objects${query}`, { method: 'GET' })
}

async function loadDashboardData() {
  dashboardLoading.value = true
  pageError.value = ''
  try {
    await Promise.all([loadCurrentUser(), loadDicts(), loadMenus(), loadOrgTree(), loadRelics()])
    connectionState.value = 'online'
  } catch (error) {
    pageError.value =
      error instanceof Error ? error.message : '工作台加载失败'
    throw error
  } finally {
    dashboardLoading.value = false
  }
}

async function restoreSession() {
  const token = localStorage.getItem('four-survey-token')
  if (!token) {
    return
  }

  try {
    await loadDashboardData()
  } catch {
    localStorage.removeItem('four-survey-token')
    currentUser.value = null
    menus.value = []
    orgTree.value = { currentOrgId: null, nodes: [] }
    relicItems.value = []
  }
}

async function submitLogin() {
  loginLoading.value = true
  loginError.value = ''

  try {
    const result = await apiRequest<LoginResponse>('/api/auth/login', {
      method: 'POST',
      authenticated: false,
      body: JSON.stringify({
        username: loginForm.username,
        password: loginForm.password,
      }),
    })

    localStorage.setItem('four-survey-token', result.accessToken)
    currentUser.value = result.user
    await Promise.all([loadDicts(), loadMenus(), loadOrgTree(), loadRelics()])
    connectionState.value = 'online'
  } catch (error) {
    loginError.value =
      error instanceof Error ? error.message : '登录失败，请检查后端服务或账号数据'
  } finally {
    loginLoading.value = false
  }
}

function logout() {
  localStorage.removeItem('four-survey-token')
  currentUser.value = null
  menus.value = []
  orgTree.value = { currentOrgId: null, nodes: [] }
  relicItems.value = []
  surveyStatusItems.value = []
  surveySourceItems.value = []
}

onMounted(async () => {
  await loadBootstrap()
  await restoreSession()
})
</script>

<template>
  <div class="app-shell">
    <template v-if="isAuthenticated">
      <aside class="sidebar">
        <div class="brand">
          <div class="brand-mark">FS</div>
          <div>
            <p class="eyebrow">FS Rebuild</p>
            <h1>工作台</h1>
          </div>
        </div>

        <section class="side-section">
          <h2>当前用户</h2>
          <div class="user-card">
            <strong>{{ currentUser?.displayName }}</strong>
            <span>{{ currentUser?.username }}</span>
            <span>{{ currentUser?.orgName || '未分配组织' }}</span>
          </div>
          <ul class="tag-list">
            <li v-for="role in currentUser?.roles" :key="role.id">{{ role.name }}</li>
          </ul>
        </section>

        <section class="side-section">
          <h2>导航菜单</h2>
          <ul class="menu-tree">
            <li v-for="menu in menus" :key="menu.id">
              <div class="menu-row">
                <strong>{{ menu.menuName }}</strong>
                <span>{{ menu.routePath || '-' }}</span>
              </div>
              <ul v-if="menu.children.length" class="menu-children">
                <li v-for="child in menu.children" :key="child.id">
                  <span>{{ child.menuName }}</span>
                  <code>{{ child.routePath }}</code>
                </li>
              </ul>
            </li>
          </ul>
        </section>

        <button class="ghost-button" type="button" @click="logout">退出登录</button>
      </aside>

      <main class="main">
        <header class="topbar">
          <div>
            <p class="eyebrow">当前阶段</p>
            <strong>{{ bootstrap.currentPhase }} / {{ bootstrap.nextStep }}</strong>
          </div>
          <div class="status-row">
            <span class="status-pill" :class="connectionState === 'online' ? 'online' : 'neutral'">
              {{ connectionState === 'online' ? '后端在线' : '后端离线' }}
            </span>
            <span class="status-pill neutral">API {{ API_BASE_URL }}</span>
          </div>
        </header>

        <section class="panel hero-panel">
          <div>
            <p class="eyebrow">项目状态</p>
            <h2>{{ bootstrap.project }}</h2>
            <p class="summary">
              当前已经完成登录、字典、菜单、组织树和对象列表骨架。下一步会继续往详情页、接收批次和核查任务推进。
            </p>
            <p v-if="pageError" class="error-text">{{ pageError }}</p>
          </div>
          <div class="metrics">
            <div class="metric">
              <span class="metric-label">菜单总数</span>
              <strong>{{ totalMenuCount }}</strong>
            </div>
            <div class="metric">
              <span class="metric-label">组织根节点</span>
              <strong>{{ orgTree.nodes.length }}</strong>
            </div>
            <div class="metric">
              <span class="metric-label">对象样例</span>
              <strong>{{ relicItems.length }}</strong>
            </div>
          </div>
        </section>

        <section class="grid-two">
          <section class="panel">
            <div class="panel-header">
              <h2>阶段路线</h2>
              <span class="hint">按工程路线持续推进</span>
            </div>
            <ol class="phase-list">
              <li v-for="phase in bootstrap.phases" :key="phase.key">
                <div class="phase-index">{{ phase.key }}</div>
                <div class="phase-body">
                  <div class="phase-title-row">
                    <strong>{{ phase.name }}</strong>
                    <span class="phase-status" :class="{ pending: phase.status === 'PENDING' }">
                      {{ phaseLabel(phase.status) }}
                    </span>
                  </div>
                  <p>{{ phase.summary }}</p>
                </div>
              </li>
            </ol>
          </section>

          <section class="panel">
            <div class="panel-header">
              <h2>组织树预览</h2>
              <span class="hint">当前登录组织：{{ currentUser?.orgName }}</span>
            </div>
            <ul class="org-tree">
              <li v-for="node in orgTree.nodes" :key="node.id">
                <div class="org-node" :class="{ current: node.id === orgTree.currentOrgId }">
                  <strong>{{ node.orgName }}</strong>
                  <span>{{ node.orgCode }}</span>
                </div>
                <ul v-if="node.children.length" class="org-children">
                  <li v-for="child in node.children" :key="child.id">
                    <div class="org-node" :class="{ current: child.id === orgTree.currentOrgId }">
                      <strong>{{ child.orgName }}</strong>
                      <span>{{ child.orgCode }}</span>
                    </div>
                  </li>
                </ul>
              </li>
            </ul>
          </section>
        </section>

        <section class="panel">
          <div class="panel-header">
            <h2>对象列表示例</h2>
            <div class="toolbar">
              <input
                v-model.trim="relicKeyword"
                type="text"
                placeholder="按编号或名称搜索"
                @keyup.enter="loadRelics"
              />
              <button class="primary-button small" type="button" @click="loadRelics" :disabled="dashboardLoading">
                查询
              </button>
            </div>
          </div>

          <div class="table-shell">
            <table class="data-table">
              <thead>
                <tr>
                  <th>编号</th>
                  <th>名称</th>
                  <th>来源</th>
                  <th>类别</th>
                  <th>普查状态</th>
                  <th>核查状态</th>
                  <th>所属组织</th>
                  <th>地址</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="item in relicItems" :key="item.id">
                  <td>{{ item.objectCode }}</td>
                  <td>{{ item.objectName }}</td>
                  <td>{{ formatSource(item.sourceType) }}</td>
                  <td>{{ item.categoryCode }}</td>
                  <td>{{ formatStatus(item.surveyStatus) }}</td>
                  <td>{{ checkStatusLabel(item.checkStatus) }}</td>
                  <td>{{ item.orgName || '-' }}</td>
                  <td>{{ item.addressText }}</td>
                </tr>
                <tr v-if="!relicItems.length">
                  <td colspan="8" class="empty-cell">暂无数据</td>
                </tr>
              </tbody>
            </table>
          </div>
        </section>

        <section class="grid-two">
          <section class="panel">
            <div class="panel-header">
              <h2>当前接口</h2>
            </div>
            <ul class="deliverables">
              <li>`POST /api/auth/login` 登录</li>
              <li>`GET /api/auth/me` 当前用户</li>
              <li>`GET /api/system/bootstrap` 工程引导</li>
              <li>`GET /api/dicts/:dictCode/items` 字典项查询</li>
              <li>`GET /api/menus/current` 当前用户菜单树</li>
              <li>`GET /api/orgs/tree` 组织树</li>
              <li>`GET /api/relic-objects` 对象列表</li>
            </ul>
          </section>

          <section class="panel">
            <div class="panel-header">
              <h2>当前 SQL 输出</h2>
            </div>
            <div class="path-block">
              <code>sql/schema/003_navigation.sql</code>
              <p>菜单和角色菜单关联表。</p>
            </div>
            <div class="path-block">
              <code>sql/seed/002_menu_and_sample_data.sql</code>
              <p>首批菜单和对象样例数据。</p>
            </div>
            <div class="path-block">
              <code>backend/menu / backend/org / backend/relic</code>
              <p>菜单、组织、对象列表的最小服务骨架。</p>
            </div>
          </section>
        </section>
      </main>
    </template>

    <template v-else>
      <main class="login-shell">
        <section class="login-panel">
          <div class="login-brand">
            <div class="brand-mark">FS</div>
            <div>
              <p class="eyebrow">FS Rebuild</p>
              <h1>登录工作台</h1>
            </div>
          </div>

          <div class="connection-strip" :class="connectionState">
            <span>
              {{
                connectionState === 'online'
                  ? '后端在线'
                  : connectionState === 'offline'
                    ? '后端未连接'
                    : '正在检查后端'
              }}
            </span>
            <code>{{ API_BASE_URL }}</code>
          </div>

          <form class="login-form" @submit.prevent="submitLogin">
            <label>
              <span>用户名</span>
              <input v-model.trim="loginForm.username" type="text" placeholder="请输入用户名" />
            </label>

            <label>
              <span>密码</span>
              <input v-model="loginForm.password" type="password" placeholder="请输入密码" />
            </label>

            <p class="login-hint">当前种子数据默认账号：`admin` / `Admin@123456`</p>

            <p v-if="loginError" class="error-text">{{ loginError }}</p>

            <button class="primary-button" type="submit" :disabled="loginLoading || dashboardLoading">
              {{ loginLoading ? '正在登录...' : dashboardLoading ? '正在恢复会话...' : '登录系统' }}
            </button>
          </form>
        </section>

        <section class="preview-panel">
          <header class="preview-header">
            <div>
              <p class="eyebrow">当前阶段</p>
              <h2>{{ bootstrap.currentPhase }}</h2>
            </div>
            <span class="status-pill neutral">{{ bootstrap.nextStep }}</span>
          </header>

          <section class="preview-band">
            <div class="metric">
              <span class="metric-label">工程名</span>
              <strong>{{ bootstrap.project }}</strong>
            </div>
            <div class="metric">
              <span class="metric-label">当前目标</span>
              <strong>菜单、组织树、对象列表</strong>
            </div>
          </section>

          <section class="panel inset-panel">
            <div class="panel-header">
              <h2>复刻路线预览</h2>
            </div>
            <ol class="phase-list">
              <li v-for="phase in bootstrap.phases" :key="phase.key">
                <div class="phase-index">{{ phase.key }}</div>
                <div class="phase-body">
                  <div class="phase-title-row">
                    <strong>{{ phase.name }}</strong>
                    <span class="phase-status" :class="{ pending: phase.status === 'PENDING' }">
                      {{ phaseLabel(phase.status) }}
                    </span>
                  </div>
                  <p>{{ phase.summary }}</p>
                </div>
              </li>
            </ol>
          </section>
        </section>
      </main>
    </template>
  </div>
</template>
