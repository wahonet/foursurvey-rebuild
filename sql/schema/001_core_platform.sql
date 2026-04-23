CREATE DATABASE IF NOT EXISTS four_survey_rebuild
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE four_survey_rebuild;

CREATE TABLE IF NOT EXISTS sys_org (
  id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  parent_id BIGINT NULL COMMENT '父级组织ID',
  org_code VARCHAR(64) NOT NULL COMMENT '组织编码',
  org_name VARCHAR(200) NOT NULL COMMENT '组织名称',
  org_type VARCHAR(32) NOT NULL DEFAULT 'AREA' COMMENT '组织类型',
  region_code VARCHAR(32) NULL COMMENT '行政区划编码',
  leader_name VARCHAR(64) NULL COMMENT '负责人',
  contact_phone VARCHAR(32) NULL COMMENT '联系电话',
  sort_no INT NOT NULL DEFAULT 0 COMMENT '排序号',
  enabled TINYINT NOT NULL DEFAULT 1 COMMENT '是否启用',
  deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除',
  created_by BIGINT NULL COMMENT '创建人',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_by BIGINT NULL COMMENT '更新人',
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_sys_org_code (org_code),
  KEY idx_sys_org_parent (parent_id),
  KEY idx_sys_org_region (region_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='组织机构';

CREATE TABLE IF NOT EXISTS sys_role (
  id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  role_code VARCHAR(64) NOT NULL COMMENT '角色编码',
  role_name VARCHAR(100) NOT NULL COMMENT '角色名称',
  role_scope VARCHAR(32) NOT NULL DEFAULT 'ORG' COMMENT '角色范围',
  sort_no INT NOT NULL DEFAULT 0 COMMENT '排序号',
  enabled TINYINT NOT NULL DEFAULT 1 COMMENT '是否启用',
  deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除',
  created_by BIGINT NULL COMMENT '创建人',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_by BIGINT NULL COMMENT '更新人',
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_sys_role_code (role_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色';

CREATE TABLE IF NOT EXISTS sys_user (
  id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  org_id BIGINT NULL COMMENT '所属组织ID',
  username VARCHAR(64) NOT NULL COMMENT '登录名',
  display_name VARCHAR(100) NOT NULL COMMENT '显示名称',
  password_hash VARCHAR(255) NOT NULL COMMENT '密码哈希',
  password_salt VARCHAR(64) NULL COMMENT '密码盐',
  mobile VARCHAR(32) NULL COMMENT '手机号',
  email VARCHAR(100) NULL COMMENT '邮箱',
  id_card_no VARCHAR(32) NULL COMMENT '身份证号',
  account_status VARCHAR(32) NOT NULL DEFAULT 'ACTIVE' COMMENT '账号状态',
  last_login_at DATETIME NULL COMMENT '最后登录时间',
  last_login_ip VARCHAR(64) NULL COMMENT '最后登录IP',
  enabled TINYINT NOT NULL DEFAULT 1 COMMENT '是否启用',
  deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除',
  created_by BIGINT NULL COMMENT '创建人',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_by BIGINT NULL COMMENT '更新人',
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_sys_user_username (username),
  KEY idx_sys_user_org (org_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户';

CREATE TABLE IF NOT EXISTS sys_user_role (
  id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  user_id BIGINT NOT NULL COMMENT '用户ID',
  role_id BIGINT NOT NULL COMMENT '角色ID',
  created_by BIGINT NULL COMMENT '创建人',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_sys_user_role (user_id, role_id),
  KEY idx_sys_user_role_role (role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户角色关联';

CREATE TABLE IF NOT EXISTS base_region (
  id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  parent_id BIGINT NULL COMMENT '父级区域ID',
  region_code VARCHAR(32) NOT NULL COMMENT '区域编码',
  region_name VARCHAR(100) NOT NULL COMMENT '区域名称',
  region_level VARCHAR(32) NOT NULL COMMENT '区域级别',
  full_name VARCHAR(300) NULL COMMENT '全名',
  sort_no INT NOT NULL DEFAULT 0 COMMENT '排序号',
  enabled TINYINT NOT NULL DEFAULT 1 COMMENT '是否启用',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_base_region_code (region_code),
  KEY idx_base_region_parent (parent_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='行政区划';

CREATE TABLE IF NOT EXISTS base_dict_type (
  id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  dict_code VARCHAR(64) NOT NULL COMMENT '字典编码',
  dict_name VARCHAR(100) NOT NULL COMMENT '字典名称',
  dict_group VARCHAR(64) NULL COMMENT '字典分组',
  description VARCHAR(500) NULL COMMENT '说明',
  enabled TINYINT NOT NULL DEFAULT 1 COMMENT '是否启用',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_base_dict_type_code (dict_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='字典类型';

CREATE TABLE IF NOT EXISTS base_dict_item (
  id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  dict_type_id BIGINT NOT NULL COMMENT '字典类型ID',
  item_code VARCHAR(64) NOT NULL COMMENT '字典项编码',
  item_name VARCHAR(200) NOT NULL COMMENT '字典项名称',
  item_value VARCHAR(200) NULL COMMENT '字典项值',
  sort_no INT NOT NULL DEFAULT 0 COMMENT '排序号',
  enabled TINYINT NOT NULL DEFAULT 1 COMMENT '是否启用',
  ext_json JSON NULL COMMENT '扩展属性',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_base_dict_item_code (dict_type_id, item_code),
  KEY idx_base_dict_item_type (dict_type_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='字典项';

CREATE TABLE IF NOT EXISTS file_resource (
  id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  biz_type VARCHAR(64) NOT NULL COMMENT '业务类型',
  biz_id BIGINT NULL COMMENT '业务ID',
  file_name VARCHAR(255) NOT NULL COMMENT '文件名称',
  file_path VARCHAR(500) NOT NULL COMMENT '文件路径',
  file_ext VARCHAR(32) NULL COMMENT '扩展名',
  mime_type VARCHAR(100) NULL COMMENT 'MIME类型',
  file_size BIGINT NULL COMMENT '文件大小',
  storage_type VARCHAR(32) NOT NULL DEFAULT 'LOCAL' COMMENT '存储类型',
  uploader_id BIGINT NULL COMMENT '上传人ID',
  uploaded_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '上传时间',
  deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除',
  PRIMARY KEY (id),
  KEY idx_file_resource_biz (biz_type, biz_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='附件资源';

INSERT INTO base_dict_type (dict_code, dict_name, dict_group, description)
VALUES
  ('relic_category', '文物类别', 'relic', '普查对象类别'),
  ('survey_status', '普查状态', 'relic', '待普查、普查中、已普查等'),
  ('survey_source', '调查来源', 'relic', '三普延续、新发现、变更等'),
  ('check_status', '核查状态', 'workflow', '待核查、核查中、已通过、已退回')
ON DUPLICATE KEY UPDATE
  dict_name = VALUES(dict_name),
  dict_group = VALUES(dict_group),
  description = VALUES(description);
