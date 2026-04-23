package cn.foursurvey.backend.receive.model;

import java.time.LocalDateTime;

public record ReceiveBatchListItem(
        Long id,
        String batchNo,
        String batchName,
        String receiveSource,
        Integer recordCount,
        String receiveStatus,
        String receiveOrgName,
        String operatorName,
        LocalDateTime receivedAt) {
}
