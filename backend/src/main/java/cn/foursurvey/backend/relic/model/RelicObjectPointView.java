package cn.foursurvey.backend.relic.model;

public record RelicObjectPointView(
        Long id,
        String pointType,
        Double longitude,
        Double latitude,
        Double altitude,
        String coordinateSystem,
        String sourceType) {
}
