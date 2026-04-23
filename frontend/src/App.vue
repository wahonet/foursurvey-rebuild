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
  title: string
  breadcrumb: string
  tabs: { key: string; label: string }[]
  activeTab: string
  buttons: ToolbarButton[]
  headers: string[]
  rows: TableRow[]
  supportsSearch: boolean
}

const shellMenus: { key: MenuKey; label: string }[] = [
  { key: 'home', label: '首页' },
  { key: 'data-init', label: '数据初始化' },
  { key: 'mobile-download', label: '移动端下载基础数据' },
  { key: 'receive', label: '接收移动端数据' },
  { key: 'survey', label: '普查数据采集' },
  { key: 'quality', label: '数据质量核查' },
  { key: 'report', label: '报送省平台' },
  { key: 'query', label: '数据查询' },
  { key: 'basic', label: '基础数据' },
  { key: 'stats', label: '数据统计' },
  { key: 'system', label: '系统管理' },
]

const detailSections: { key: DetailSectionKey; label: string }[] = [
  { key: 'cover', label: '封面' },
  { key: 'basic', label: '基本信息' },
  { key: 'body', label: '本体文物' },
  { key: 'attachment', label: '附属文物' },
  { key: 'boundary', label: '本体边界坐标' },
  { key: 'clue', label: '关联线索库' },
  { key: 'topic', label: '关联专题文物' },
  { key: 'specimen', label: '标本登记表' },
  { key: 'other', label: '其他资料登记表' },
  { key: 'drawing', label: '图纸册页' },
  { key: 'photo', label: '照片册页' },
  { key: 'vector', label: '文物矢量图' },
]

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
const selectedMenu = ref<MenuKey>('data-init')
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
  if (!token) return

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
  selectedRelicId.value = null
  selectedRelic.value = null
  receiveBatches.value = []
  selectedBatchId.value = null
  selectedBatch.value = null
  pageMode.value = 'list'
}

function selectMenu(menuKey: MenuKey) {
  selectedMenu.value = menuKey
  pageMode.value = 'list'
  selectedDetailSection.value = 'cover'
  actionMessage.value = ''
  batchMessage.value = ''
  batchError.value = ''
}

function openRelicDetail(id: number) {
  selectedRelicId.value = id
  pageMode.value = 'detail'
  selectedDetailSection.value = 'cover'
  relicError.value = ''
  relicMessage.value = ''
  loadRelicDetail(id)
}

function closeDetail() {
  pageMode.value = 'list'
}

function selectDetailSection(sectionKey: DetailSectionKey) {
  selectedDetailSection.value = sectionKey
}

function goPrevSection() {
  const currentIndex = detailSections.findIndex((item) => item.key === selectedDetailSection.value)
  if (currentIndex > 0) {
    selectedDetailSection.value = detailSections[currentIndex - 1].key
  }
}

function goNextSection() {
  const currentIndex = detailSections.findIndex((item) => item.key === selectedDetailSection.value)
  if (currentIndex < detailSections.length - 1) {
    selectedDetailSection.value = detailSections[currentIndex + 1].key
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
    actionMessage.value = '当前先复用已有对象详情页，后续再接新增流程。'
    return
  }

  if (selectedMenu.value === 'receive' && button.label === '接收移动端' && selectedBatchId.value) {
    actionMessage.value = '接收入口先保留在当前页，后续接文件上传和包解析。'
    return
  }

  actionMessage.value = `${button.label} 功能下一步继续接入。`
}

const currentList = computed<ListConfig | null>(() => {
  if (selectedMenu.value === 'data-init') {
    return {
      title: '数据初始化',
      breadcrumb: '数据初始化',
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
      rows: relicItems.value.map((item, index) => ({
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
      })),
      supportsSearch: true,
    }
  }

  if (selectedMenu.value === 'survey') {
    return {
      title: '普查数据采集',
      breadcrumb: '普查数据采集',
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
      rows: relicItems.value.map((item, index) => ({
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
      })),
      supportsSearch: true,
    }
  }

  if (selectedMenu.value === 'receive') {
    const records = selectedBatch.value?.records ?? []
    return {
      title: '接收移动端数据',
      breadcrumb: '接收移动端数据',
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
      headers: ['序号', '状态', '调查类型', '名称', '类别', '地址', '操作人', '操作时间'],
      rows: records.map((record, index) => ({
        id: record.id,
        cells: [
          { text: index + 1 },
          { text: formatBatchStatus(record.receiveStatus) },
          { text: formatSource(record.surveyType) },
          { text: record.objectName, type: 'link' },
          { text: formatCategory(record.categoryCode) },
          { text: record.addressText || '-' },
          { text: record.operatorName || '-' },
          { text: formatDateTime(record.operatedAt) },
        ],
      })),
      supportsSearch: true,
    }
  }

  return null
})

