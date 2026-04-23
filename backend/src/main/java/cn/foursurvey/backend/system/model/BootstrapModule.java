package cn.foursurvey.backend.system.model;

public record BootstrapModule(
        String code,
        String name,
        String priority,
        String owner) {
}
