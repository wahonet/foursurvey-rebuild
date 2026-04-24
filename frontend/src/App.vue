<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import { API_BASE_URL, apiRequest } from './api'

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

type MenuKey =
  | 'home'
  | 'data-init'
  | 'mobile-download'
  | 'receive'
  | 'survey'
  | 'quality'
  | 'report'
  | 'query'
  | 'basic'
  | 'stats'
  | 'system'

type DetailSectionKey =
  | 'cover'
  | 'basic'
  | 'body'
  | 'attachment'
  | 'boundary'
  | 'clue'
  | 'topic'
  | 'specimen'
  | 'other'
  | 'drawing'
  | 'photo'
  | 'vector'

type ToolbarButton = {
  key: string
  label: string
  variant?: 'primary' | 'danger' | 'ghost'
}

type TableCell = {
  text: string | number
  type?: 'checkbox' | 'link' | 'muted'
}

type TableRow = {
  id: number
  cells: TableCell[]
  clickable?: boolean
}

type ListConfig = {
  tabs: { key: string; label: string }[]
  activeTab: string
  buttons: ToolbarButton[]
  headers: string[]
  rows: TableRow[]
  supportsSearch: boolean
  searchPlaceholder?: string
}

type DetailNavNode =
  | {
      kind: 'single'
      key: DetailSectionKey
      label: string
    }
  | {
      kind: 'group'
      label: string
      children: { key: DetailSectionKey; label: string }[]
    }

type BoundaryRow = {
  order: number
  groupName: string
  pointType: string
  latitudeText: string
  longitudeText: string
  altitudeText: string
  noteText: string
  remarkText: string
}

type PhotoRow = {
  order: number
  thumb: string
  relatedType: string
  name: string
  code: string
  photoNo: string
  filmNo: string
  photographer: string
  shotAt: string
  direction: string
  note: string
}

type AttachmentRow = {
  order: number
  groupName: string
  name: string
  categoryName: string
  areaText: string
}

type RelationRow = {
  order: number
  code: string
  name: string
  categoryName: string
  addressText: string
  noteText: string
}

type ShellNavChild = {
  id: string
  key: MenuKey
  label: string
}

type ShellNavNode =
  | {
      kind: 'item'
      key: MenuKey
      label: string
      icon: string
    }
  | {
      kind: 'group'
      id: string
      label: string
      icon: string
      children: ShellNavChild[]
    }

type TopTool = {
  key: string
  title: string
  icon: string
}

type HomeStatItem = {
  label: string
  value: number
}

type HomeStatSection = {
  title: string
  items: HomeStatItem[]
}

const menuLabelMap: Record<MenuKey, string> = {
  home: '首页',
  'data-init': '数据初始化',
  'mobile-download': '移动端下载基础数据',
  receive: '接收移动端数据',
  survey: '普查数据采集',
  quality: '数据质量核查',
  report: '报送省平台',
  query: '数据查询',
  basic: '基础数据',
  stats: '数据统计',
  system: '系统管理',
}

const shellNavNodes: ShellNavNode[] = [
  { kind: 'item', key: 'home', label: '首页', icon: 'home' },
  { kind: 'item', key: 'data-init', label: '数据初始化', icon: 'reset' },
  { kind: 'item', key: 'mobile-download', label: '移动端下载基础数据', icon: 'download' },
  { kind: 'item', key: 'receive', label: '接收移动端数据', icon: 'upload' },
  { kind: 'item', key: 'survey', label: '普查数据采集', icon: 'survey' },
  { kind: 'item', key: 'quality', label: '数据质量核查', icon: 'check' },
  { kind: 'item', key: 'report', label: '报送省平台', icon: 'report' },
  {
    kind: 'group',
    id: 'query',
    label: '数据查询',
    icon: 'query',
    children: [
      { id: 'query-immovable', key: 'query', label: '不可移动文物查询' },
      { id: 'query-change', key: 'query', label: '变更文物登记表查询' },
    ],
  },
  {
    kind: 'group',
    id: 'basic',
    label: '基础数据',
    icon: 'basic',
    children: [
      { id: 'basic-third', key: 'basic', label: '三普文物信息库' },
      { id: 'basic-unit', key: 'basic', label: '文保单位信息库' },
      { id: 'basic-clue', key: 'basic', label: '线索库' },
      { id: 'basic-topic', key: 'basic', label: '专题文物' },
    ],
  },
  {
    kind: 'group',
    id: 'stats',
    label: '数据统计',
    icon: 'stats',
    children: [
      { id: 'stats-survey', key: 'stats', label: '普查情况统计' },
      { id: 'stats-workload', key: 'stats', label: '工作量统计' },
    ],
  },
  {
    kind: 'group',
    id: 'system',
    label: '系统管理',
    icon: 'system',
    children: [
      { id: 'system-backup', key: 'system', label: '数据备份管理' },
      { id: 'system-user', key: 'system', label: '用户管理' },
      { id: 'system-log', key: 'system', label: '操作日志' },
      { id: 'system-report', key: 'system', label: '报送设置' },
    ],
  },
]

const topTools: TopTool[] = [
  { key: 'account', title: '用户中心', icon: 'user' },
  { key: 'password', title: '修改密码', icon: 'lock' },
  { key: 'switch', title: '切换单位', icon: 'switch' },
  { key: 'scan', title: '扫码', icon: 'scan' },
  { key: 'fullscreen', title: '全屏', icon: 'expand' },
  { key: 'about', title: '关于', icon: 'info' },
]

const homeFlowSteps: { key: MenuKey; label: string; caption: string }[] = [
  { key: 'data-init', label: '数据初始化', caption: '建立离线底账' },
  { key: 'mobile-download', label: '移动端下载基础数据', caption: '下发外业底包' },
  { key: 'receive', label: '接收移动端数据', caption: '汇总回传成果' },
  { key: 'survey', label: '普查数据采集', caption: '登记与编辑主档' },
  { key: 'quality', label: '数据质量核查', caption: '核查退回与复核' },
  { key: 'report', label: '报送省平台', caption: '形成报送成果' },
]

const homeSupportLinks = ['标准规范', '操作手册', '在线支持', '联系我们', '升级日志']

const detailNavNodes: DetailNavNode[] = [
  { kind: 'single', key: 'cover', label: '封面' },
  {
    kind: 'group',
    label: '不可移动文物登记表',
    children: [
      { key: 'basic', label: '基本信息' },
      { key: 'body', label: '本体文物' },
      { key: 'attachment', label: '附属文物' },
      { key: 'boundary', label: '本体边界坐标' },
      { key: 'clue', label: '关联线索库' },
      { key: 'topic', label: '关联专题文物' },
    ],
  },
  { kind: 'single', key: 'specimen', label: '标本登记表' },
  { kind: 'single', key: 'other', label: '其他资料登记表' },
  { kind: 'single', key: 'drawing', label: '图纸册页' },
  { kind: 'single', key: 'photo', label: '照片册页' },
  { kind: 'single', key: 'vector', label: '文物矢量图' },
]

