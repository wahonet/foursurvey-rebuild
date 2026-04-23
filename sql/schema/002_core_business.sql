SET NAMES utf8;

USE four_survey_rebuild;

CREATE TABLE IF NOT EXISTS fs_reference_record (
  id BIGINT NOT NULL AUTO_INCREMENT,
  source_type VARCHAR(32) NOT NULL,
  source_code VARCHAR(100) NULL,
  record_name VARCHAR(200) NOT NULL,
  category_code VARCHAR(64) NULL,
  level_code VARCHAR(64) NULL,
  region_code VARCHAR(32) NULL,
  address_text VARCHAR(500) NULL,
  era_text VARCHAR(100) NULL,
  longitude DECIMAL(12,8) NULL,
  latitude DECIMAL(12,8) NULL,
  source_payload LONGTEXT NULL,
  created_at DATETIME NULL,
  updated_at DATETIME NULL,
  PRIMARY KEY (id),
  KEY idx_fs_reference_source (source_type, source_code),
  KEY idx_fs_reference_region (region_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS fs_receive_batch (
  id BIGINT NOT NULL AUTO_INCREMENT,
  batch_no VARCHAR(64) NOT NULL,
  batch_name VARCHAR(200) NOT NULL,
  receive_source VARCHAR(32) NOT NULL DEFAULT 'MOBILE',
  package_name VARCHAR(255) NULL,
  package_path VARCHAR(500) NULL,
  record_count INT NOT NULL DEFAULT 0,
  receive_status VARCHAR(32) NOT NULL DEFAULT 'CREATED',
  receive_org_id BIGINT NULL,
  operator_id BIGINT NULL,
  received_at DATETIME NULL,
  remark VARCHAR(500) NULL,
  created_at DATETIME NULL,
  updated_at DATETIME NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_fs_receive_batch_no (batch_no)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS fs_receive_record (
  id BIGINT NOT NULL AUTO_INCREMENT,
  batch_id BIGINT NOT NULL,
  record_no VARCHAR(64) NULL,
  survey_type VARCHAR(32) NOT NULL,
  object_name VARCHAR(200) NOT NULL,
  category_code VARCHAR(64) NULL,
  region_code VARCHAR(32) NULL,
  address_text VARCHAR(500) NULL,
  receive_status VARCHAR(32) NOT NULL DEFAULT 'IMPORTED',
  operator_name VARCHAR(100) NULL,
  operated_at DATETIME NULL,
  source_payload LONGTEXT NULL,
  created_at DATETIME NULL,
  updated_at DATETIME NULL,
  PRIMARY KEY (id),
  KEY idx_fs_receive_record_batch (batch_id),
  KEY idx_fs_receive_record_region (region_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS fs_relic_object (
  id BIGINT NOT NULL AUTO_INCREMENT,
  object_code VARCHAR(64) NOT NULL,
  object_name VARCHAR(200) NOT NULL,
  source_type VARCHAR(32) NOT NULL,
  reference_id BIGINT NULL,
  receive_record_id BIGINT NULL,
  org_id BIGINT NULL,
  region_code VARCHAR(32) NULL,
  category_code VARCHAR(64) NULL,
  level_code VARCHAR(64) NULL,
  survey_status VARCHAR(32) NOT NULL DEFAULT 'TO_DO',
  check_status VARCHAR(32) NOT NULL DEFAULT 'PENDING',
  address_text VARCHAR(500) NULL,
  era_text VARCHAR(100) NULL,
  abstract_text TEXT NULL,
  protection_scope TEXT NULL,
  construction_control TEXT NULL,
  current_use VARCHAR(200) NULL,
  fill_user_id BIGINT NULL,
  fill_started_at DATETIME NULL,
  submitted_at DATETIME NULL,
  created_at DATETIME NULL,
  updated_at DATETIME NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_fs_relic_object_code (object_code),
  KEY idx_fs_relic_object_org (org_id),
  KEY idx_fs_relic_object_region (region_code),
  KEY idx_fs_relic_object_status (survey_status, check_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS fs_relic_point (
  id BIGINT NOT NULL AUTO_INCREMENT,
  relic_object_id BIGINT NOT NULL,
  point_type VARCHAR(32) NOT NULL DEFAULT 'MAIN',
  longitude DECIMAL(12,8) NOT NULL,
  latitude DECIMAL(12,8) NOT NULL,
  altitude DECIMAL(10,2) NULL,
  coordinate_system VARCHAR(32) NOT NULL DEFAULT 'CGCS2000',
  source_type VARCHAR(32) NULL,
  created_at DATETIME NULL,
  updated_at DATETIME NULL,
  PRIMARY KEY (id),
  KEY idx_fs_relic_point_object (relic_object_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS fs_check_task (
  id BIGINT NOT NULL AUTO_INCREMENT,
  task_no VARCHAR(64) NOT NULL,
  relic_object_id BIGINT NOT NULL,
  task_type VARCHAR(32) NOT NULL DEFAULT 'QUALITY',
  task_status VARCHAR(32) NOT NULL DEFAULT 'PENDING',
  assignee_id BIGINT NULL,
  assignee_name VARCHAR(100) NULL,
  assigned_at DATETIME NULL,
  finished_at DATETIME NULL,
  result_code VARCHAR(32) NULL,
  result_text VARCHAR(1000) NULL,
  created_by BIGINT NULL,
  created_at DATETIME NULL,
  updated_at DATETIME NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_fs_check_task_no (task_no),
  KEY idx_fs_check_task_object (relic_object_id),
  KEY idx_fs_check_task_status (task_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
