USE four_survey_rebuild;

INSERT INTO sys_menu (
  id, parent_id, menu_code, menu_name, menu_type, route_path, icon_name, component_name, permission_code, sort_no, enabled, deleted
) VALUES
  (1, NULL, 'dashboard', '工作台', 'MENU', '/dashboard', 'home', 'DashboardPage', 'dashboard:view', 1, 1, 0),
  (2, NULL, 'data-init', '数据初始化', 'MENU', '/data-init', 'database', 'DataInitPage', 'data:init:view', 2, 1, 0),
  (3, NULL, 'receive', '接收移动端数据', 'MENU', '/receive', 'inbox', 'ReceivePage', 'receive:view', 3, 1, 0),
  (4, NULL, 'objects', '普查对象', 'MENU', '/objects', 'list', 'ObjectListPage', 'object:view', 4, 1, 0),
  (5, NULL, 'check', '质量核查', 'MENU', '/check', 'check', 'CheckPage', 'check:view', 5, 1, 0),
  (6, NULL, 'system', '系统管理', 'MENU', '/system', 'settings', 'SystemPage', 'system:view', 6, 1, 0),
  (7, 6, 'system-org', '组织机构', 'MENU', '/system/orgs', 'org', 'OrgPage', 'org:view', 1, 1, 0),
  (8, 6, 'system-dict', '基础字典', 'MENU', '/system/dicts', 'dict', 'DictPage', 'dict:view', 2, 1, 0)
ON DUPLICATE KEY UPDATE
  menu_name = VALUES(menu_name),
  route_path = VALUES(route_path),
  icon_name = VALUES(icon_name),
  component_name = VALUES(component_name),
  permission_code = VALUES(permission_code),
  sort_no = VALUES(sort_no),
  enabled = VALUES(enabled),
  deleted = VALUES(deleted);

INSERT INTO sys_role_menu (role_id, menu_id)
SELECT seed.role_id, seed.menu_id
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
  survey_status, check_status, address_text, era_text, abstract_text, current_use
) VALUES
  (1, 'FS-370829-0001', '曾庙碑', 'THIRD_CENSUS', 1, '370829', 'GROTTO_CARVING', NULL, 'DONE', 'PASSED',
   '山东省济宁市嘉祥县', '清', '示例对象，用于列表骨架联调。', '展示'),
  (2, 'FS-370829-0002', '北李楼村观音堂', 'NEW_DISCOVERY', 1, '370829', 'ANCIENT_BUILDING', NULL, 'IN_PROGRESS', 'IN_REVIEW',
   '山东省济宁市嘉祥县仲山镇', '不详', '示例对象，用于接下一步详情页。', '闲置'),
  (3, 'FS-370829-0003', '张攀柱墓碑', 'CHANGE', 1, '370829', 'MODERN_HISTORIC', NULL, 'TO_DO', 'PENDING',
   '山东省济宁市嘉祥县布山村', '民国', '示例对象，用于核查与流程状态展示。', '待核实')
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
  current_use = VALUES(current_use);
