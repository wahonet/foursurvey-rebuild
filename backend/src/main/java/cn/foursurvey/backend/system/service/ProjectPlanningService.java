package cn.foursurvey.backend.system.service;

import cn.foursurvey.backend.system.model.BootstrapModule;
import cn.foursurvey.backend.system.model.BootstrapPayload;
import cn.foursurvey.backend.system.model.BootstrapPhase;
import java.util.List;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class ProjectPlanningService {

    @Value("${app.project-name}")
    private String projectName;

    @Value("${app.current-phase}")
    private String currentPhase;

    @Value("${app.docs-path}")
    private String docsPath;

    public BootstrapPayload buildBootstrap() {
        return new BootstrapPayload(
                projectName,
                currentPhase,
                "首批核心数据模型与建表草案",
                docsPath,
                List.of(
                        new BootstrapPhase("01", "基础平台", "IN_PROGRESS", "登录、权限、菜单、组织与基础字典"),
                        new BootstrapPhase("02", "核心建模", "IN_PROGRESS", "普查对象、接收批次、底账与核查任务"),
                        new BootstrapPhase("03", "业务闭环", "PENDING", "数据初始化、接收数据、采集与核查"),
                        new BootstrapPhase("04", "增强能力", "PENDING", "地图工作台、导出、统计与报送"),
                        new BootstrapPhase("05", "迁移试点", "PENDING", "迁移、试点与上线切换")),
                List.of(
                        new BootstrapModule("auth", "登录与权限", "P0", "backend"),
                        new BootstrapModule("dict", "基础字典", "P0", "backend"),
                        new BootstrapModule("menu", "导航菜单", "P0", "backend"),
                        new BootstrapModule("org", "组织树", "P0", "backend"),
                        new BootstrapModule("init", "数据初始化", "P0", "backend/frontend"),
                        new BootstrapModule("receive", "接收移动端数据", "P0", "backend/frontend"),
                        new BootstrapModule("relic", "普查对象详情", "P0", "backend/frontend"),
                        new BootstrapModule("check", "质量核查", "P1", "backend/frontend"),
                        new BootstrapModule("map", "地图工作台", "P1", "map")));
    }
}
