package cn.foursurvey.backend.org.model;

public record OrgFlatView(
        Long id,
        Long parentId,
        String orgCode,
        String orgName,
        String orgType,
        String regionCode,
        Integer sortNo) {
}
