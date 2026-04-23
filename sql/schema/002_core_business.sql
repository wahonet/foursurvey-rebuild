USE four_survey_rebuild;

CREATE TABLE IF NOT EXISTS fs_reference_record (
  id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  source_type VARCHAR(32) NOT NULL COMMENT '来源类型',
  source_code VARCHAR(100) NULL COMMENT '原始编码',
  record_name VARCHAR(200) NOT NULL COMMENT '名称',
  category_code VARCHAR(64) NULL COMMENT '类别编码',
  level_code VARCHAR(64) NULL COMMENT '级别编码',
  region_code VARCHAR(32) NULL COMMENT '行政区划编码',
  address_text VARCHAR(500) NULL COMMENT '地址',
  era_text VARCHAR(100) NULL COMMENT '年代',
  longitude DECIMAL(12,8) NULL COMMENT '经度',
  latitude DECIMAL(12,8) NULL COMMENT '纬度',
  source_payload JSON NULL COMMENT '来源原始数据',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  KEY idx_fs_reference_source (source_type, source_code),
  KEY idx_fs_reference_region (region_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='参照底账';

CREATE TABLE IF NOT EXISTS fs_receive_batch (
  id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  batch_no VARCHAR(64) NOT NULL COMMENT '批次号',
  batch_name VARCHAR(200) NOT NULL COMMENT '批次名称',
  receive_source VARCHAR(32) NOT NULL DEFAULT 'MOBILE' COMMENT '接收来源',
  package_name VARCHAR(255) NULL COMMENT '数据包名称',
  package_path VARCHAR(500) NULL COMMENT '数据包路径',
  record_count INT NOT NULL DEFAULT 0 COMMENT '记录数',
  receive_status VARCHAR(32) NOT NULL DEFAULT 'CREATED' COMMENT '接收状态',
  receive_org_id BIGINT NULL COMMENT '接收组织ID',
  operator_id BIGINT NULL COMMENT '操作人ID',
  received_at DATETIME NULL COMMENT '接收时间',
  remark VARCHAR(500) NULL COMMENT '备注',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_fs_receive_batch_no (batch_no)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='接收批次';

CREATE TABLE IF NOT EXISTS fs_receive_record (
  id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  batch_id BIGINT NOT NULL COMMENT '所属批次ID',
  record_no VARCHAR(64) NULL COMMENT '记录号',
  survey_type VARCHAR(32) NOT NULL COMMENT '调查类型',
  object_name VARCHAR(200) NOT NULL COMMENT '对象名称',
  category_code VARCHAR(64) NULL COMMENT '类别编码',
  region_code VARCHAR(32) NULL COMMENT '行政区划编码',
  address_text VARCHAR(500) NULL COMMENT '地址',
  receive_status VARCHAR(32) NOT NULL DEFAULT 'IMPORTED' COMMENT '接收状态',
  operator_name VARCHAR(100) NULL COMMENT '操作人',
  operated_at DATETIME NULL COMMENT '操作时间',
  source_payload JSON NULL COMMENT '原始回传数据',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  KEY idx_fs_receive_record_batch (batch_id),
  KEY idx_fs_receive_record_region (region_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='接收记录';

CREATE TABLE IF NOT EXISTS fs_relic_object (
  id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  object_code VARCHAR(64) NOT NULL COMMENT '普查对象编码',
  object_name VARCHAR(200) NOT NULL COMMENT '普查对象名称',
  source_type VARCHAR(32) NOT NULL COMMENT '调查来源',
  reference_id BIGINT NULL COMMENT '参照底账ID',
  receive_record_id BIGINT NULL COMMENT '来源接收记录ID',
  org_id BIGINT NULL COMMENT '归属组织ID',
  region_code VARCHAR(32) NULL COMMENT '行政区划编码',
  category_code VARCHAR(64) NULL COMMENT '文物类别编码',
  level_code VARCHAR(64) NULL COMMENT '文物级别编码',
  survey_status VARCHAR(32) NOT NULL DEFAULT 'TO_DO' COMMENT '普查状态',
  check_status VARCHAR(32) NOT NULL DEFAULT 'PENDING' COMMENT '核查状态',
  address_text VARCHAR(500) NULL COMMENT '地址',
  era_text VARCHAR(100) NULL COMMENT '年代',
  abstract_text VARCHAR(2000) NULL COMMENT '简介',
  protection_scope TEXT NULL COMMENT '保护范围',
  construction_control TEXT NULL COMMENT '建设控制地带',
  current_use VARCHAR(200) NULL COMMENT '现状用途',
  fill_user_id BIGINT NULL COMMENT '填报人ID',
  fill_started_at DATETIME NULL COMMENT '开始填报时间',
  submitted_at DATETIME NULL COMMENT '提交时间',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_fs_relic_object_code (object_code),
  KEY idx_fs_relic_object_org (org_id),
  KEY idx_fs_relic_object_region (region_code),
  KEY idx_fs_relic_object_status (survey_status, check_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='普查对象主档';

CREATE TABLE IF NOT EXISTS fs_relic_point (
  id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  relic_object_id BIGINT NOT NULL COMMENT '普查对象ID',
  point_type VARCHAR(32) NOT NULL DEFAULT 'MAIN' COMMENT '点位类型',
  longitude DECIMAL(12,8) NOT NULL COMMENT '经度',
  latitude DECIMAL(12,8) NOT NULL COMMENT '纬度',
  altitude DECIMAL(10,2) NULL COMMENT '高程',
  coordinate_system VARCHAR(32) NOT NULL DEFAULT 'CGCS2000' COMMENT '坐标系',
  source_type VARCHAR(32) NULL COMMENT '来源类型',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  KEY idx_fs_relic_point_object (relic_object_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='普查对象点位';

CREATE TABLE IF NOT EXISTS fs_check_task (
  id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  task_no VARCHAR(64) NOT NULL COMMENT '任务编号',
  relic_object_id BIGINT NOT NULL COMMENT '普查对象ID',
  task_type VARCHAR(32) NOT NULL DEFAULT 'QUALITY' COMMENT '任务类型',
  task_status VARCHAR(32) NOT NULL DEFAULT 'PENDING' COMMENT '任务状态',
  assignee_id BIGINT NULL COMMENT '处理人ID',
  assignee_name VARCHAR(100) NULL COMMENT '处理人名称',
  assigned_at DATETIME NULL COMMENT '分配时间',
  finished_at DATETIME NULL COMMENT '完成时间',
  result_code VARCHAR(32) NULL COMMENT '结果编码',
  result_text VARCHAR(1000) NULL COMMENT '处理意见',
  created_by BIGINT NULL COMMENT '创建人',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_fs_check_task_no (task_no),
  KEY idx_fs_check_task_object (relic_object_id),
  KEY idx_fs_check_task_status (task_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='核查任务';
