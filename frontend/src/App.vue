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

type RelicPoint = {
  id: number
  pointType: string
  longitude: number
  latitude: number
  altitude: number | null
  coordinateSystem: string
  sourceType: string | null
}

type RelicDetail = {
  id: number
  objectCode: string
  objectName: string
  sourceType: string
  categoryCode: string
  levelCode: string | null
  surveyStatus: string
  checkStatus: string
  addressText: string
  eraText: string | null
  abstractText: string | null
  currentUse: string | null
  protectionScope: string | null
  constructionControl: string | null
  orgName: string | null
  fillStartedAt: string | null
  submittedAt: string | null
  points: RelicPoint[]
}

type RelicUpdatePayload = {
  objectName: string
  categoryCode: string
  surveyStatus: string
  checkStatus: string
  addressText: string
  eraText: string
  currentUse: string
  abstractText: string
  protectionScope: string
  constructionControl: string
}

type ReceiveBatchItem = {
  id: number
  batchNo: string
  batchName: string
  receiveSource: string
  recordCount: number
  receiveStatus: string
  receiveOrgName: string | null
  operatorName: string | null
  receivedAt: string | null
}

type ReceiveRecord = {
  id: number
  recordNo: string
  surveyType: string
  objectName: string
  categoryCode: string | null
  regionCode: string | null
  addressText: string | null
  receiveStatus: string
  operatorName: string | null
  operatedAt: string | null
}

type ReceiveBatchDetail = {
  id: number
  batchNo: string
  batchName: string
  receiveSource: string
  packageName: string | null
  packagePath: string | null
  recordCount: number
  receiveStatus: string
  receiveOrgName: string | null
  operatorName: string | null
  receivedAt: string | null
  remark: string | null
  records: ReceiveRecord[]
}

type ReceiveBatchProcessPayload = {
  action: 'START_REVIEW' | 'COMPLETE' | 'RESET'
  remark: string
}

const fallbackBootstrap: BootstrapPayload = {
  project: 'FS Rebuild Console',
  currentPhase: '基础平台',
  nextStep: '对象编辑表单与接收处理动作',
  docsPath: 'G:/fourSurvey/FS-doc-bundle',
  phases: [
    {
      key: '01',
      name: '基础平台',
      status: 'IN_PROGRESS',
      summary: '登录、权限、菜单、组织与基础字典',
    },
    {
      key: '02',
      name: '核心建模',
      status: 'IN_PROGRESS',
      summary: '对象、接收批次、底账与核查任务',
    },
    {
      key: '03',
      name: '业务闭环',
      status: 'PENDING',
      summary: '数据初始化、接收数据、采集与核查',
    },
    {
      key: '04',
      name: '增强能力',
      status: 'PENDING',
      summary: '地图工作台、统计导出与报送',
    },
    {
      key: '05',
      name: '迁移试点',
      status: 'PENDING',
      summary: '旧库迁移、试点验收与切换',
    },
  ],
  modules: [
    { code: 'auth', name: '登录与权限', priority: 'P0', owner: 'backend' },
    { code: 'dict', name: '基础字典', priority: 'P0', owner: 'backend' },
    { code: 'menu', name: '导航菜单', priority: 'P0', owner: 'backend' },
    { code: 'org', name: '组织树', priority: 'P0', owner: 'backend' },
    { code: 'relic', name: '对象列表与编辑', priority: 'P0', owner: 'backend/frontend' },
    { code: 'receive', name: '接收批次处理', priority: 'P0', owner: 'backend/frontend' },
    { code: 'map', name: '地图工作台', priority: 'P1', owner: 'map' },
  ],
}

const loginForm = reactive({
  username: 'admin',
  password: 'Admin@123456',
})

const relicForm = reactive<RelicUpdatePayload>({
  objectName: '',
  categoryCode: '',
  surveyStatus: '',
  checkStatus: '',
  addressText: '',
  eraText: '',
  currentUse: '',
  abstractText: '',
  protectionScope: '',
  constructionControl: '',
})

