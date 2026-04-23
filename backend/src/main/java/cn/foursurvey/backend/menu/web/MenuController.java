package cn.foursurvey.backend.menu.web;

import cn.foursurvey.backend.auth.model.AuthSession;
import cn.foursurvey.backend.auth.support.AuthContext;
import cn.foursurvey.backend.common.api.ApiResponse;
import cn.foursurvey.backend.menu.model.MenuNodeView;
import cn.foursurvey.backend.menu.service.MenuService;
import jakarta.servlet.http.HttpServletRequest;
import java.util.List;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/menus")
public class MenuController {

    private final MenuService menuService;

    public MenuController(MenuService menuService) {
        this.menuService = menuService;
    }

    @GetMapping("/current")
    public ApiResponse<List<MenuNodeView>> currentMenus(HttpServletRequest request) {
        AuthSession session = (AuthSession) request.getAttribute(AuthContext.SESSION_REQUEST_KEY);
        return ApiResponse.ok(menuService.findCurrentMenus(session.userId()));
    }
}
