# SQL 说明

本目录用于存放新系统数据库相关内容：

- 建表脚本
- 初始化脚本
- 迁移脚本草案

当前原则：

1. 先按照新系统业务域重建，不直接复制旧库所有表。
2. 先建立核心主干表，再补充扩展表和兼容视图。
3. 地图、附件、升级等能力后续按模块补充。

## 目录结构

- `schema/`：建表脚本
- `seed/`：初始化数据
- `migration/`：历史数据迁移草案

## 当前建表顺序

1. `schema/001_core_platform.sql`
2. `schema/002_core_business.sql`

## 首批覆盖范围

### 平台域

- 组织机构 `sys_org`
- 角色 `sys_role`
- 用户 `sys_user`
- 用户角色关联 `sys_user_role`
- 行政区划 `base_region`
- 字典类型与字典项 `base_dict_type` / `base_dict_item`
- 附件资源 `file_resource`

### 业务域

- 参照底账 `fs_reference_record`
- 接收批次 `fs_receive_batch`
- 接收记录 `fs_receive_record`
- 普查对象主档 `fs_relic_object`
- 普查对象点位 `fs_relic_point`
- 核查任务 `fs_check_task`

## 下一步

下一步补充内容：

1. 初始管理员与角色种子数据
2. 普查对象扩展信息表
3. 图片、构成、样本、线图等从表
4. 旧库到新库的迁移草案
