package cn.foursurvey.backend.auth.model;

public record LoginUserRecord(
        Long id,
        Long orgId,
        String orgName,
        String username,
        String displayName,
        String passwordHash,
        String passwordSalt,
        String accountStatus,
        Integer enabled) {
}
