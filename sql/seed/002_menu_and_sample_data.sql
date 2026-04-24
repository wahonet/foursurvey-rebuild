SET NAMES utf8;

USE four_survey_rebuild;

INSERT INTO sys_menu (
  id, parent_id, menu_code, menu_name, menu_type, route_path, icon_name, component_name, permission_code, sort_no, enabled, deleted, created_at, updated_at
) VALUES
  (1, NULL, 'dashboard', '工作台', 'MENU', '/dashboard', 'home', 'DashboardPage', 'dashboard:view', 1, 1, 0, NOW(), NOW()),
  (2, NULL, 'data-init', '数据初始化', 'MENU', '/data-init', 'database', 'DataInitPage', 'data:init:view', 2, 1, 0, NOW(), NOW()),
  (3, NULL, 'receive', '接收移动端数据', 'MENU', '/receive', 'inbox', 'ReceivePage', 'receive:view', 3, 1, 0, NOW(), NOW()),
  (4, NULL, 'objects', '普查对象', 'MENU', '/objects', 'list', 'ObjectListPage', 'object:view', 4, 1, 0, NOW(), NOW()),
  (5, NULL, 'check', '质量核查', 'MENU', '/check', 'check', 'CheckPage', 'check:view', 5, 1, 0, NOW(), NOW()),
  (6, NULL, 'system', '系统管理', 'MENU', '/system', 'settings', 'SystemPage', 'system:view', 6, 1, 0, NOW(), NOW()),
  (7, 6, 'system-org', '组织机构', 'MENU', '/system/orgs', 'org', 'OrgPage', 'org:view', 1, 1, 0, NOW(), NOW()),
  (8, 6, 'system-dict', '基础字典', 'MENU', '/system/dicts', 'dict', 'DictPage', 'dict:view', 2, 1, 0, NOW(), NOW())
ON DUPLICATE KEY UPDATE
  menu_name = VALUES(menu_name),
  route_path = VALUES(route_path),
  icon_name = VALUES(icon_name),
  component_name = VALUES(component_name),
  permission_code = VALUES(permission_code),
  sort_no = VALUES(sort_no),
  enabled = VALUES(enabled),
  deleted = VALUES(deleted),
  updated_at = NOW();

INSERT INTO sys_role_menu (role_id, menu_id, created_at)
SELECT seed.role_id, seed.menu_id, NOW()
FROM (
  SELECT 1 AS role_id, 1 AS menu_id
  UNION ALL SELECT 1, 2
  UNION ALL SELECT 1, 3
  UNION ALL SELECT 1, 4
  UNION ALL SELECT 1, 5
  UNION ALL SELECT 1, 6
  UNION ALL SELECT 1, 7
  UNION ALL SELECT 1, 8
  UNION ALL SELECT 2, 1
  UNION ALL SELECT 2, 2
  UNION ALL SELECT 2, 3
  UNION ALL SELECT 2, 4
  UNION ALL SELECT 3, 1
  UNION ALL SELECT 3, 4
  UNION ALL SELECT 3, 5
) seed
LEFT JOIN sys_role_menu current_row
  ON current_row.role_id = seed.role_id
 AND current_row.menu_id = seed.menu_id
WHERE current_row.id IS NULL;

INSERT INTO fs_relic_object (
  id, object_code, object_name, source_type, org_id, region_code, category_code, level_code,
  survey_status, check_status, address_text, era_text, abstract_text, current_use, created_at, updated_at
) VALUES
  (1, 'FS-370829-0001', '示例石刻点', 'THIRD_CENSUS', 1, '370829', 'GROTTO_CARVING', NULL, 'DONE', 'PASSED',
   '示例区域一', '清', '示例对象，用于列表骨架联调。', '展示', NOW(), NOW()),
  (2, 'FS-370829-0002', '示例古建筑点', 'NEW_DISCOVERY', 1, '370829', 'ANCIENT_BUILDING', NULL, 'IN_PROGRESS', 'IN_REVIEW',
   '示例区域二', '不详', '示例对象，用于接下一步详情页。', '闲置', NOW(), NOW()),
  (3, 'FS-370829-0003', '示例近现代建筑点', 'CHANGE', 1, '370829', 'MODERN_HISTORIC', NULL, 'TO_DO', 'PENDING',
   '示例区域三', '民国', '示例对象，用于核查与流程状态展示。', '待核实', NOW(), NOW())
