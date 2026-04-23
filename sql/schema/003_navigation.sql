USE four_survey_rebuild;

CREATE TABLE IF NOT EXISTS sys_menu (
  id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  parent_id BIGINT NULL COMMENT '父菜单ID',
  menu_code VARCHAR(64) NOT NULL COMMENT '菜单编码',
  menu_name VARCHAR(100) NOT NULL COMMENT '菜单名称',
  menu_type VARCHAR(32) NOT NULL DEFAULT 'MENU' COMMENT '菜单类型',
  route_path VARCHAR(200) NULL COMMENT '路由路径',
  icon_name VARCHAR(64) NULL COMMENT '图标',
  component_name VARCHAR(100) NULL COMMENT '组件名称',
  permission_code VARCHAR(100) NULL COMMENT '权限编码',
  sort_no INT NOT NULL DEFAULT 0 COMMENT '排序号',
  enabled TINYINT NOT NULL DEFAULT 1 COMMENT '是否启用',
  deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_sys_menu_code (menu_code),
  KEY idx_sys_menu_parent (parent_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统菜单';

CREATE TABLE IF NOT EXISTS sys_role_menu (
  id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  role_id BIGINT NOT NULL COMMENT '角色ID',
  menu_id BIGINT NOT NULL COMMENT '菜单ID',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_sys_role_menu (role_id, menu_id),
  KEY idx_sys_role_menu_menu (menu_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色菜单关联';