const batchActionForm = reactive({
  remark: '',
})

const bootstrap = ref<BootstrapPayload>(fallbackBootstrap)
const surveyStatusItems = ref<DictItem[]>([])
const surveySourceItems = ref<DictItem[]>([])
const relicCategoryItems = ref<DictItem[]>([])
const checkStatusItems = ref<DictItem[]>([])
const currentUser = ref<CurrentUserPayload | null>(null)
const menus = ref<MenuNode[]>([])
const orgTree = ref<OrgTreePayload>({ currentOrgId: null, nodes: [] })
const relicItems = ref<RelicItem[]>([])
const selectedRelicId = ref<number | null>(null)
const selectedRelic = ref<RelicDetail | null>(null)
const receiveBatches = ref<ReceiveBatchItem[]>([])
const selectedBatchId = ref<number | null>(null)
const selectedBatch = ref<ReceiveBatchDetail | null>(null)
const relicKeyword = ref('')
const connectionState = ref<'connecting' | 'online' | 'offline'>('connecting')
const loginError = ref('')
const pageError = ref('')
const relicError = ref('')
const relicMessage = ref('')
const batchError = ref('')
const batchMessage = ref('')
const loginLoading = ref(false)
const dashboardLoading = ref(false)
const savingRelic = ref(false)
const processingBatch = ref(false)

const isAuthenticated = computed(() => currentUser.value !== null)
const totalMenuCount = computed(() => countMenus(menus.value))

function countMenus(nodes: MenuNode[]): number {
  return nodes.reduce((sum, node) => sum + 1 + countMenus(node.children), 0)
}

function phaseLabel(status: string) {
  if (status === 'IN_PROGRESS') return '进行中'
  if (status === 'PENDING') return '待开始'
  return status
}

function findDictLabel(items: DictItem[], code: string | null | undefined) {
  if (!code) return '-'
  return items.find((item) => item.itemCode === code)?.itemName ?? code
}

function formatSource(sourceType: string | null | undefined) {
  return findDictLabel(surveySourceItems.value, sourceType)
}

function formatSurveyStatus(status: string | null | undefined) {
  return findDictLabel(surveyStatusItems.value, status)
}

function formatCategory(categoryCode: string | null | undefined) {
  return findDictLabel(relicCategoryItems.value, categoryCode)
}

function formatCheckStatus(value: string | null | undefined) {
  return findDictLabel(checkStatusItems.value, value)
}

function formatBatchStatus(value: string | null | undefined) {
  if (!value) return '-'
  if (value === 'IMPORTED') return '已导入'
  if (value === 'IN_REVIEW') return '处理中'
  if (value === 'PROCESSED') return '已完成'
  return value
}

function formatDateTime(value: string | null | undefined) {
  if (!value) return '-'
  return value.replace('T', ' ').slice(0, 19)
}

function syncRelicForm(detail: RelicDetail | null) {
  relicForm.objectName = detail?.objectName ?? ''
  relicForm.categoryCode = detail?.categoryCode ?? ''
  relicForm.surveyStatus = detail?.surveyStatus ?? ''
  relicForm.checkStatus = detail?.checkStatus ?? ''
  relicForm.addressText = detail?.addressText ?? ''
  relicForm.eraText = detail?.eraText ?? ''
  relicForm.currentUse = detail?.currentUse ?? ''
  relicForm.abstractText = detail?.abstractText ?? ''
  relicForm.protectionScope = detail?.protectionScope ?? ''
  relicForm.constructionControl = detail?.constructionControl ?? ''
}

