package cn.foursurvey.backend.auth.service;

import cn.foursurvey.backend.auth.model.AuthRoleView;
import cn.foursurvey.backend.auth.model.AuthSession;
import cn.foursurvey.backend.auth.model.CurrentUserPayload;
import cn.foursurvey.backend.auth.model.LoginRequest;
import cn.foursurvey.backend.auth.model.LoginResponse;
import cn.foursurvey.backend.auth.model.LoginUserRecord;
import cn.foursurvey.backend.auth.persistence.AuthMapper;
import cn.foursurvey.backend.common.exception.ApiException;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
public class AuthService {

    private final AuthMapper authMapper;
    private final PasswordHasher passwordHasher;
    private final AuthTokenService authTokenService;

    public AuthService(
            AuthMapper authMapper,
            PasswordHasher passwordHasher,
            AuthTokenService authTokenService) {
        this.authMapper = authMapper;
        this.passwordHasher = passwordHasher;
        this.authTokenService = authTokenService;
    }

    public LoginResponse login(LoginRequest request) {
        LoginUserRecord user = authMapper.findByUsername(request.username().trim());
        if (user == null) {
            throw new ApiException(401, "用户名或密码错误");
        }

        if (!"ACTIVE".equalsIgnoreCase(user.accountStatus()) || user.enabled() == null || user.enabled() != 1) {
            throw new ApiException(403, "账号已被禁用");
        }

        if (!StringUtils.hasText(user.passwordSalt()) || !StringUtils.hasText(user.passwordHash())) {
            throw new ApiException(500, "账号密码配置不完整");
        }

        if (!passwordHasher.matches(request.password(), user.passwordSalt(), user.passwordHash())) {
            throw new ApiException(401, "用户名或密码错误");
        }

        List<AuthRoleView> roles = authMapper.findRolesByUserId(user.id());
        AuthSession session = authTokenService.createSession(
                user.id(),
                user.username(),
                user.displayName(),
                user.orgId(),
                user.orgName(),
                roles);

        return new LoginResponse(
                "Bearer",
                session.token(),
                session.expiresAt(),
                toCurrentUser(session));
    }

    public CurrentUserPayload currentUser(AuthSession session) {
        return toCurrentUser(session);
    }

    private CurrentUserPayload toCurrentUser(AuthSession session) {
        return new CurrentUserPayload(
                session.userId(),
                session.username(),
                session.displayName(),
                session.orgId(),
                session.orgName(),
                session.roles(),
                session.expiresAt());
    }
}
