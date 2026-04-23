package cn.foursurvey.backend.system.web;

import cn.foursurvey.backend.common.api.ApiResponse;
import cn.foursurvey.backend.system.model.BootstrapPayload;
import cn.foursurvey.backend.system.service.ProjectPlanningService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/system")
public class SystemController {

    private final ProjectPlanningService projectPlanningService;

    public SystemController(ProjectPlanningService projectPlanningService) {
        this.projectPlanningService = projectPlanningService;
    }

    @GetMapping("/bootstrap")
    public ApiResponse<BootstrapPayload> bootstrap() {
        return ApiResponse.ok(projectPlanningService.buildBootstrap());
    }
}
