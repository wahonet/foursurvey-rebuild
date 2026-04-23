SET NAMES utf8;

CREATE DATABASE IF NOT EXISTS four_survey_rebuild
  DEFAULT CHARACTER SET utf8
  DEFAULT COLLATE utf8_general_ci;

USE four_survey_rebuild;

CREATE TABLE IF NOT EXISTS sys_org (
  id BIGINT NOT NULL AUTO_INCREMENT,
  parent_id BIGINT NULL,
  org_code VARCHAR(64) NOT NULL,
  org_name VARCHAR(200) NOT NULL,
  org_type VARCHAR(32) NOT NULL DEFAULT 'AREA',
  region_code VARCHAR(32) NULL,
  leader_name VARCHAR(64) NULL,
  contact_phone VARCHAR(32) NULL,
  sort_no INT NOT NULL DEFAULT 0,
  enabled TINYINT NOT NULL DEFAULT 1,
  deleted TINYINT NOT NULL DEFAULT 0,
  created_by BIGINT NULL,
  created_at DATETIME NULL,
  updated_by BIGINT NULL,
  updated_at DATETIME NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_sys_org_code (org_code),
  KEY idx_sys_org_parent (parent_id),
  KEY idx_sys_org_region (region_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS sys_role (
  id BIGINT NOT NULL AUTO_INCREMENT,
  role_code VARCHAR(64) NOT NULL,
  role_name VARCHAR(100) NOT NULL,
  role_scope VARCHAR(32) NOT NULL DEFAULT 'ORG',
  sort_no INT NOT NULL DEFAULT 0,
  enabled TINYINT NOT NULL DEFAULT 1,
  deleted TINYINT NOT NULL DEFAULT 0,
  created_by BIGINT NULL,
  created_at DATETIME NULL,
  updated_by BIGINT NULL,
  updated_at DATETIME NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_sys_role_code (role_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS sys_user (
  id BIGINT NOT NULL AUTO_INCREMENT,
  org_id BIGINT NULL,
  username VARCHAR(64) NOT NULL,
  display_name VARCHAR(100) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  password_salt VARCHAR(64) NULL,
  mobile VARCHAR(32) NULL,
  email VARCHAR(100) NULL,
  id_card_no VARCHAR(32) NULL,
  account_status VARCHAR(32) NOT NULL DEFAULT 'ACTIVE',
  last_login_at DATETIME NULL,
  last_login_ip VARCHAR(64) NULL,
  enabled TINYINT NOT NULL DEFAULT 1,
  deleted TINYINT NOT NULL DEFAULT 0,
  created_by BIGINT NULL,
  created_at DATETIME NULL,
  updated_by BIGINT NULL,
  updated_at DATETIME NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_sys_user_username (username),
  KEY idx_sys_user_org (org_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS sys_user_role (
  id BIGINT NOT NULL AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  role_id BIGINT NOT NULL,
  created_by BIGINT NULL,
  created_at DATETIME NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_sys_user_role (user_id, role_id),
  KEY idx_sys_user_role_role (role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS base_region (
  id BIGINT NOT NULL AUTO_INCREMENT,
  parent_id BIGINT NULL,
  region_code VARCHAR(32) NOT NULL,
  region_name VARCHAR(100) NOT NULL,
  region_level VARCHAR(32) NOT NULL,
  full_name VARCHAR(300) NULL,
  sort_no INT NOT NULL DEFAULT 0,
  enabled TINYINT NOT NULL DEFAULT 1,
  created_at DATETIME NULL,
  updated_at DATETIME NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_base_region_code (region_code),
  KEY idx_base_region_parent (parent_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS base_dict_type (
  id BIGINT NOT NULL AUTO_INCREMENT,
  dict_code VARCHAR(64) NOT NULL,
  dict_name VARCHAR(100) NOT NULL,
  dict_group VARCHAR(64) NULL,
  description VARCHAR(500) NULL,
  enabled TINYINT NOT NULL DEFAULT 1,
  created_at DATETIME NULL,
  updated_at DATETIME NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_base_dict_type_code (dict_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS base_dict_item (
  id BIGINT NOT NULL AUTO_INCREMENT,
  dict_type_id BIGINT NOT NULL,
  item_code VARCHAR(64) NOT NULL,
  item_name VARCHAR(200) NOT NULL,
  item_value VARCHAR(200) NULL,
  sort_no INT NOT NULL DEFAULT 0,
  enabled TINYINT NOT NULL DEFAULT 1,
  ext_json LONGTEXT NULL,
  created_at DATETIME NULL,
  updated_at DATETIME NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_base_dict_item_code (dict_type_id, item_code),
  KEY idx_base_dict_item_type (dict_type_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS file_resource (
  id BIGINT NOT NULL AUTO_INCREMENT,
  biz_type VARCHAR(64) NOT NULL,
  biz_id BIGINT NULL,
  file_name VARCHAR(255) NOT NULL,
  file_path VARCHAR(500) NOT NULL,
  file_ext VARCHAR(32) NULL,
  mime_type VARCHAR(100) NULL,
  file_size BIGINT NULL,
  storage_type VARCHAR(32) NOT NULL DEFAULT 'LOCAL',
  uploader_id BIGINT NULL,
  uploaded_at DATETIME NULL,
  deleted TINYINT NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  KEY idx_file_resource_biz (biz_type, biz_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO base_dict_type (dict_code, dict_name, dict_group, description, enabled, created_at, updated_at)
VALUES
  ('relic_category', '文物类别', 'relic', '普查对象类别', 1, NOW(), NOW()),
  ('survey_status', '普查状态', 'relic', '待普查、普查中、已普查等', 1, NOW(), NOW()),
  ('survey_source', '调查来源', 'relic', '三普延续、新发现、变更等', 1, NOW(), NOW()),
  ('check_status', '核查状态', 'workflow', '待核查、核查中、已通过、已退回', 1, NOW(), NOW())
ON DUPLICATE KEY UPDATE
  dict_name = VALUES(dict_name),
  dict_group = VALUES(dict_group),
  description = VALUES(description),
  updated_at = NOW();