const activeMenuLabel = computed(
  () => shellMenus.find((item) => item.key === selectedMenu.value)?.label ?? '首页',
)

const receiveBatchChips = computed(() =>
  receiveBatches.value.map((item) => ({
    id: item.id,
    label: `${item.batchNo} / ${item.batchName}`,
    status: formatBatchStatus(item.receiveStatus),
  })),
)

const detailCategoryTitle = computed(() => {
  if (!selectedRelic.value) return '古建筑'
  return formatCategory(selectedRelic.value.categoryCode)
})

const detailChangeType = computed(() => {
  if (!selectedRelic.value) return '新发现'
  if (selectedRelic.value.sourceType === 'THIRD_CENSUS') return '复查'
  if (selectedRelic.value.sourceType === 'CHANGE') return '变更类型'
  return '新发现'
})

const detailCode = computed(() => formatLegacyCode(selectedRelic.value?.objectCode))

const detailPointRows = computed(() =>
  (selectedRelic.value?.points ?? []).map((point, index) => ({
    no: index + 1,
    pointType: point.pointType,
    longitude: point.longitude,
    latitude: point.latitude,
    altitude: point.altitude ?? '-',
    coordinateSystem: point.coordinateSystem,
  })),
)

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

const photoRows = computed(() => {
  const name = selectedRelic.value?.objectName || '土山桥'
  return [
    {
      order: 1,
      thumb: buildPhotoThumb(1, name),
      relatedType: '本体文物',
      name,
      code: 'Z00001',
      photoNo: 'Z001',
      filmNo: '',
      photographer: '汪源',
      shotAt: '2025.04.11',
      direction: '由东向西',
      note: '可见近年维修牌坊与栏杆',
    },
    {
      order: 2,
      thumb: buildPhotoThumb(2, `${name}桥身`),
      relatedType: '文物构成-本体文物',
      name: `${name}桥身`,
      code: 'Z00002',
      photoNo: 'Z002',
      filmNo: '',
      photographer: '汪源',
      shotAt: '2025.04.11',
      direction: '由东北向西南',
      note: '桥身北侧近景',
    },
    {
      order: 3,
      thumb: buildPhotoThumb(3, `${name}桥面`),
      relatedType: '文物构成-本体文物',
      name: `${name}桥面`,
      code: 'Z00003',
      photoNo: 'Z003',
      filmNo: '',
      photographer: '汪源',
      shotAt: '2025.04.11',
      direction: '由东向西',
      note: '桥面纹理与栏板保存情况',
    },
    {
      order: 4,
      thumb: buildPhotoThumb(4, `${name}桥洞`),
      relatedType: '年代',
      name: `${name}桥洞`,
      code: 'Z00004',
      photoNo: 'Z004',
      filmNo: '',
      photographer: '汪源',
      shotAt: '2025.04.11',
      direction: '由西南向东北',
      note: '桥洞结构与砌筑做法',
    },
    {
      order: 5,
      thumb: buildPhotoThumb(5, `${name}记石`),
      relatedType: '文物构成-附属文物',
      name: `创修嘉祥县${name}记`,
      code: 'Z00005',
      photoNo: 'Z005',
      filmNo: '',
      photographer: '汪源',
      shotAt: '2025.04.11',
      direction: '由东向西',
      note: '碑刻可佐证创修年代',
    },
  ]
})

const showListPage = computed(
  () => pageMode.value === 'list' && currentList.value !== null,
)

const showPlaceholderPage = computed(
  () => pageMode.value === 'list' && currentList.value === null,
)

const canPrevSection = computed(
  () => detailSections.findIndex((item) => item.key === selectedDetailSection.value) > 0,
)

const canNextSection = computed(
  () =>
    detailSections.findIndex((item) => item.key === selectedDetailSection.value) <
    detailSections.length - 1,
)

