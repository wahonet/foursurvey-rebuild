package cn.foursurvey.backend.auth.support;

import cn.foursurvey.backend.auth.model.AuthSession;
import cn.foursurvey.backend.auth.service.AuthTokenService;
import cn.foursurvey.backend.common.exception.ApiException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.servlet.HandlerInterceptor;

@Component
public class AuthInterceptor implements HandlerInterceptor {

    private final AuthTokenService authTokenService;

    public AuthInterceptor(AuthTokenService authTokenService) {
        this.authTokenService = authTokenService;
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            return true;
        }

        String authorization = request.getHeader("Authorization");
        if (!StringUtils.hasText(authorization) || !authorization.startsWith("Bearer ")) {
            throw new ApiException(401, "未登录或登录已失效");
        }

        String token = authorization.substring(7).trim();
        if (!StringUtils.hasText(token)) {
            throw new ApiException(401, "未登录或登录已失效");
        }

        AuthSession session = authTokenService.requireValidSession(token);
        request.setAttribute(AuthContext.SESSION_REQUEST_KEY, session);
        return true;
    }
}
