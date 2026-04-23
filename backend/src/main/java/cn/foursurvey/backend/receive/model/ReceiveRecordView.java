package cn.foursurvey.backend.receive.model;

import java.time.LocalDateTime;

public record ReceiveRecordView(
        Long id,
        String recordNo,
        String surveyType,
        String objectName,
        String categoryCode,
        String regionCode,
        String addressText,
        String receiveStatus,
        String operatorName,
        LocalDateTime operatedAt) {
}