ON DUPLICATE KEY UPDATE
  object_name = VALUES(object_name),
  source_type = VALUES(source_type),
  org_id = VALUES(org_id),
  region_code = VALUES(region_code),
  category_code = VALUES(category_code),
  survey_status = VALUES(survey_status),
  check_status = VALUES(check_status),
  address_text = VALUES(address_text),
  era_text = VALUES(era_text),
  abstract_text = VALUES(abstract_text),
  current_use = VALUES(current_use),
  updated_at = NOW();

INSERT INTO fs_relic_point (
  id, relic_object_id, point_type, longitude, latitude, altitude, coordinate_system, source_type, created_at, updated_at
) VALUES
  (1, 1, 'MAIN', 116.34461400, 35.34019400, 56.20, 'CGCS2000', 'THIRD_CENSUS', NOW(), NOW()),
  (2, 2, 'MAIN', 116.35671100, 35.33796200, 58.10, 'CGCS2000', 'NEW_DISCOVERY', NOW(), NOW()),
  (3, 3, 'MAIN', 116.32981400, 35.34122900, 54.70, 'CGCS2000', 'CHANGE', NOW(), NOW())
ON DUPLICATE KEY UPDATE
  longitude = VALUES(longitude),
  latitude = VALUES(latitude),
  altitude = VALUES(altitude),
  coordinate_system = VALUES(coordinate_system),
  source_type = VALUES(source_type),
  updated_at = NOW();

INSERT INTO fs_receive_batch (
  id, batch_no, batch_name, receive_source, package_name, package_path, record_count, receive_status,
  receive_org_id, operator_id, received_at, remark, created_at, updated_at
) VALUES
  (1, 'RB-20260423-001', '4月外业回传批次一', 'MOBILE', 'rb-20260423-001.zip',
   'G:/fourSurvey/packages/rb-20260423-001.zip', 2, 'IMPORTED', 1, 1, NOW(),
   '示例接收批次，用于前端详情联调。', NOW(), NOW()),
  (2, 'RB-20260423-002', '4月外业回传批次二', 'MOBILE', 'rb-20260423-002.zip',
   'G:/fourSurvey/packages/rb-20260423-002.zip', 1, 'IMPORTED', 1, 1, NOW(),
   '示例接收批次，用于展示多批次列表。', NOW(), NOW())
ON DUPLICATE KEY UPDATE
  batch_name = VALUES(batch_name),
  package_name = VALUES(package_name),
  package_path = VALUES(package_path),
  record_count = VALUES(record_count),
  receive_status = VALUES(receive_status),
  receive_org_id = VALUES(receive_org_id),
  operator_id = VALUES(operator_id),
  received_at = VALUES(received_at),
  remark = VALUES(remark),
  updated_at = NOW();

INSERT INTO fs_receive_record (
  id, batch_id, record_no, survey_type, object_name, category_code, region_code, address_text,
  receive_status, operator_name, operated_at, source_payload, created_at, updated_at
) VALUES
  (1, 1, 'RR-001', 'NEW_DISCOVERY', '示例古建筑点', 'ANCIENT_BUILDING', '370829',
   '示例区域二', 'IMPORTED', '系统用户', NOW(),
   '{\"source\":\"mobile\",\"device\":\"android\"}', NOW(), NOW()),
  (2, 1, 'RR-002', 'CHANGE', '示例近现代建筑点', 'MODERN_HISTORIC', '370829',
   '示例区域三', 'IMPORTED', '系统用户', NOW(),
   '{\"source\":\"mobile\",\"device\":\"android\"}', NOW(), NOW()),
  (3, 2, 'RR-003', 'THIRD_CENSUS', '示例石刻点', 'GROTTO_CARVING', '370829',
   '示例区域一', 'IMPORTED', '系统用户', NOW(),
   '{\"source\":\"mobile\",\"device\":\"android\"}', NOW(), NOW())
ON DUPLICATE KEY UPDATE
  batch_id = VALUES(batch_id),
  survey_type = VALUES(survey_type),
  object_name = VALUES(object_name),
  category_code = VALUES(category_code),
  region_code = VALUES(region_code),
  address_text = VALUES(address_text),
  receive_status = VALUES(receive_status),
  operator_name = VALUES(operator_name),
  operated_at = VALUES(operated_at),
  source_payload = VALUES(source_payload),
  updated_at = NOW();