const loginForm = reactive({
  username: '',
  password: '',
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

const currentUser = ref<CurrentUserPayload | null>(null)
const surveyStatusItems = ref<DictItem[]>([])
const surveySourceItems = ref<DictItem[]>([])
const relicCategoryItems = ref<DictItem[]>([])
const checkStatusItems = ref<DictItem[]>([])
const relicItems = ref<RelicItem[]>([])
const selectedRelicId = ref<number | null>(null)
const selectedRelic = ref<RelicDetail | null>(null)
const receiveBatches = ref<ReceiveBatchItem[]>([])
const selectedBatchId = ref<number | null>(null)
const selectedBatch = ref<ReceiveBatchDetail | null>(null)
const selectedMenu = ref<MenuKey>('home')
const activePageLabel = ref('首页')
const expandedShellGroups = ref<string[]>([])
const pageMode = ref<'list' | 'detail'>('list')
const selectedDetailSection = ref<DetailSectionKey>('cover')
const selectedInitTab = ref('third-census')
const selectedSurveyTab = ref('collect')
const selectedReceiveTab = ref('immovable')
const relicKeyword = ref('')
const loginError = ref('')
const pageError = ref('')
const actionMessage = ref('')
const relicError = ref('')
const relicMessage = ref('')
const batchError = ref('')
const batchMessage = ref('')
const connectionState = ref<'connecting' | 'online' | 'offline'>('connecting')
const loginLoading = ref(false)
const dashboardLoading = ref(false)
const savingRelic = ref(false)
const processingBatch = ref(false)

const isAuthenticated = computed(() => currentUser.value !== null)

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

function formatBatchStatus(value: string | null | undefined) {
  if (!value) return '-'
  if (value === 'IMPORTED') return '已导入'
  if (value === 'IN_REVIEW') return '处理中'
  if (value === 'PROCESSED') return '已完成'
  return value
}

function formatLegacyCode(code: string | null | undefined) {
  if (!code) return '-'
  return code.startsWith('FS-') ? code.slice(3) : code
}

function formatDateTime(value: string | null | undefined) {
  if (!value) return '-'
  return value.replace('T', ' ').slice(0, 19)
}

function mockEraById(id: number) {
  const eras = ['清康熙十四年(1675)', '明', '民国三十三年(1944)', '不详']
  return eras[(id - 1) % eras.length]
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

async function loadCurrentUser() {
  currentUser.value = await apiRequest<CurrentUserPayload>('/api/auth/me', { method: 'GET' })
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

  selectedRelicId.value = relicItems.value[0].id
  await loadRelicDetail(relicItems.value[0].id)
}

async function loadRelicDetail(id: number) {
  selectedRelic.value = await apiRequest<RelicDetail>(`/api/relic-objects/${id}`, { method: 'GET' })
  syncRelicForm(selectedRelic.value)
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

  selectedBatchId.value = receiveBatches.value[0].id
  await loadReceiveBatchDetail(receiveBatches.value[0].id)
}

async function loadReceiveBatchDetail(id: number) {
  selectedBatch.value = await apiRequest<ReceiveBatchDetail>(`/api/receive-batches/${id}`, {
    method: 'GET',
  })
  syncBatchForm(selectedBatch.value)
}

async function loadWorkspaceData() {
  dashboardLoading.value = true
  pageError.value = ''

  try {
    await Promise.all([loadCurrentUser(), loadDicts(), loadRelics(), loadReceiveBatches()])
    connectionState.value = 'online'
  } catch (error) {
    pageError.value = error instanceof Error ? error.message : '页面加载失败'
    connectionState.value = 'offline'
    throw error
  } finally {
    dashboardLoading.value = false
  }
}

async function restoreSession() {
  const token = localStorage.getItem('four-survey-token')
  if (!token) {
    connectionState.value = 'online'
    return
  }

  try {
    await loadWorkspaceData()
  } catch {
    localStorage.removeItem('four-survey-token')
    currentUser.value = null
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
    loginError.value = error instanceof Error ? error.message : '登录失败'
  } finally {
    loginLoading.value = false
  }
}

function logout() {
  localStorage.removeItem('four-survey-token')
  currentUser.value = null
  relicItems.value = []
  receiveBatches.value = []
  selectedRelicId.value = null
  selectedRelic.value = null
  selectedBatchId.value = null
  selectedBatch.value = null
  pageMode.value = 'list'
}

function defaultMenuLabel(menuKey: MenuKey) {
  return menuLabelMap[menuKey] ?? '首页'
}

function isShellGroupExpanded(groupId: string, keys: MenuKey[]) {
  return expandedShellGroups.value.includes(groupId) || keys.includes(selectedMenu.value)
}

function toggleShellGroup(groupId: string) {
  if (expandedShellGroups.value.includes(groupId)) {
    expandedShellGroups.value = expandedShellGroups.value.filter((item) => item !== groupId)
    return
  }
  expandedShellGroups.value = [...expandedShellGroups.value, groupId]
}

function selectMenu(menuKey: MenuKey, label?: string) {
  selectedMenu.value = menuKey
  activePageLabel.value = label ?? defaultMenuLabel(menuKey)
  pageMode.value = 'list'
  selectedDetailSection.value = 'cover'
  actionMessage.value = ''
  relicMessage.value = ''
  relicError.value = ''
  batchMessage.value = ''
  batchError.value = ''
}

function openRelicDetail(id: number) {
  selectedRelicId.value = id
  pageMode.value = 'detail'
  selectedDetailSection.value = 'cover'
  relicMessage.value = ''
  relicError.value = ''
  void loadRelicDetail(id)
}

function closeDetail() {
  pageMode.value = 'list'
}

function selectDetailSection(sectionKey: DetailSectionKey) {
  selectedDetailSection.value = sectionKey
}

function goPrevSection() {
  const keys = detailNavNodes.flatMap((item) =>
    item.kind === 'single' ? [item.key] : item.children.map((child) => child.key),
  )
  const currentIndex = keys.findIndex((key) => key === selectedDetailSection.value)
  if (currentIndex > 0) {
    selectedDetailSection.value = keys[currentIndex - 1]
  }
}

function goNextSection() {
  const keys = detailNavNodes.flatMap((item) =>
    item.kind === 'single' ? [item.key] : item.children.map((child) => child.key),
  )
  const currentIndex = keys.findIndex((key) => key === selectedDetailSection.value)
  if (currentIndex >= 0 && currentIndex < keys.length - 1) {
    selectedDetailSection.value = keys[currentIndex + 1]
  }
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
    relicMessage.value = '登记表已保存'
  } catch (error) {
    relicError.value = error instanceof Error ? error.message : '保存失败'
  } finally {
    savingRelic.value = false
  }
}

function resetRelicForm() {
  syncRelicForm(selectedRelic.value)
  relicError.value = ''
  relicMessage.value = '已恢复为当前详情内容'
}

async function selectBatch(id: number) {
  selectedBatchId.value = id
  batchMessage.value = ''
  batchError.value = ''
  await loadReceiveBatchDetail(id)
}

async function processBatch(action: ReceiveBatchProcessPayload['action']) {
  if (!selectedBatchId.value) return

  processingBatch.value = true
  batchMessage.value = ''
  batchError.value = ''

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
    batchError.value = error instanceof Error ? error.message : '处理失败'
  } finally {
    processingBatch.value = false
  }
}

function handleToolbarAction(button: ToolbarButton) {
  actionMessage.value = ''

  if ((selectedMenu.value === 'data-init' || selectedMenu.value === 'survey') && button.label === '修改' && selectedRelicId.value) {
    openRelicDetail(selectedRelicId.value)
    return
  }

  if (selectedMenu.value === 'survey' && button.label === '新增') {
    pageMode.value = 'detail'
    selectedDetailSection.value = 'cover'
    actionMessage.value = '当前先复用已有详情页，下一步再补新增登记流程。'
    return
  }

  if (selectedMenu.value === 'receive' && button.label === '接收移动端') {
    actionMessage.value = '接收入口下一步接文件上传和数据包解析。'
    return
  }

  actionMessage.value = `${button.label} 功能下一步继续接入。`
}

function isGroupActive(keys: DetailSectionKey[]) {
  return keys.includes(selectedDetailSection.value)
}

function buildPhotoThumb(index: number, title: string) {
  const palettes = [
    ['#8ea67e', '#d7c9a5'],
    ['#6f8d5e', '#e6d7b7'],
    ['#7b8a96', '#d9dfe4'],
    ['#9b7e62', '#eadbc7'],
  ]
  const pair = palettes[index % palettes.length]
  const svg = `
    <svg xmlns="http://www.w3.org/2000/svg" width="92" height="64" viewBox="0 0 92 64">
      <defs>
        <linearGradient id="g" x1="0" x2="1" y1="0" y2="1">
          <stop offset="0%" stop-color="${pair[0]}"/>
          <stop offset="100%" stop-color="${pair[1]}"/>
        </linearGradient>
      </defs>
      <rect width="92" height="64" fill="url(#g)"/>
      <rect x="0" y="42" width="92" height="22" fill="rgba(255,255,255,0.18)"/>
      <rect x="12" y="18" width="26" height="18" fill="rgba(255,255,255,0.45)"/>
      <path d="M44 40l10-12 9 8 8-12 9 16z" fill="rgba(255,255,255,0.48)"/>
      <text x="6" y="58" font-family="Microsoft YaHei, Arial" font-size="9" fill="#ffffff">${title.slice(0, 8)}</text>
    </svg>
  `
  return `data:image/svg+xml;charset=UTF-8,${encodeURIComponent(svg)}`
}

function decimalToDms(value: number) {
  const absolute = Math.abs(value)
  const degree = Math.floor(absolute)
  const minuteFloat = (absolute - degree) * 60
  const minute = Math.floor(minuteFloat)
  const second = ((minuteFloat - minute) * 60).toFixed(4)
  return `${degree}°${minute}'${second}"`
}

function createBoundaryRows(detail: RelicDetail | null): BoundaryRow[] {
  if (!detail) return []

  const baseLongitude = detail.points[0]?.longitude ?? 116.375255
  const baseLatitude = detail.points[0]?.latitude ?? 35.31615
  const altitude = detail.points[0]?.altitude ?? 29.49
  const offsets = [
    [0.00007, -0.00008],
    [0.000071, -0.000035],
    [0.000095, 0.000025],
    [0.000118, 0.00008],
    [0.000142, 0.00012],
    [0.00006, 0.000162],
    [0.000012, 0.00009],
    [-0.000004, 0.00002],
    [-0.000025, -0.00004],
    [-0.000048, -0.00008],
  ]
  const noteTexts = [
    '桥引西北角',
    '桥身西北角',
    '桥身北侧点',
    '桥身东北角',
    '桥引东北角',
    '桥引东南角',
    '桥身东南角',
    '桥身南侧点',
    '桥身西南角',
    '桥引西南角',
  ]

  return offsets.map(([latOffset, lngOffset], index) => ({
    order: index + 1,
    groupName: '',
    pointType: '边界点',
    latitudeText: decimalToDms(baseLatitude + latOffset),
    longitudeText: decimalToDms(baseLongitude + lngOffset),
    altitudeText: `${altitude.toFixed(2)}米`,
    noteText: noteTexts[index],
    remarkText: index === 0 ? '示例点位说明' : '无',
  }))
}

const bodyRows = computed(() => {
  if (!selectedRelic.value) return []
  return [
    {
      order: 1,
      groupName: '',
      name: selectedRelic.value.objectName,
      categoryName: '建构筑物',
      areaText: '126.48平方米',
    },
  ]
})

const attachmentRows = computed<AttachmentRow[]>(() => {
  const name = selectedRelic.value?.objectName || '示例文物点'
  return [
    {
      order: 1,
      groupName: '附属构件',
      name: `${name}附属碑刻`,
      categoryName: '石刻构件',
      areaText: '4.20平方米',
    },
    {
      order: 2,
      groupName: '附属构件',
      name: `${name}栏板`,
      categoryName: '建构筑物',
      areaText: '12.60平方米',
    },
  ]
})

const boundaryRows = computed(() => createBoundaryRows(selectedRelic.value))

const clueRows = computed<RelationRow[]>(() => [
  {
    order: 1,
    code: 'XS-2026-001',
    name: '示例线索点一',
    categoryName: '古建筑',
    addressText: '示例区域二',
    noteText: '与本点位空间位置相近，来源于线索库。',
  },
  {
    order: 2,
    code: 'XS-2026-009',
    name: '示例线索点二',
    categoryName: '石窟寺及石刻',
    addressText: '示例区域一',
    noteText: '作为关联比对对象保留。',
  },
])

const topicRows = computed<RelationRow[]>(() => [
  {
    order: 1,
    code: 'ZT-2026-003',
    name: '示例专题文物点一',
    categoryName: '桥涵码头',
    addressText: '示例区域二',
    noteText: '纳入桥梁专题名录。',
  },
  {
    order: 2,
    code: 'ZT-2026-008',
    name: '示例专题文物点二',
    categoryName: '交通遗产',
    addressText: '示例区域三',
    noteText: '用于专题关联展示。',
  },
])

const photoRows = computed<PhotoRow[]>(() => {
  const name = selectedRelic.value?.objectName || '示例文物点'
  return [
    {
      order: 1,
      thumb: buildPhotoThumb(0, name),
      relatedType: '本体文物',
      name,
      code: 'Z00001',
      photoNo: 'Z001',
      filmNo: '',
      photographer: '采集员',
      shotAt: '2025.04.11',
      direction: '由东向西',
      note: '示例照片说明一',
    },
    {
      order: 2,
      thumb: buildPhotoThumb(1, `${name}桥身`),
      relatedType: '文物构成-本体文物',
      name: `${name}桥身`,
      code: 'Z00002',
      photoNo: 'Z002',
      filmNo: '',
      photographer: '采集员',
      shotAt: '2025.04.11',
      direction: '由东北向西南',
      note: '示例照片说明二',
    },
    {
      order: 3,
      thumb: buildPhotoThumb(2, `${name}桥面`),
      relatedType: '年代',
      name: `${name}桥面`,
      code: 'Z00003',
      photoNo: 'Z003',
      filmNo: '',
      photographer: '采集员',
      shotAt: '2025.04.11',
      direction: '由东向西',
      note: '示例照片说明三',
    },
    {
      order: 4,
      thumb: buildPhotoThumb(3, `${name}桥洞`),
      relatedType: '年代',
      name: `${name}桥洞`,
      code: 'Z00004',
      photoNo: 'Z004',
      filmNo: '',
      photographer: '采集员',
      shotAt: '2025.04.11',
      direction: '由西南向东北',
      note: '示例照片说明四',
    },
    {
      order: 5,
      thumb: buildPhotoThumb(4, `${name}记石`),
      relatedType: '文物构成-附属文物',
      name: '示例附属构件',
      code: 'Z00005',
      photoNo: 'Z005',
      filmNo: '',
      photographer: '采集员',
      shotAt: '2025.04.11',
      direction: '由东向西',
      note: '示例照片说明五',
    },
  ]
})

const activeMenuLabel = computed(() => activePageLabel.value || defaultMenuLabel(selectedMenu.value))

const homeSummaryStats = computed<HomeStatItem[]>(() => [
  { label: '不可移动文物总数', value: relicItems.value.length },
  { label: '复查文物数', value: relicItems.value.filter((item) => item.sourceType === 'THIRD_CENSUS').length },
  { label: '新发现文物数', value: relicItems.value.filter((item) => item.sourceType === 'NEW_DISCOVERY').length },
  { label: '变更文物总数', value: relicItems.value.filter((item) => item.sourceType === 'CHANGE').length },
  { label: '拆分数', value: 0 },
  { label: '合并数', value: 0 },
])

const homeCategoryStats = computed<HomeStatItem[]>(() => [
  { label: '古文化遗址数', value: relicItems.value.filter((item) => item.categoryCode === 'ANCIENT_SITE').length },
  { label: '古墓葬数', value: relicItems.value.filter((item) => item.categoryCode === 'ANCIENT_TOMB').length },
  { label: '古建筑数', value: relicItems.value.filter((item) => item.categoryCode === 'ANCIENT_BUILDING').length },
  { label: '石窟寺及石刻数', value: relicItems.value.filter((item) => item.categoryCode === 'GROTTO_CARVING').length },
  { label: '近现代数', value: relicItems.value.filter((item) => item.categoryCode === 'MODERN_HISTORIC').length },
  { label: '其他', value: relicItems.value.filter((item) => !['ANCIENT_SITE', 'ANCIENT_TOMB', 'ANCIENT_BUILDING', 'GROTTO_CARVING', 'MODERN_HISTORIC'].includes(item.categoryCode)).length },
])

const homeProgressStats = computed<HomeStatItem[]>(() => [
  { label: '待普查', value: relicItems.value.filter((item) => item.surveyStatus === 'TO_DO').length },
  { label: '普查中', value: relicItems.value.filter((item) => item.surveyStatus === 'IN_PROGRESS').length },
  { label: '已普查', value: relicItems.value.filter((item) => item.surveyStatus === 'DONE').length },
  { label: '待核查', value: relicItems.value.filter((item) => item.checkStatus === 'PENDING').length },
  { label: '核查中', value: relicItems.value.filter((item) => item.checkStatus === 'IN_REVIEW').length },
  { label: '已通过', value: relicItems.value.filter((item) => item.checkStatus === 'PASSED').length },
])

const homeStatSections = computed<HomeStatSection[]>(() => [
  { title: '数量统计', items: homeSummaryStats.value },
  { title: '分类统计', items: homeCategoryStats.value },
  { title: '普查进度', items: homeProgressStats.value },
])

const detailCategoryTitle = computed(() => {
  if (!selectedRelic.value) return '古建筑'
  return formatCategory(selectedRelic.value.categoryCode)
})

const detailCode = computed(() => formatLegacyCode(selectedRelic.value?.objectCode))

const detailChangeType = computed(() => {
  if (!selectedRelic.value) return '新发现'
  if (selectedRelic.value.sourceType === 'THIRD_CENSUS') return '复查'
  if (selectedRelic.value.sourceType === 'CHANGE') return '变更类型'
  return '新发现'
})

const receiveBatchChips = computed(() =>
  receiveBatches.value.map((item) => ({
    id: item.id,
    label: `${item.batchNo} / ${item.batchName}`,
    status: formatBatchStatus(item.receiveStatus),
  })),
)

const currentList = computed<ListConfig | null>(() => {
  if (selectedMenu.value === 'data-init') {
    const rows: TableRow[] =
      selectedInitTab.value === 'third-census'
        ? relicItems.value.map((item, index) => ({
            id: item.id,
            clickable: true,
            cells: [
              { text: '', type: 'checkbox' },
              { text: index + 1 },
              { text: item.checkStatus === 'PASSED' ? '已复查' : '待复查', type: 'link' },
              { text: formatLegacyCode(item.objectCode) },
              { text: item.objectName, type: 'link' },
              { text: formatCategory(item.categoryCode) },
              { text: '尚未核定为保护单位' },
              { text: item.addressText || '-' },
              { text: mockEraById(item.id) },
            ],
          }))
        : []

    return {
      tabs: [
        { key: 'third-census', label: '三普文物信息库' },
        { key: 'protect-unit', label: '文保单位信息库' },
        { key: 'clue', label: '线索库' },
        { key: 'topic', label: '专题文物' },
        { key: 'map-init', label: '地图离线数据初始化' },
      ],
      activeTab: selectedInitTab.value,
      buttons: [
        { key: 'import', label: '批量导入', variant: 'primary' },
        { key: 'export-package', label: '导出三普数据包', variant: 'primary' },
        { key: 'delete', label: '删除', variant: 'danger' },
        { key: 'export-excel', label: '导出Excel', variant: 'primary' },
      ],
      headers: [' ', '序号', '是否复查', '编号', '名称', '类别', '文物级别', '地址', '年代'],
      rows,
      supportsSearch: true,
      searchPlaceholder: '编号,名称',
    }
  }

  if (selectedMenu.value === 'survey') {
    const rows: TableRow[] =
      selectedSurveyTab.value === 'collect'
        ? relicItems.value.map((item, index) => ({
            id: item.id,
            clickable: true,
            cells: [
              { text: '', type: 'checkbox' },
              { text: index + 1 },
              { text: formatSurveyStatus(item.surveyStatus) },
              { text: formatSource(item.sourceType) },
              { text: formatLegacyCode(item.objectCode) },
              { text: item.objectName, type: 'link' },
              { text: formatCategory(item.categoryCode) },
              { text: '尚未核定为保护单位' },
              { text: item.addressText || '-' },
              { text: mockEraById(item.id) },
              { text: index + 1 },
            ],
          }))
        : []

    return {
      tabs: [
        { key: 'collect', label: '普查数据采集' },
        { key: 'recycle', label: '回收站' },
      ],
      activeTab: selectedSurveyTab.value,
      buttons: [
        { key: 'create', label: '新增', variant: 'primary' },
        { key: 'edit', label: '修改', variant: 'primary' },
        { key: 'delete', label: '删除', variant: 'danger' },
        { key: 'review', label: '转现场复核', variant: 'primary' },
        { key: 'cancel-review', label: '撤销现场复核', variant: 'primary' },
        { key: 'submit-check', label: '提交质量核查', variant: 'primary' },
        { key: 'system-check', label: '系统核查', variant: 'primary' },
        { key: 'return-note', label: '退回意见', variant: 'primary' },
        { key: 'import-export', label: '导入导出', variant: 'primary' },
      ],
      headers: [' ', '序号', '状态', '调查类型', '编号', '名称', '类别', '文物级别', '地址', '年代', '下载次数'],
      rows,
      supportsSearch: true,
      searchPlaceholder: '编号,名称',
    }
  }

  if (selectedMenu.value === 'receive') {
    const records = selectedReceiveTab.value === 'immovable' ? selectedBatch.value?.records ?? [] : []
    return {
      tabs: [
        { key: 'immovable', label: '不可移动文物' },
        { key: 'change', label: '变更文物登记表' },
        { key: 'multi', label: '单处文物多端采集管理' },
      ],
      activeTab: selectedReceiveTab.value,
      buttons: [
        { key: 'receive-mobile', label: '接收移动端', variant: 'primary' },
        { key: 'upload-offline', label: '离线数据上传', variant: 'primary' },
        { key: 'export-excel', label: '导出Excel', variant: 'primary' },
      ],
      headers: [' ', '序号', '状态', '调查类型', '编号', '名称', '类别', '地址', '操作人', '操作时间'],
      rows: records.map((record, index) => ({
        id: record.id,
        cells: [
          { text: '', type: 'checkbox' },
          { text: index + 1 },
          { text: formatBatchStatus(record.receiveStatus) },
          { text: formatSource(record.surveyType) },
          { text: record.recordNo },
          { text: record.objectName, type: 'link' },
          { text: formatCategory(record.categoryCode) },
          { text: record.addressText || '-' },
          { text: record.operatorName || '-' },
          { text: formatDateTime(record.operatedAt) },
        ],
      })),
      supportsSearch: true,
      searchPlaceholder: '编号,名称',
    }
  }

  return null
})

const showListPage = computed(() => pageMode.value === 'list' && currentList.value !== null)
const showHomePage = computed(() => pageMode.value === 'list' && selectedMenu.value === 'home')
const showPlaceholderPage = computed(
  () => pageMode.value === 'list' && selectedMenu.value !== 'home' && currentList.value === null,
)

const canPrevSection = computed(() => {
  const keys = detailNavNodes.flatMap((item) =>
    item.kind === 'single' ? [item.key] : item.children.map((child) => child.key),
  )
  return keys.findIndex((key) => key === selectedDetailSection.value) > 0
})

const canNextSection = computed(() => {
  const keys = detailNavNodes.flatMap((item) =>
    item.kind === 'single' ? [item.key] : item.children.map((child) => child.key),
  )
  return keys.findIndex((key) => key === selectedDetailSection.value) < keys.length - 1
})

onMounted(async () => {
  await restoreSession()
})
</script>

<template>
  <div class="app-shell">
    <template v-if="isAuthenticated">
      <header class="top-shell">
        <div class="top-shell__brand">
          <div class="top-shell__logo">FS</div>
          <div class="top-shell__titles">
            <h1>第四次全国文物普查数据采集软件</h1>
          </div>
        </div>

        <div class="top-shell__right">
          <div class="top-shell__meta">
            <span>普查地区：{{ currentUser?.orgName || '示例普查区域' }}</span>
            <strong>{{ currentUser?.displayName || '当前用户' }}</strong>
            <span class="top-shell__avatar">{{ (currentUser?.displayName || '用').slice(0, 1) }}</span>
          </div>
          <div class="top-shell__tools">
            <button
              v-for="tool in topTools"
              :key="tool.key"
              type="button"
              class="top-shell__tool"
              :class="`top-shell__tool--${tool.icon}`"
              :title="tool.title"
            ></button>
            <button type="button" class="top-shell__logout" @click="logout" title="退出登录"></button>
          </div>
        </div>
      </header>

      <div class="workspace-shell">
        <aside class="side-shell">
          <div class="side-shell__collapse">
            <span></span>
          </div>

          <nav class="side-shell__menu">
            <template v-for="node in shellNavNodes" :key="node.kind === 'item' ? node.key : node.id">
              <button
                v-if="node.kind === 'item'"
                type="button"
                class="side-shell__menu-item"
                :class="{ 'is-active': selectedMenu === node.key && activeMenuLabel === node.label }"
                @click="selectMenu(node.key, node.label)"
              >
                <span class="side-shell__icon" :data-icon="node.icon"></span>
                <span>{{ node.label }}</span>
              </button>

              <div
                v-else
                class="side-nav-group"
                :class="{ 'is-open': isShellGroupExpanded(node.id, node.children.map((child) => child.key)) }"
              >
                <button type="button" class="side-nav-group__title" @click="toggleShellGroup(node.id)">
                  <span class="side-shell__icon" :data-icon="node.icon"></span>
                  <span>{{ node.label }}</span>
                  <span class="side-nav-group__arrow"></span>
                </button>
                <div class="side-nav-group__children">
                  <button
                    v-for="child in node.children"
                    :key="child.id"
                    type="button"
                    class="side-nav-child"
                    :class="{ 'is-active': selectedMenu === child.key && activeMenuLabel === child.label }"
                    @click="selectMenu(child.key, child.label)"
                  >
                    <span class="side-nav-child__dot"></span>
                    <span>{{ child.label }}</span>
                  </button>
                </div>
              </div>
            </template>
          </nav>
        </aside>

        <main class="content-shell">
          <div class="page-crumb">
            <span class="page-crumb__home"></span>
            <span>{{ activeMenuLabel }}</span>
          </div>

          <section v-if="showHomePage" class="home-shell">
            <div class="home-grid">
              <section class="home-panel home-panel--flow">
                <div class="home-panel__title">流程导航</div>
                <div class="home-flow">
                  <button
                    v-for="step in homeFlowSteps"
                    :key="step.key"
                    type="button"
                    class="home-flow__item"
                    @click="selectMenu(step.key, menuLabelMap[step.key])"
                  >
                    <span class="home-flow__icon"></span>
                    <span class="home-flow__label">{{ step.label }}</span>
                    <span class="home-flow__caption">{{ step.caption }}</span>
                  </button>
                </div>
              </section>

              <aside class="home-stats">
                <section v-for="section in homeStatSections" :key="section.title" class="home-panel home-panel--stats">
                  <div class="home-panel__title">{{ section.title }}</div>
                  <div class="home-stat-grid">
                    <div v-for="item in section.items" :key="item.label" class="home-stat-card">
                      <div class="home-stat-card__label">{{ item.label }}</div>
                      <div class="home-stat-card__value">{{ item.value }}</div>
                    </div>
                  </div>
                </section>
              </aside>
            </div>

            <section class="home-panel home-panel--support">
              <div class="home-panel__title">技术支持</div>
              <div class="home-support">
                <button v-for="item in homeSupportLinks" :key="item" type="button" class="home-support__item">
                  <span class="home-support__icon"></span>
                  <span>{{ item }}</span>
                </button>
              </div>
            </section>
          </section>

          <section v-else-if="showListPage" class="page-card">
            <div class="page-tabs">
              <button
                v-for="tab in currentList?.tabs"
                :key="tab.key"
                type="button"
                class="page-tabs__item"
                :class="{ 'is-active': currentList?.activeTab === tab.key }"
                @click="
                  selectedMenu === 'data-init'
                    ? (selectedInitTab = tab.key)
                    : selectedMenu === 'survey'
                      ? (selectedSurveyTab = tab.key)
                      : (selectedReceiveTab = tab.key)
                "
              >
                {{ tab.label }}
              </button>
            </div>

            <div class="page-toolbar">
              <div class="page-toolbar__buttons">
                <button
                  v-for="button in currentList?.buttons"
                  :key="button.key"
                  type="button"
                  class="toolbar-button"
                  :class="button.variant || 'primary'"
                  @click="handleToolbarAction(button)"
                >
                  {{ button.label }}
                </button>
              </div>

              <div v-if="currentList?.supportsSearch" class="page-toolbar__search">
                <input
                  v-model.trim="relicKeyword"
                  type="text"
                  :placeholder="currentList?.searchPlaceholder || '编号,名称'"
                  @keyup.enter="loadRelics"
                />
                <button type="button" class="toolbar-button primary" @click="loadRelics">查询</button>
                <button type="button" class="toolbar-button ghost">更多条件</button>
                <button type="button" class="filter-button" title="筛选"></button>
              </div>
            </div>

            <div v-if="selectedMenu === 'receive'" class="batch-strip">
              <div class="batch-strip__chips">
                <button
                  v-for="batch in receiveBatchChips"
                  :key="batch.id"
                  type="button"
                  class="batch-chip"
                  :class="{ 'is-active': batch.id === selectedBatchId }"
                  @click="selectBatch(batch.id)"
                >
                  <strong>{{ batch.label }}</strong>
                  <span>{{ batch.status }}</span>
                </button>
              </div>

              <div class="batch-strip__actions">
                <textarea v-model.trim="batchActionForm.remark" rows="2" placeholder="处理备注"></textarea>
                <div class="batch-strip__action-buttons">
                  <button class="toolbar-button primary" type="button" @click="processBatch('START_REVIEW')" :disabled="processingBatch">
                    转处理中
                  </button>
                  <button class="toolbar-button primary" type="button" @click="processBatch('COMPLETE')" :disabled="processingBatch">
                    标记完成
                  </button>
                  <button class="toolbar-button ghost" type="button" @click="processBatch('RESET')" :disabled="processingBatch">
                    重置
                  </button>
                </div>
              </div>
            </div>

            <div class="list-table-shell">
              <table class="list-table">
                <thead>
                  <tr>
                    <th v-for="header in currentList?.headers" :key="header">{{ header }}</th>
                  </tr>
                </thead>
                <tbody>
                  <tr
                    v-for="row in currentList?.rows"
                    :key="row.id"
                    :class="{ 'is-clickable': row.clickable }"
                    @click="row.clickable ? openRelicDetail(row.id) : undefined"
                  >
                    <td v-for="(cell, index) in row.cells" :key="`${row.id}-${index}`">
                      <span v-if="cell.type === 'checkbox'" class="table-checkbox"></span>
                      <span v-else-if="cell.type === 'link'" class="table-link">{{ cell.text }}</span>
                      <span v-else-if="cell.type === 'muted'" class="table-muted">{{ cell.text }}</span>
                      <span v-else>{{ cell.text }}</span>
                    </td>
                  </tr>

                  <tr v-if="!currentList?.rows.length">
                    <td :colspan="currentList?.headers.length || 1">
                      <div class="table-empty">
                        <div class="table-empty__icon"></div>
                        <p>暂无数据</p>
                      </div>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>

            <div class="page-card__footer">
              <span class="page-card__count">共 {{ currentList?.rows.length || 0 }} 条</span>
              <div class="pager">
                <button type="button">上一页</button>
                <button type="button" class="is-active">1</button>
                <button type="button">2</button>
                <button type="button">下一页</button>
                <span>10 条/页</span>
              </div>
            </div>

            <p v-if="actionMessage" class="page-message">{{ actionMessage }}</p>
            <p v-if="batchMessage" class="page-message page-message--success">{{ batchMessage }}</p>
            <p v-if="batchError" class="page-message page-message--error">{{ batchError }}</p>
          </section>

          <section v-else-if="showPlaceholderPage" class="page-card page-card--placeholder">
            <div class="placeholder-state">
              <h2>{{ activeMenuLabel }}</h2>
              <p>这个模块下一步继续按原版界面往下补，现在先把列表和登记表主链路做准。</p>
            </div>
          </section>

          <section v-else-if="selectedRelic" class="detail-shell">
            <aside class="detail-shell__nav">
              <template v-for="node in detailNavNodes" :key="node.kind === 'single' ? node.key : node.label">
                <button
                  v-if="node.kind === 'single'"
                  type="button"
                  class="detail-nav-single"
                  :class="{ 'is-active': selectedDetailSection === node.key }"
                  @click="selectDetailSection(node.key)"
                >
                  <span class="detail-nav-single__icon"></span>
                  <span>{{ node.label }}</span>
                </button>

                <div
                  v-else
                  class="detail-nav-group"
                  :class="{ 'is-active': isGroupActive(node.children.map((child) => child.key)) }"
                >
                  <div class="detail-nav-group__title">
                    <span class="detail-nav-group__icon"></span>
                    <span>{{ node.label }}</span>
                  </div>
                  <div class="detail-nav-group__children">
                    <button
                      v-for="child in node.children"
                      :key="child.key"
                      type="button"
                      class="detail-nav-child"
                      :class="{ 'is-active': selectedDetailSection === child.key }"
                      @click="selectDetailSection(child.key)"
                    >
                      <span class="detail-nav-child__dot"></span>
                      <span>{{ child.label }}</span>
                    </button>
                  </div>
                </div>
              </template>
            </aside>

            <section class="detail-shell__main">
              <div class="detail-shell__top">
                <button type="button" class="detail-close" @click="closeDetail">关闭</button>
              </div>

              <div v-if="selectedDetailSection === 'cover'" class="sheet-cover">
                <div class="sheet-cover__code">编号：{{ detailCode }}</div>

                <div class="sheet-choice-row">
                  <span
                    v-for="option in ['新发现', '复查', '合并', '拆分', '变更类型', '无变更']"
                    :key="option"
                    class="choice-option"
                    :class="{ 'is-checked': option === detailChangeType }"
                  >
                    <span class="choice-option__dot"></span>
                    {{ option }}
                  </span>
                </div>

                <h2>第四次全国文物普查不可移动文物登记表</h2>
                <h3>{{ detailCategoryTitle }}</h3>

                <div class="sheet-cover__fields">
                  <div class="sheet-cover__field wide">
                    <label>*名称</label>
                    <span>{{ selectedRelic.objectName }}</span>
                  </div>
                  <div class="sheet-cover__field">
                    <label>*省（自治区、直辖市）</label>
                    <span>示例省</span>
                  </div>
                  <div class="sheet-cover__field">
                    <label>*市（地区、州、盟）</label>
                    <span>示例市</span>
                  </div>
                  <div class="sheet-cover__field">
                    <label>*县（区、市、旗）</label>
                    <span>示例县</span>
                  </div>
                  <div class="sheet-cover__field wide">
                    <label>*调查人（签字）</label>
                    <span>调查员甲、调查员乙、调查员丙</span>
                  </div>
                  <div class="sheet-cover__field">
                    <label>*日期</label>
                    <span>2026.04.11</span>
                  </div>
                  <div class="sheet-cover__field">
                    <label>审定人（签字）</label>
                    <span>-</span>
                  </div>
                  <div class="sheet-cover__field">
                    <label>日期</label>
                    <span>-</span>
                  </div>
                  <div class="sheet-cover__field">
                    <label>抽查人（签字）</label>
                    <span>-</span>
                  </div>
                  <div class="sheet-cover__field">
                    <label>日期</label>
                    <span>-</span>
                  </div>
                </div>

                <div class="sheet-cover__footer">第四次全国文物普查领导小组办公室 制</div>
              </div>

              <div v-else-if="selectedDetailSection === 'basic'" class="sheet-panel">
                <h2>第四次全国文物普查不可移动文物登记表（{{ detailCategoryTitle }}）</h2>

                <table class="sheet-table">
                  <tbody>
                    <tr>
                      <th>*名称</th>
                      <td>{{ selectedRelic.objectName }}</td>
                      <th>代码</th>
                      <td>{{ detailCode }}</td>
                    </tr>
                    <tr>
                      <th>地址及位置</th>
                      <td colspan="3">{{ selectedRelic.addressText || '示例地址信息' }}</td>
                    </tr>
                    <tr>
                      <th>迁移情况</th>
                      <td colspan="3">
                        <div class="choice-inline">
                          <span class="choice-option">
                            <span class="choice-option__dot"></span>是
                          </span>
                          <span class="choice-option is-checked">
                            <span class="choice-option__dot"></span>否
                          </span>
                        </div>
                      </td>
                    </tr>
                    <tr>
                      <th>面积（平方米）</th>
                      <td>126.48</td>
                      <th>文物级别</th>
                      <td>未认定</td>
                    </tr>
                    <tr>
                      <th>所属文物保护单位名称</th>
                      <td colspan="3">-</td>
                    </tr>
                    <tr>
                      <th>是否已公布保护范围</th>
                      <td>
                        <div class="choice-inline">
                          <span class="choice-option"><span class="choice-option__dot"></span>是</span>
                          <span class="choice-option is-checked"><span class="choice-option__dot"></span>否</span>
                        </div>
                      </td>
                      <th>是否已公布建设控制地带</th>
                      <td>
                        <div class="choice-inline">
                          <span class="choice-option"><span class="choice-option__dot"></span>是</span>
                          <span class="choice-option is-checked"><span class="choice-option__dot"></span>否</span>
                        </div>
                      </td>
                    </tr>
                    <tr>
                      <th>年代</th>
                      <td>{{ selectedRelic.eraText || '明' }}</td>
                      <th>统计年代</th>
                      <td>
                        <div class="choice-inline wrap">
                          <span class="choice-pill">夏商周（含春秋）</span>
                          <span class="choice-pill">战国秦汉</span>
                          <span class="choice-pill">三国两晋南北朝</span>
                          <span class="choice-pill">隋唐五代十国</span>
                          <span class="choice-pill">宋辽西夏金元</span>
                          <span class="choice-pill is-checked">明代</span>
                          <span class="choice-pill">清代</span>
                          <span class="choice-pill">不详</span>
                        </div>
                      </td>
                    </tr>
                    <tr>
                      <th>类别</th>
                      <td colspan="3">
                        <div class="choice-block">
                          <div class="choice-inline wrap">
                            <span class="choice-pill">古文化遗址</span>
                            <span class="choice-pill">古墓葬</span>
                            <span class="choice-pill is-checked">古建筑</span>
                            <span class="choice-pill">石窟寺及石刻</span>
                            <span class="choice-pill">近现代重要史迹及代表性建筑</span>
                            <span class="choice-pill">其他</span>
                          </div>
                          <div class="choice-inline wrap">
                            <span class="choice-pill">城垣城楼</span>
                            <span class="choice-pill">官殿府邸</span>
                            <span class="choice-pill">宅第民居</span>
                            <span class="choice-pill">坛庙祠堂</span>
                            <span class="choice-pill">牌坊影壁</span>
                            <span class="choice-pill">台榭楼阁</span>
                            <span class="choice-pill">寺观塔阁</span>
                            <span class="choice-pill is-checked">桥涵码头</span>
                            <span class="choice-pill">堤坝渠堰</span>
                            <span class="choice-pill">池塘井泉</span>
                          </div>
                        </div>
                      </td>
                    </tr>
                    <tr>
                      <th>所有权</th>
                      <td>
                        <div class="choice-inline">
                          <span class="choice-pill">国家所有</span>
                          <span class="choice-pill is-checked">集体所有</span>
                          <span class="choice-pill">私人所有</span>
                        </div>
                      </td>
                      <th>产权单位（人）</th>
                      <td>示例产权单位</td>
                    </tr>
                    <tr>
                      <th>使用单位（人）</th>
                      <td>示例使用单位</td>
                      <th>上级管理机构</th>
                      <td>示例管理机构</td>
                    </tr>
                    <tr>
                      <th>所属行业、系统</th>
                      <td>
                        <div class="choice-inline">
                          <span class="choice-pill is-checked">文化</span>
                          <span class="choice-pill">军队</span>
                          <span class="choice-pill">教育</span>
                          <span class="choice-pill">宗教</span>
                          <span class="choice-pill">农业</span>
                          <span class="choice-pill">工业</span>
                          <span class="choice-pill">商业</span>
                          <span class="choice-pill">其他</span>
                        </div>
                      </td>
                      <th>开放状况</th>
                      <td>
                        <div class="choice-inline">
                          <span class="choice-option is-checked"><span class="choice-option__dot"></span>开放</span>
                          <span class="choice-option"><span class="choice-option__dot"></span>未开放</span>
                        </div>
                      </td>
                    </tr>
                  </tbody>
                </table>

                <div class="edit-panel">
                  <div class="edit-panel__title">当前重建版可编辑字段</div>
                  <div class="edit-grid">
                    <label class="edit-field wide">
                      <span>名称</span>
                      <input v-model.trim="relicForm.objectName" type="text" />
                    </label>
                    <label class="edit-field">
                      <span>类别</span>
                      <select v-model="relicForm.categoryCode">
                        <option value="">请选择</option>
                        <option v-for="item in relicCategoryItems" :key="item.id" :value="item.itemCode">
                          {{ item.itemName }}
                        </option>
                      </select>
                    </label>
                    <label class="edit-field">
                      <span>年代</span>
                      <input v-model.trim="relicForm.eraText" type="text" />
                    </label>
                    <label class="edit-field">
                      <span>普查状态</span>
                      <select v-model="relicForm.surveyStatus">
                        <option value="">请选择</option>
                        <option v-for="item in surveyStatusItems" :key="item.id" :value="item.itemCode">
                          {{ item.itemName }}
                        </option>
                      </select>
                    </label>
                    <label class="edit-field">
                      <span>核查状态</span>
                      <select v-model="relicForm.checkStatus">
                        <option value="">请选择</option>
                        <option v-for="item in checkStatusItems" :key="item.id" :value="item.itemCode">
                          {{ item.itemName }}
                        </option>
                      </select>
                    </label>
                    <label class="edit-field wide">
                      <span>地址</span>
                      <input v-model.trim="relicForm.addressText" type="text" />
                    </label>
                    <label class="edit-field wide">
                      <span>现状用途</span>
                      <input v-model.trim="relicForm.currentUse" type="text" />
                    </label>
                    <label class="edit-field wide">
                      <span>简介</span>
                      <textarea v-model.trim="relicForm.abstractText" rows="3"></textarea>
                    </label>
                    <label class="edit-field">
                      <span>保护范围</span>
                      <textarea v-model.trim="relicForm.protectionScope" rows="3"></textarea>
                    </label>
                    <label class="edit-field">
                      <span>建设控制地带</span>
                      <textarea v-model.trim="relicForm.constructionControl" rows="3"></textarea>
                    </label>
                  </div>

                  <div class="edit-actions">
                    <button class="toolbar-button primary" type="button" @click="saveRelic" :disabled="savingRelic">
                      {{ savingRelic ? '正在保存...' : '保存' }}
                    </button>
                    <button class="toolbar-button ghost" type="button" @click="resetRelicForm">还原</button>
                    <span>填报开始：{{ formatDateTime(selectedRelic.fillStartedAt) }}</span>
                  </div>

                  <p v-if="relicMessage" class="page-message page-message--success">{{ relicMessage }}</p>
                  <p v-if="relicError" class="page-message page-message--error">{{ relicError }}</p>
                </div>
              </div>

              <div v-else-if="selectedDetailSection === 'body'" class="sheet-panel sheet-panel--list">
                <table class="list-table detail-table detail-table--compact">
                  <thead>
                    <tr>
                      <th>序号</th>
                      <th>分组</th>
                      <th>名称</th>
                      <th>类别</th>
                      <th>面积</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="row in bodyRows" :key="row.order">
                      <td>{{ row.order }}</td>
                      <td>{{ row.groupName }}</td>
                      <td>{{ row.name }}</td>
                      <td>{{ row.categoryName }}</td>
                      <td>{{ row.areaText }}</td>
                    </tr>
                  </tbody>
                </table>

                <div class="detail-table-footer">
                  <span>共 {{ bodyRows.length }} 条</span>
                  <div class="pager">
                    <button type="button">上一页</button>
                    <button type="button" class="is-active">1</button>
                    <button type="button">下一页</button>
                    <span>10 条/页</span>
                  </div>
                </div>
              </div>

              <div v-else-if="selectedDetailSection === 'attachment'" class="sheet-panel sheet-panel--list">
                <table class="list-table detail-table detail-table--compact">
                  <thead>
                    <tr>
                      <th>序号</th>
                      <th>分组</th>
                      <th>名称</th>
                      <th>类别</th>
                      <th>面积</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="row in attachmentRows" :key="row.order">
                      <td>{{ row.order }}</td>
                      <td>{{ row.groupName }}</td>
                      <td>{{ row.name }}</td>
                      <td>{{ row.categoryName }}</td>
                      <td>{{ row.areaText }}</td>
                    </tr>
                  </tbody>
                </table>

                <div class="detail-table-footer">
                  <span>共 {{ attachmentRows.length }} 条</span>
                  <div class="pager">
                    <button type="button">上一页</button>
                    <button type="button" class="is-active">1</button>
                    <button type="button">下一页</button>
                    <span>10 条/页</span>
                  </div>
                </div>
              </div>

              <div v-else-if="selectedDetailSection === 'boundary'" class="sheet-panel sheet-panel--list">
                <div class="detail-table-toolbar">
                  <button type="button" class="toolbar-button primary">查看点位分布</button>
                </div>

                <table class="list-table detail-table">
                  <thead>
                    <tr>
                      <th rowspan="2">序号</th>
                      <th rowspan="2">关联分组</th>
                      <th rowspan="2">测点类型</th>
                      <th colspan="3">坐标</th>
                      <th rowspan="2">测点（边界）说明</th>
                      <th rowspan="2">备注</th>
                    </tr>
                    <tr>
                      <th>纬度</th>
                      <th>经度</th>
                      <th>海拔高程</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="row in boundaryRows" :key="row.order">
                      <td>{{ row.order }}</td>
                      <td>{{ row.groupName }}</td>
                      <td>{{ row.pointType }}</td>
                      <td>{{ row.latitudeText }}</td>
                      <td>{{ row.longitudeText }}</td>
                      <td>{{ row.altitudeText }}</td>
                      <td>{{ row.noteText }}</td>
                      <td>{{ row.remarkText }}</td>
                    </tr>
                  </tbody>
                </table>

                <div class="detail-table-footer">
                  <span>共 {{ boundaryRows.length }} 条</span>
                  <div class="pager">
                    <button type="button">上一页</button>
                    <button type="button" class="is-active">1</button>
                    <button type="button">2</button>
                    <button type="button">下一页</button>
                    <span>10 条/页</span>
                  </div>
                </div>
              </div>

              <div v-else-if="selectedDetailSection === 'clue'" class="sheet-panel sheet-panel--list">
                <table class="list-table detail-table">
                  <thead>
                    <tr>
                      <th>序号</th>
                      <th>编号</th>
                      <th>名称</th>
                      <th>类别</th>
                      <th>地址</th>
                      <th>关联说明</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="row in clueRows" :key="row.order">
                      <td>{{ row.order }}</td>
                      <td>{{ row.code }}</td>
                      <td>{{ row.name }}</td>
                      <td>{{ row.categoryName }}</td>
                      <td>{{ row.addressText }}</td>
                      <td>{{ row.noteText }}</td>
                    </tr>
                  </tbody>
                </table>

                <div class="detail-table-footer">
                  <span>共 {{ clueRows.length }} 条</span>
                  <div class="pager">
                    <button type="button">上一页</button>
                    <button type="button" class="is-active">1</button>
                    <button type="button">下一页</button>
                    <span>10 条/页</span>
                  </div>
                </div>
              </div>

              <div v-else-if="selectedDetailSection === 'topic'" class="sheet-panel sheet-panel--list">
                <table class="list-table detail-table">
                  <thead>
                    <tr>
                      <th>序号</th>
                      <th>编号</th>
                      <th>名称</th>
                      <th>类别</th>
                      <th>地址</th>
                      <th>备注</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="row in topicRows" :key="row.order">
                      <td>{{ row.order }}</td>
                      <td>{{ row.code }}</td>
                      <td>{{ row.name }}</td>
                      <td>{{ row.categoryName }}</td>
                      <td>{{ row.addressText }}</td>
                      <td>{{ row.noteText }}</td>
                    </tr>
                  </tbody>
                </table>

                <div class="detail-table-footer">
                  <span>共 {{ topicRows.length }} 条</span>
                  <div class="pager">
                    <button type="button">上一页</button>
                    <button type="button" class="is-active">1</button>
                    <button type="button">下一页</button>
                    <span>10 条/页</span>
                  </div>
                </div>
              </div>

              <div v-else-if="selectedDetailSection === 'photo'" class="sheet-panel sheet-panel--list">
                <table class="list-table detail-table">
                  <thead>
                    <tr>
                      <th>序号</th>
                      <th>照片</th>
                      <th>关联类型</th>
                      <th>名称</th>
                      <th>编号</th>
                      <th>照片号</th>
                      <th>底片号</th>
                      <th>摄影者</th>
                      <th>拍摄时间</th>
                      <th>拍摄方位</th>
                      <th>文字说明</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="photo in photoRows" :key="photo.order">
                      <td>{{ photo.order }}</td>
                      <td><img class="photo-thumb" :src="photo.thumb" :alt="photo.name" /></td>
                      <td>{{ photo.relatedType }}</td>
                      <td>{{ photo.name }}</td>
                      <td>{{ photo.code }}</td>
                      <td>{{ photo.photoNo }}</td>
                      <td>{{ photo.filmNo || '-' }}</td>
                      <td>{{ photo.photographer }}</td>
                      <td>{{ photo.shotAt }}</td>
                      <td>{{ photo.direction }}</td>
                      <td>{{ photo.note }}</td>
                    </tr>
                  </tbody>
                </table>

                <div class="detail-table-footer">
                  <span>共 {{ photoRows.length }} 条</span>
                  <div class="pager">
                    <button type="button">上一页</button>
                    <button type="button" class="is-active">1</button>
                    <button type="button">下一页</button>
                    <span>10 条/页</span>
                  </div>
                </div>
              </div>

              <div v-else class="sheet-panel sheet-panel--empty">
                <h2>{{ detailNavNodes.find((node) => node.kind === 'single' && node.key === selectedDetailSection)?.label || '页面建设中' }}</h2>
                <p>这个章节已经预留位置，下一步我会按原版登记表字段继续往下补。</p>
              </div>

              <div class="detail-shell__footer">
                <button type="button" class="toolbar-button ghost" :disabled="!canPrevSection" @click="goPrevSection">上一页</button>
                <button type="button" class="toolbar-button primary" :disabled="!canNextSection" @click="goNextSection">下一页</button>
              </div>
            </section>
          </section>

          <footer class="content-footer">技术支持单位：中国文物信息咨询中心</footer>
        </main>
      </div>
    </template>

    <template v-else>
      <main class="login-shell">
        <section class="login-banner">
          <div class="login-banner__logo">FS</div>
          <div>
            <h1>第四次全国文物普查数据采集软件</h1>
            <p>重建版前端正在按原系统界面逐步复刻。</p>
          </div>
        </section>

        <section class="login-card">
          <h2>登录</h2>

          <label class="login-field">
            <span>用户名</span>
            <input v-model.trim="loginForm.username" type="text" />
          </label>

          <label class="login-field">
            <span>密码</span>
            <input v-model="loginForm.password" type="password" />
          </label>

          <div class="login-info">
            <span>后端地址：{{ API_BASE_URL }}</span>
            <span>{{ connectionState === 'offline' ? '后端离线' : '后端可用' }}</span>
          </div>

          <p v-if="loginError" class="page-message page-message--error">{{ loginError }}</p>

          <button class="login-submit" type="button" @click="submitLogin" :disabled="loginLoading">
            {{ loginLoading ? '正在登录...' : '登录系统' }}
          </button>
        </section>
      </main>
    </template>
  </div>
</template>