function syncBatchForm(detail: ReceiveBatchDetail | null) {
  batchActionForm.remark = detail?.remark ?? ''
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
  const [statusItems, sourceItems, categoryItems, checkItems] = await Promise.all([
    apiRequest<DictItem[]>('/api/dicts/survey_status/items', { method: 'GET' }),
    apiRequest<DictItem[]>('/api/dicts/survey_source/items', { method: 'GET' }),
    apiRequest<DictItem[]>('/api/dicts/relic_category/items', { method: 'GET' }),
    apiRequest<DictItem[]>('/api/dicts/check_status/items', { method: 'GET' }),
  ])

  surveyStatusItems.value = statusItems
  surveySourceItems.value = sourceItems
  relicCategoryItems.value = categoryItems
  checkStatusItems.value = checkItems
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

  if (!relicItems.value.length) {
    selectedRelicId.value = null
    selectedRelic.value = null
    syncRelicForm(null)
    return
  }

  if (selectedRelicId.value && relicItems.value.some((item) => item.id === selectedRelicId.value)) {
    await loadRelicDetail(selectedRelicId.value)
    return
  }

  await selectRelic(relicItems.value[0].id)
}

async function loadRelicDetail(id: number) {
  selectedRelic.value = await apiRequest<RelicDetail>(`/api/relic-objects/${id}`, { method: 'GET' })
  syncRelicForm(selectedRelic.value)
}

async function selectRelic(id: number) {
  selectedRelicId.value = id
  relicError.value = ''
  relicMessage.value = ''
  await loadRelicDetail(id)
}

async function saveRelic() {
  if (!selectedRelicId.value) return

  savingRelic.value = true
  relicError.value = ''
  relicMessage.value = ''

  try {
    const updated = await apiRequest<RelicDetail>(`/api/relic-objects/${selectedRelicId.value}`, {
      method: 'PUT',
      body: JSON.stringify(relicForm),
    })
    selectedRelic.value = updated
    syncRelicForm(updated)
    await loadRelics()
    relicMessage.value = '对象信息已保存'
  } catch (error) {
    relicError.value = error instanceof Error ? error.message : '对象保存失败'
  } finally {
    savingRelic.value = false
  }
}

function resetRelicForm() {
  syncRelicForm(selectedRelic.value)
  relicError.value = ''
  relicMessage.value = '已恢复为当前详情内容'
}

async function loadReceiveBatches() {
  receiveBatches.value = await apiRequest<ReceiveBatchItem[]>('/api/receive-batches', { method: 'GET' })

  if (!receiveBatches.value.length) {
    selectedBatchId.value = null
    selectedBatch.value = null
    syncBatchForm(null)
    return
  }

  if (selectedBatchId.value && receiveBatches.value.some((item) => item.id === selectedBatchId.value)) {
    await loadReceiveBatchDetail(selectedBatchId.value)
    return
  }

  await selectBatch(receiveBatches.value[0].id)
}

async function loadReceiveBatchDetail(id: number) {
  selectedBatch.value = await apiRequest<ReceiveBatchDetail>(`/api/receive-batches/${id}`, {
    method: 'GET',
  })
  syncBatchForm(selectedBatch.value)
}

async function selectBatch(id: number) {
  selectedBatchId.value = id
  batchError.value = ''
  batchMessage.value = ''
  await loadReceiveBatchDetail(id)
}

async function processBatch(action: ReceiveBatchProcessPayload['action']) {
  if (!selectedBatchId.value) return

  processingBatch.value = true
  batchError.value = ''
  batchMessage.value = ''

  try {
    const updated = await apiRequest<ReceiveBatchDetail>(`/api/receive-batches/${selectedBatchId.value}/process`, {
      method: 'POST',
      body: JSON.stringify({
        action,
        remark: batchActionForm.remark,
      } satisfies ReceiveBatchProcessPayload),
    })
    selectedBatch.value = updated
    syncBatchForm(updated)
    await loadReceiveBatches()

    if (action === 'START_REVIEW') batchMessage.value = '批次已转为处理中'
    if (action === 'COMPLETE') batchMessage.value = '批次已标记为已完成'
    if (action === 'RESET') batchMessage.value = '批次已重置为已导入'
  } catch (error) {
    batchError.value = error instanceof Error ? error.message : '批次处理失败'
  } finally {
    processingBatch.value = false
  }
}

