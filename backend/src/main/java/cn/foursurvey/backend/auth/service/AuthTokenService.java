package cn.foursurvey.backend.auth.service;

import cn.foursurvey.backend.auth.model.AuthSession;
import cn.foursurvey.backend.common.exception.ApiException;
import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class AuthTokenService {

    private final Map<String, AuthSession> sessions = new ConcurrentHashMap<>();
    private final SecureRandom secureRandom = new SecureRandom();

    @Value("${app.auth.token-expire-hours:8}")
    private long tokenExpireHours;

    public AuthSession createSession(
            Long userId,
            String username,
            String displayName,
            Long orgId,
            String orgName,
            java.util.List<cn.foursurvey.backend.auth.model.AuthRoleView> roles) {

        String token = generateToken();
        LocalDateTime expiresAt = LocalDateTime.now().plusHours(tokenExpireHours);
        AuthSession session = new AuthSession(token, userId, username, displayName, orgId, orgName, roles, expiresAt);
        sessions.put(token, session);
        return session;
    }

    public AuthSession requireValidSession(String token) {
        AuthSession session = sessions.get(token);
        if (session == null) {
            throw new ApiException(401, "未登录或登录已失效");
        }

        if (session.expiresAt().isBefore(LocalDateTime.now())) {
            sessions.remove(token);
            throw new ApiException(401, "登录已过期，请重新登录");
        }

        return session;
    }

    public void remove(String token) {
        sessions.remove(token);
    }

    private String generateToken() {
        byte[] bytes = new byte[32];
        secureRandom.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }
}
