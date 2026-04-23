package cn.foursurvey.backend.auth.model;

import java.time.LocalDateTime;

public record LoginResponse(
        String tokenType,
        String accessToken,
        LocalDateTime expiresAt,
        CurrentUserPayload user) {
}
