package cn.foursurvey.backend.org.model;

import java.util.List;

public record OrgTreePayload(
        Long currentOrgId,
        List<OrgNodeView> nodes) {
}
