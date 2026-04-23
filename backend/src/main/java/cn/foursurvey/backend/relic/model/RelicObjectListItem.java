package cn.foursurvey.backend.relic.model;

public record RelicObjectListItem(
        Long id,
        String objectCode,
        String objectName,
        String sourceType,
        String categoryCode,
        String surveyStatus,
        String checkStatus,
        String addressText,
        String orgName) {
}
