package cn.foursurvey.backend.auth.model;

import java.time.LocalDateTime;
import java.util.List;

public record AuthSession(
        String token,
        Long userId,
        String username,
        String displayName,
        Long orgId,
        String orgName,
        List<AuthRoleView> roles,
        LocalDateTime expiresAt) {
}
