package cn.foursurvey.backend.system.model;

import java.util.List;

public record BootstrapPayload(
        String project,
        String currentPhase,
        String nextStep,
        String docsPath,
        List<BootstrapPhase> phases,
        List<BootstrapModule> modules) {
}
