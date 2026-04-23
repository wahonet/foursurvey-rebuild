package cn.foursurvey.backend.org.web;

import cn.foursurvey.backend.auth.model.AuthSession;
import cn.foursurvey.backend.auth.support.AuthContext;
import cn.foursurvey.backend.common.api.ApiResponse;
import cn.foursurvey.backend.org.model.OrgTreePayload;
import cn.foursurvey.backend.org.service.OrgService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/orgs")
public class OrgController {

    private final OrgService orgService;

    public OrgController(OrgService orgService) {
        this.orgService = orgService;
    }

    @GetMapping("/tree")
    public ApiResponse<OrgTreePayload> tree(HttpServletRequest request) {
        AuthSession session = (AuthSession) request.getAttribute(AuthContext.SESSION_REQUEST_KEY);
        return ApiResponse.ok(orgService.buildOrgTree(session.orgId()));
    }
}