onMounted(async () => {
  await restoreSession()
  if (!localStorage.getItem('four-survey-token')) {
    connectionState.value = 'online'
  }
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
            <span>普查地区：{{ currentUser?.orgName || '山东省济宁市嘉祥县' }}</span>
            <strong>{{ currentUser?.displayName || '魏萍' }}</strong>
          </div>
          <div class="top-shell__tools">
            <button v-for="index in 6" :key="index" type="button" class="top-shell__tool" :title="`工具${index}`"></button>
            <button type="button" class="top-shell__logout" @click="logout">退出</button>
          </div>
        </div>
      </header>

      <div class="workspace-shell">
        <aside class="side-shell">
          <div class="side-shell__collapse">
            <span></span>
          </div>
          <nav class="side-shell__menu">
            <button
              v-for="menu in shellMenus"
              :key="menu.key"
              type="button"
              class="side-shell__menu-item"
              :class="{ 'is-active': selectedMenu === menu.key }"
              @click="selectMenu(menu.key)"
            >
              <span class="side-shell__icon"></span>
              <span>{{ menu.label }}</span>
            </button>
          </nav>
        </aside>

        <main class="content-shell">
          <div class="page-crumb">
            <span class="page-crumb__home"></span>
            <span>{{ activeMenuLabel }}</span>
          </div>

          <section v-if="showListPage" class="page-card">
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
                  placeholder="编号,名称"
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
              <p>这个模块我会继续按原版界面往下补，现在先把列表页和登记表主链路做准。</p>
            </div>
          </section>

          <section v-else-if="selectedRelic" class="detail-shell">
            <aside class="detail-shell__nav">
              <button
                v-for="section in detailSections"
                :key="section.key"
                type="button"
                class="detail-shell__nav-item"
                :class="{ 'is-active': selectedDetailSection === section.key }"
                @click="selectDetailSection(section.key)"
              >
                <span class="detail-shell__nav-dot"></span>
                <span>{{ section.label }}</span>
              </button>
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
                    <span>山东省</span>
                  </div>
                  <div class="sheet-cover__field">
                    <label>*市（地区、州、盟）</label>
                    <span>济宁市</span>
                  </div>
                  <div class="sheet-cover__field">
                    <label>*县（区、市、旗）</label>
                    <span>嘉祥县</span>
                  </div>
                  <div class="sheet-cover__field wide">
                    <label>*调查人（签字）</label>
                    <span>魏萍、张绪华、汪源、陈玲玲、刘传玺</span>
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
                      <td colspan="3">{{ selectedRelic.addressText || '山东省济宁市嘉祥县金屯镇土山桥村村北，土山桥村后街' }}</td>
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
                      <td>土山桥村村民委员会</td>
                    </tr>
                    <tr>
                      <th>使用单位（人）</th>
                      <td>土山桥村村民委员会</td>
                      <th>上级管理机构</th>
                      <td>金屯镇人民政府</td>
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

              <div v-else-if="selectedDetailSection === 'boundary'" class="sheet-panel">
                <h2>本体边界坐标</h2>
                <table class="list-table detail-table">
                  <thead>
                    <tr>
                      <th>序号</th>
                      <th>点位类型</th>
                      <th>经度</th>
                      <th>纬度</th>
                      <th>高程</th>
                      <th>坐标系</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="point in detailPointRows" :key="point.no">
                      <td>{{ point.no }}</td>
                      <td>{{ point.pointType }}</td>
                      <td>{{ point.longitude }}</td>
                      <td>{{ point.latitude }}</td>
                      <td>{{ point.altitude }}</td>
                      <td>{{ point.coordinateSystem }}</td>
                    </tr>
                    <tr v-if="!detailPointRows.length">
                      <td colspan="6">
                        <div class="table-empty table-empty--compact">
                          <div class="table-empty__icon"></div>
                          <p>暂无边界点位数据</p>
                        </div>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>

              <div v-else-if="selectedDetailSection === 'photo'" class="sheet-panel">
                <h2>照片册页</h2>
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
              </div>

              <div v-else class="sheet-panel sheet-panel--empty">
                <h2>{{ detailSections.find((item) => item.key === selectedDetailSection)?.label }}</h2>
                <p>这个章节已经预留了位置，后面我会按原版登记表的字段和排版继续往下补。</p>
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