async function loadWorkspaceData() {
  dashboardLoading.value = true
  pageError.value = ''

  try {
    await Promise.all([loadCurrentUser(), loadDicts(), loadMenus(), loadOrgTree()])
    await Promise.all([loadRelics(), loadReceiveBatches()])
    connectionState.value = 'online'
  } catch (error) {
    pageError.value = error instanceof Error ? error.message : '工作台加载失败'
    throw error
  } finally {
    dashboardLoading.value = false
  }
}

async function restoreSession() {
  const token = localStorage.getItem('four-survey-token')
  if (!token) return

  try {
    await loadWorkspaceData()
  } catch {
    localStorage.removeItem('four-survey-token')
    currentUser.value = null
    menus.value = []
    orgTree.value = { currentOrgId: null, nodes: [] }
    relicItems.value = []
    selectedRelicId.value = null
    selectedRelic.value = null
    receiveBatches.value = []
    selectedBatchId.value = null
    selectedBatch.value = null
    syncRelicForm(null)
    syncBatchForm(null)
  }
}

async function submitLogin() {
  loginLoading.value = true
  loginError.value = ''

  try {
    const result = await apiRequest<LoginResponse>('/api/auth/login', {
      method: 'POST',
      authenticated: false,
      body: JSON.stringify(loginForm),
    })

    localStorage.setItem('four-survey-token', result.accessToken)
    currentUser.value = result.user
    await loadWorkspaceData()
  } catch (error) {
    loginError.value = error instanceof Error ? error.message : '登录失败，请检查账号和后端服务'
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
  selectedRelicId.value = null
  selectedRelic.value = null
  receiveBatches.value = []
  selectedBatchId.value = null
  selectedBatch.value = null
  surveyStatusItems.value = []
  surveySourceItems.value = []
  relicCategoryItems.value = []
  checkStatusItems.value = []
  syncRelicForm(null)
  syncBatchForm(null)
  relicMessage.value = ''
  relicError.value = ''
  batchMessage.value = ''
  batchError.value = ''
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
              当前已经具备登录、菜单、组织树、对象列表、对象详情、接收批次和接收记录骨架。
              这一轮继续往前推，补上对象编辑表单和接收批次处理动作，形成一个最小可操作闭环。
            </p>
            <p v-if="pageError" class="error-text">{{ pageError }}</p>
          </div>
          <div class="metrics">
            <div class="metric">
              <span class="metric-label">菜单总数</span>
              <strong>{{ totalMenuCount }}</strong>
            </div>
            <div class="metric">
              <span class="metric-label">对象样例</span>
              <strong>{{ relicItems.length }}</strong>
            </div>
            <div class="metric">
              <span class="metric-label">接收批次</span>
              <strong>{{ receiveBatches.length }}</strong>
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

        <section class="workspace-grid">
          <section class="panel">
            <div class="panel-header">
              <h2>对象列表</h2>
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
                  </tr>
                </thead>
                <tbody>
                  <tr
                    v-for="item in relicItems"
                    :key="item.id"
                    class="clickable-row"
                    :class="{ active: item.id === selectedRelicId }"
                    @click="selectRelic(item.id)"
                  >
                    <td>{{ item.objectCode }}</td>
                    <td>{{ item.objectName }}</td>
                    <td>{{ formatSource(item.sourceType) }}</td>
                    <td>{{ formatCategory(item.categoryCode) }}</td>
                    <td>{{ formatSurveyStatus(item.surveyStatus) }}</td>
                    <td>{{ formatCheckStatus(item.checkStatus) }}</td>
                  </tr>
                  <tr v-if="!relicItems.length">
                    <td colspan="6" class="empty-cell">暂无数据</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </section>

          <section class="panel">
            <div class="panel-header">
              <h2>对象详情</h2>
              <span class="hint">{{ selectedRelic?.objectCode || '未选中对象' }}</span>
            </div>

            <div v-if="selectedRelic" class="detail-stack">
              <div class="detail-card">
                <div class="detail-title-row">
                  <div>
                    <p class="eyebrow">对象编辑</p>
                    <h3>{{ selectedRelic.objectName }}</h3>
                  </div>
                  <div class="badge-group">
                    <span class="detail-badge">{{ formatSurveyStatus(selectedRelic.surveyStatus) }}</span>
                    <span class="detail-badge muted">{{ formatCheckStatus(selectedRelic.checkStatus) }}</span>
                  </div>
                </div>

                <div class="detail-grid">
                  <div class="wide">
                    <label class="form-field">
                      <span class="detail-label">对象名称</span>
                      <input v-model.trim="relicForm.objectName" type="text" />
                    </label>
                  </div>
                  <div>
                    <label class="form-field">
                      <span class="detail-label">类别</span>
                      <select v-model="relicForm.categoryCode">
                        <option value="">请选择</option>
                        <option v-for="item in relicCategoryItems" :key="item.id" :value="item.itemCode">
                          {{ item.itemName }}
                        </option>
                      </select>
                    </label>
                  </div>
                  <div>
                    <label class="form-field">
                      <span class="detail-label">来源</span>
                      <input :value="formatSource(selectedRelic.sourceType)" type="text" disabled />
                    </label>
                  </div>
                  <div>
                    <label class="form-field">
                      <span class="detail-label">普查状态</span>
                      <select v-model="relicForm.surveyStatus">
                        <option value="">请选择</option>
                        <option v-for="item in surveyStatusItems" :key="item.id" :value="item.itemCode">
                          {{ item.itemName }}
                        </option>
                      </select>
                    </label>
                  </div>
                  <div>
                    <label class="form-field">
                      <span class="detail-label">核查状态</span>
                      <select v-model="relicForm.checkStatus">
                        <option value="">请选择</option>
                        <option v-for="item in checkStatusItems" :key="item.id" :value="item.itemCode">
                          {{ item.itemName }}
                        </option>
                      </select>
                    </label>
                  </div>
                  <div>
                    <label class="form-field">
                      <span class="detail-label">年代</span>
                      <input v-model.trim="relicForm.eraText" type="text" />
                    </label>
                  </div>
                  <div>
                    <label class="form-field">
                      <span class="detail-label">当前组织</span>
                      <input :value="selectedRelic.orgName || '-'" type="text" disabled />
                    </label>
                  </div>
                  <div>
                    <label class="form-field">
                      <span class="detail-label">现状用途</span>
                      <input v-model.trim="relicForm.currentUse" type="text" />
                    </label>
                  </div>
                  <div class="wide">
                    <label class="form-field">
                      <span class="detail-label">地址</span>
                      <input v-model.trim="relicForm.addressText" type="text" />
                    </label>
                  </div>
                  <div class="wide">
                    <label class="form-field">
                      <span class="detail-label">简介</span>
                      <textarea v-model.trim="relicForm.abstractText" rows="3"></textarea>
                    </label>
                  </div>
                  <div>
                    <label class="form-field">
                      <span class="detail-label">保护范围</span>
                      <textarea v-model.trim="relicForm.protectionScope" rows="3"></textarea>
                    </label>
                  </div>
                  <div>
                    <label class="form-field">
                      <span class="detail-label">建设控制地带</span>
                      <textarea v-model.trim="relicForm.constructionControl" rows="3"></textarea>
                    </label>
                  </div>
                </div>

                <div class="form-actions">
                  <button class="primary-button small" type="button" @click="saveRelic" :disabled="savingRelic">
                    {{ savingRelic ? '正在保存...' : '保存对象' }}
                  </button>
                  <button class="secondary-button small" type="button" @click="resetRelicForm" :disabled="savingRelic">
                    还原当前详情
                  </button>
                  <span class="hint">填报开始：{{ formatDateTime(selectedRelic.fillStartedAt) }}</span>
                </div>
                <p v-if="relicError" class="error-text">{{ relicError }}</p>
                <p v-else-if="relicMessage" class="success-text">{{ relicMessage }}</p>
              </div>

              <div class="detail-card">
                <p class="eyebrow">点位信息</p>
                <div class="detail-title-row detail-title-row--compact">
                  <h3>空间位置</h3>
                  <span class="hint">{{ selectedRelic.points.length }} 个点</span>
                </div>
                <div v-if="selectedRelic.points.length" class="point-list">
                  <div v-for="point in selectedRelic.points" :key="point.id" class="point-item">
                    <div>
                      <span class="detail-label">点位类型</span>
                      <strong>{{ point.pointType }}</strong>
                    </div>
                    <div>
                      <span class="detail-label">经纬度</span>
                      <strong>{{ point.longitude }}, {{ point.latitude }}</strong>
                    </div>
                    <div>
                      <span class="detail-label">高程</span>
                      <strong>{{ point.altitude ?? '-' }}</strong>
                    </div>
                    <div>
                      <span class="detail-label">坐标系</span>
                      <strong>{{ point.coordinateSystem }}</strong>
                    </div>
                  </div>
                </div>
                <p v-else class="empty-inline">暂无点位数据</p>
              </div>
            </div>

            <div v-else class="empty-state">先从左侧列表选择一个对象</div>
          </section>
        </section>

        <section class="workspace-grid">
          <section class="panel">
            <div class="panel-header">
              <h2>接收批次</h2>
              <span class="hint">最近 {{ receiveBatches.length }} 个批次</span>
            </div>

            <div class="table-shell">
              <table class="data-table">
                <thead>
                  <tr>
                    <th>批次号</th>
                    <th>批次名称</th>
                    <th>状态</th>
                    <th>记录数</th>
                    <th>接收时间</th>
                  </tr>
                </thead>
                <tbody>
                  <tr
                    v-for="batch in receiveBatches"
                    :key="batch.id"
                    class="clickable-row"
                    :class="{ active: batch.id === selectedBatchId }"
                    @click="selectBatch(batch.id)"
                  >
                    <td>{{ batch.batchNo }}</td>
                    <td>{{ batch.batchName }}</td>
                    <td>{{ formatBatchStatus(batch.receiveStatus) }}</td>
                    <td>{{ batch.recordCount }}</td>
                    <td>{{ formatDateTime(batch.receivedAt) }}</td>
                  </tr>
                  <tr v-if="!receiveBatches.length">
                    <td colspan="5" class="empty-cell">暂无批次数据</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </section>

          <section class="panel">
            <div class="panel-header">
              <h2>批次详情</h2>
              <span class="hint">{{ selectedBatch?.batchNo || '未选中批次' }}</span>
            </div>

            <div v-if="selectedBatch" class="detail-stack">
              <div class="detail-card">
                <div class="detail-title-row">
                  <div>
                    <p class="eyebrow">处理动作</p>
                    <h3>{{ selectedBatch.batchName }}</h3>
                  </div>
                  <div class="badge-group">
                    <span class="detail-badge">{{ formatBatchStatus(selectedBatch.receiveStatus) }}</span>
                    <span class="detail-badge muted">{{ selectedBatch.recordCount }} 条</span>
                  </div>
                </div>

                <div class="detail-grid">
                  <div>
                    <span class="detail-label">批次号</span>
                    <strong>{{ selectedBatch.batchNo }}</strong>
                  </div>
                  <div>
                    <span class="detail-label">来源</span>
                    <strong>{{ selectedBatch.receiveSource }}</strong>
                  </div>
                  <div>
                    <span class="detail-label">接收组织</span>
                    <strong>{{ selectedBatch.receiveOrgName || '-' }}</strong>
                  </div>
                  <div>
                    <span class="detail-label">操作人</span>
                    <strong>{{ selectedBatch.operatorName || '-' }}</strong>
                  </div>
                  <div class="wide">
                    <span class="detail-label">包文件</span>
                    <strong>{{ selectedBatch.packageName || '-' }}</strong>
                  </div>
                  <div class="wide">
                    <span class="detail-label">包路径</span>
                    <strong>{{ selectedBatch.packagePath || '-' }}</strong>
                  </div>
                </div>

                <label class="form-field form-field--stacked">
                  <span class="detail-label">处理备注</span>
                  <textarea v-model.trim="batchActionForm.remark" rows="3"></textarea>
                </label>

                <div class="form-actions">
                  <button
                    class="primary-button small"
                    type="button"
                    @click="processBatch('START_REVIEW')"
                    :disabled="processingBatch"
                  >
                    {{ processingBatch ? '处理中...' : '转处理中' }}
                  </button>
                  <button
                    class="secondary-button small"
                    type="button"
                    @click="processBatch('COMPLETE')"
                    :disabled="processingBatch"
                  >
                    标记完成
                  </button>
                  <button
                    class="secondary-button small"
                    type="button"
                    @click="processBatch('RESET')"
                    :disabled="processingBatch"
                  >
                    重置状态
                  </button>
                </div>

                <p v-if="batchError" class="error-text">{{ batchError }}</p>
                <p v-else-if="batchMessage" class="success-text">{{ batchMessage }}</p>
              </div>

              <div class="detail-card">
                <div class="panel-header compact">
                  <h3>接收记录</h3>
                  <span class="hint">{{ selectedBatch.records.length }} 条</span>
                </div>
                <div class="table-shell nested">
                  <table class="data-table compact-table">
                    <thead>
                      <tr>
                        <th>记录号</th>
                        <th>名称</th>
                        <th>调查类型</th>
                        <th>类别</th>
                        <th>状态</th>
                        <th>操作人</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr v-for="record in selectedBatch.records" :key="record.id">
                        <td>{{ record.recordNo || '-' }}</td>
                        <td>{{ record.objectName }}</td>
                        <td>{{ formatSource(record.surveyType) }}</td>
                        <td>{{ formatCategory(record.categoryCode) }}</td>
                        <td>{{ formatBatchStatus(record.receiveStatus) }}</td>
                        <td>{{ record.operatorName || '-' }}</td>
                      </tr>
                      <tr v-if="!selectedBatch.records.length">
                        <td colspan="6" class="empty-cell">暂无接收记录</td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </div>
            </div>

            <div v-else class="empty-state">先从左侧列表选择一个批次</div>
          </section>
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
              <li>`GET /api/relic-objects/:id` 对象详情</li>
              <li>`PUT /api/relic-objects/:id` 对象保存</li>
              <li>`GET /api/receive-batches` 接收批次列表</li>
              <li>`GET /api/receive-batches/:id` 接收批次详情</li>
              <li>`POST /api/receive-batches/:id/process` 批次处理动作</li>
            </ul>
          </section>

          <section class="panel">
            <div class="panel-header">
              <h2>当前输出</h2>
            </div>
            <div class="path-block">
              <code>backend/relic</code>
              <p>对象列表、详情、保存接口与表单映射。</p>
            </div>
            <div class="path-block">
              <code>backend/receive</code>
              <p>接收批次状态流转、备注处理与记录状态同步。</p>
            </div>
            <div class="path-block">
              <code>frontend/src/App.vue</code>
              <p>对象编辑表单、批次处理动作和最小操作反馈。</p>
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
              <strong>对象编辑与批次处理</strong>
            </div>
          </section>

          <section class="panel inset-panel">
            <div class="panel-header">
              <h2>当前模块</h2>
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
      </main>
    </template>
  </div>
</template>
