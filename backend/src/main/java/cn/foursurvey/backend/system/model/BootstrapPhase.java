package cn.foursurvey.backend.system.model;

public record BootstrapPhase(
        String key,
        String name,
        String status,
        String summary) {
}
