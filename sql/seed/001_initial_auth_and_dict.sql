USE four_survey_rebuild;

INSERT INTO sys_org (
  id, parent_id, org_code, org_name, org_type, region_code, leader_name, contact_phone, sort_no, enabled, deleted
) VALUES (
  1, NULL, '370829', '嘉祥县普查办', 'AREA', '370829', '系统初始化', '000-00000000', 1, 1, 0
)
ON DUPLICATE KEY UPDATE
  org_name = VALUES(org_name),
  org_type = VALUES(org_type),
  region_code = VALUES(region_code),
  enabled = VALUES(enabled),
  deleted = VALUES(deleted);

INSERT INTO sys_role (
  id, role_code, role_name, role_scope, sort_no, enabled, deleted
) VALUES
  (1, 'SUPER_ADMIN', '系统管理员', 'GLOBAL', 1, 1, 0),
  (2, 'COUNTY_OPERATOR', '县级采集员', 'ORG', 2, 1, 0),
  (3, 'COUNTY_CHECKER', '县级核查员', 'ORG', 3, 1, 0)
ON DUPLICATE KEY UPDATE
  role_name = VALUES(role_name),
  role_scope = VALUES(role_scope),
  sort_no = VALUES(sort_no),
  enabled = VALUES(enabled),
  deleted = VALUES(deleted);

INSERT INTO sys_user (
  id, org_id, username, display_name, password_hash, password_salt, mobile, email, account_status, enabled, deleted
) VALUES (
  1, 1, 'admin', '系统管理员', 'd5cf4d455624b480e3abe59341cb8409b6f9571529603a40b976b94e502a694a',
  '123456789abcdef01122334455667788', '13800000000', 'admin@foursurvey.local', 'ACTIVE', 1, 0
)
ON DUPLICATE KEY UPDATE
  org_id = VALUES(org_id),
  display_name = VALUES(display_name),
  password_hash = VALUES(password_hash),
  password_salt = VALUES(password_salt),
  account_status = VALUES(account_status),
  enabled = VALUES(enabled),
  deleted = VALUES(deleted);

INSERT INTO sys_user_role (
  user_id, role_id
) VALUES
  (1, 1)
ON DUPLICATE KEY UPDATE
  role_id = VALUES(role_id);

INSERT INTO base_region (
  id, parent_id, region_code, region_name, region_level, full_name, sort_no, enabled
) VALUES
  (1, NULL, '370000', '山东省', 'PROVINCE', '山东省', 1, 1),
  (2, 1, '370800', '济宁市', 'CITY', '山东省济宁市', 1, 1),
  (3, 2, '370829', '嘉祥县', 'COUNTY', '山东省济宁市嘉祥县', 1, 1)
ON DUPLICATE KEY UPDATE
  region_name = VALUES(region_name),
  region_level = VALUES(region_level),
  full_name = VALUES(full_name),
  enabled = VALUES(enabled);

INSERT INTO base_dict_item (
  dict_type_id, item_code, item_name, item_value, sort_no, enabled
)
SELECT t.id, seed.item_code, seed.item_name, seed.item_value, seed.sort_no, 1
FROM base_dict_type t
JOIN (
  SELECT 'relic_category' AS dict_code, 'ANCIENT_SITE' AS item_code, '古文化遗址' AS item_name, '古文化遗址' AS item_value, 1 AS sort_no
  UNION ALL SELECT 'relic_category', 'ANCIENT_TOMB', '古墓葬', '古墓葬', 2
  UNION ALL SELECT 'relic_category', 'ANCIENT_BUILDING', '古建筑', '古建筑', 3
  UNION ALL SELECT 'relic_category', 'GROTTO_CARVING', '石窟寺及石刻', '石窟寺及石刻', 4
  UNION ALL SELECT 'relic_category', 'MODERN_HISTORIC', '近现代重要史迹及代表性建筑', '近现代重要史迹及代表性建筑', 5
  UNION ALL SELECT 'survey_status', 'TO_DO', '待普查', '待普查', 1
  UNION ALL SELECT 'survey_status', 'IN_PROGRESS', '普查中', '普查中', 2
  UNION ALL SELECT 'survey_status', 'DONE', '已普查', '已普查', 3
  UNION ALL SELECT 'survey_source', 'THIRD_CENSUS', '三普延续', '三普延续', 1
  UNION ALL SELECT 'survey_source', 'NEW_DISCOVERY', '新发现', '新发现', 2
  UNION ALL SELECT 'survey_source', 'CHANGE', '变更', '变更', 3
  UNION ALL SELECT 'check_status', 'PENDING', '待核查', '待核查', 1
  UNION ALL SELECT 'check_status', 'IN_REVIEW', '核查中', '核查中', 2
  UNION ALL SELECT 'check_status', 'PASSED', '已通过', '已通过', 3
  UNION ALL SELECT 'check_status', 'REJECTED', '已退回', '已退回', 4
) seed ON seed.dict_code = t.dict_code
LEFT JOIN base_dict_item i ON i.dict_type_id = t.id AND i.item_code = seed.item_code
WHERE i.id IS NULL;

-- 初始账号：
-- 用户名：admin
-- 密码：Admin@123456
