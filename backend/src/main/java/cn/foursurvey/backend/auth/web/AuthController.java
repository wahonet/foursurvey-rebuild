package cn.foursurvey.backend.auth.web;

import cn.foursurvey.backend.auth.model.AuthSession;
import cn.foursurvey.backend.auth.model.CurrentUserPayload;
import cn.foursurvey.backend.auth.model.LoginRequest;
import cn.foursurvey.backend.auth.model.LoginResponse;
import cn.foursurvey.backend.auth.service.AuthService;
import cn.foursurvey.backend.auth.support.AuthContext;
import cn.foursurvey.backend.common.api.ApiResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/login")
    public ApiResponse<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        return ApiResponse.ok(authService.login(request));
    }

    @GetMapping("/me")
    public ApiResponse<CurrentUserPayload> currentUser(HttpServletRequest request) {
        AuthSession session = (AuthSession) request.getAttribute(AuthContext.SESSION_REQUEST_KEY);
        return ApiResponse.ok(authService.currentUser(session));
    }
}
