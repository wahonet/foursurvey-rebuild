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

const fallbackBootstrap: BootstrapPayload = {
  project: '第四次全国文物普查复刻工作台',
  currentPhase: '基础平台',
  nextStep: '登录/权限与基础字典最小闭环',
  docsPath: 'G:/fourSurvey/四普离线端分析文档包',
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
    { code: 'init', name: '数据初始化', priority: 'P0', owner: 'backend/frontend' },
    { code: 'receive', name: '接收移动端数据', priority: 'P0', owner: 'backend/frontend' },
    { code: 'relic', name: '普查对象详情', priority: 'P0', owner: 'backend/frontend' },
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
const connectionState = ref<'connecting' | 'online' | 'offline'>('connecting')
const loginError = ref('')
const loginLoading = ref(false)
const dashboardLoading = ref(false)

const isAuthenticated = computed(() => currentUser.value !== null)

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

async function restoreSession() {
  const token = localStorage.getItem('four-survey-token')
  if (!token) {
    return
  }

  dashboardLoading.value = true
  try {
    await loadCurrentUser()
    await loadDicts()
    connectionState.value = 'online'
  } catch {
    localStorage.removeItem('four-survey-token')
    currentUser.value = null
  } finally {
    dashboardLoading.value = false
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
    await loadDicts()
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
  surveyStatusItems.value = []
  surveySourceItems.value = []
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
          <div class="brand-mark">四</div>
          <div>
            <p class="eyebrow">Four Survey</p>
            <h1>复刻工作台</h1>
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
          <h2>字典预览</h2>
          <div class="dict-block">
            <p class="dict-title">普查状态</p>
            <ul class="mini-list">
              <li v-for="item in surveyStatusItems" :key="item.id">{{ item.itemName }}</li>
            </ul>
          </div>
          <div class="dict-block">
            <p class="dict-title">调查来源</p>
            <ul class="mini-list">
              <li v-for="item in surveySourceItems" :key="item.id">{{ item.itemName }}</li>
            </ul>
          </div>
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
            <span class="status-pill online">{{ connectionState === 'online' ? '后端在线' : '后端离线' }}</span>
            <span class="status-pill neutral">API {{ API_BASE_URL }}</span>
          </div>
        </header>

        <section class="panel hero-panel">
          <div>
            <p class="eyebrow">项目状态</p>
            <h2>{{ bootstrap.project }}</h2>
            <p class="summary">
              现在已经完成了首批核心表和最小认证入口，下一步会继续接上组织、菜单、基础字典管理和普查对象列表。
            </p>
          </div>
          <div class="metrics">
            <div class="metric">
              <span class="metric-label">文档包</span>
              <strong>15 份</strong>
            </div>
            <div class="metric">
              <span class="metric-label">当前账号</span>
              <strong>{{ currentUser?.username }}</strong>
            </div>
            <div class="metric">
              <span class="metric-label">角色数</span>
              <strong>{{ currentUser?.roles.length }}</strong>
            </div>
          </div>
        </section>

        <section class="grid-two">
          <section class="panel">
            <div class="panel-header">
              <h2>阶段路线</h2>
              <span class="hint">按文档规划持续推进</span>
            </div>
            <ol class="phase-list">
              <li v-for="phase in bootstrap.phases" :key="phase.key">
                <div class="phase-index">{{ phase.key }}</div>
                <div class="phase-body">
                  <div class="phase-title-row">
                    <strong>{{ phase.name }}</strong>
                    <span
                      class="phase-status"
                      :class="{ pending: phase.status === 'PENDING' }"
                    >
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
              <h2>首批模块</h2>
              <span class="hint">P0 / P1 优先</span>
            </div>
            <div class="module-table">
              <div class="module-row module-head">
                <span>模块</span>
                <span>归属</span>
                <span>优先级</span>
              </div>
              <div v-for="module in bootstrap.modules" :key="module.code" class="module-row">
                <span>{{ module.name }}</span>
                <span>{{ module.owner }}</span>
                <span class="priority-chip">{{ module.priority }}</span>
              </div>
            </div>
          </section>
        </section>

        <section class="grid-two">
          <section class="panel">
            <div class="panel-header">
              <h2>当前可用接口</h2>
            </div>
            <ul class="deliverables">
              <li>`POST /api/auth/login` 登录</li>
              <li>`GET /api/auth/me` 当前用户</li>
              <li>`GET /api/system/bootstrap` 工程引导数据</li>
              <li>`GET /api/dicts/:dictCode/items` 字典项查询</li>
            </ul>
          </section>

          <section class="panel">
            <div class="panel-header">
              <h2>当前输出</h2>
            </div>
            <div class="path-block">
              <code>sql/schema/001_core_platform.sql</code>
              <p>组织、角色、用户、区域、字典、附件等平台表。</p>
            </div>
            <div class="path-block">
              <code>sql/schema/002_core_business.sql</code>
              <p>普查对象、接收批次、接收记录、核查任务等业务主干表。</p>
            </div>
            <div class="path-block">
              <code>sql/seed/001_initial_auth_and_dict.sql</code>
              <p>初始管理员、角色、区域和首批字典项。</p>
            </div>
          </section>
        </section>
      </main>
    </template>

    <template v-else>
      <main class="login-shell">
        <section class="login-panel">
          <div class="login-brand">
            <div class="brand-mark">四</div>
            <div>
              <p class="eyebrow">Fourth Survey</p>
              <h1>复刻系统登录</h1>
            </div>
          </div>

          <div class="connection-strip" :class="connectionState">
            <span>{{ connectionState === 'online' ? '后端在线' : connectionState === 'offline' ? '后端未连接' : '正在检查后端' }}</span>
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

            <p class="login-hint">
              当前种子数据默认账号：`admin` / `Admin@123456`
            </p>

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
              <span class="metric-label">文档路径</span>
              <strong>{{ bootstrap.docsPath }}</strong>
            </div>
            <div class="metric">
              <span class="metric-label">后端接口</span>
              <strong>认证 / 字典 / 引导数据</strong>
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
                    <span
                      class="phase-status"
                      :class="{ pending: phase.status === 'PENDING' }"
                    >
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
