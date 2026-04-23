package cn.foursurvey.backend.receive.service;

import cn.foursurvey.backend.auth.model.AuthSession;
import cn.foursurvey.backend.common.exception.ApiException;
import cn.foursurvey.backend.receive.model.ReceiveBatchDetail;
import cn.foursurvey.backend.receive.model.ReceiveBatchListItem;
import cn.foursurvey.backend.receive.model.ReceiveBatchProcessRequest;
import cn.foursurvey.backend.receive.model.ReceiveRecordView;
import cn.foursurvey.backend.receive.persistence.ReceiveBatchMapper;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ReceiveBatchService {

    private final ReceiveBatchMapper receiveBatchMapper;

    public ReceiveBatchService(ReceiveBatchMapper receiveBatchMapper) {
        this.receiveBatchMapper = receiveBatchMapper;
    }

    public List<ReceiveBatchListItem> findLatest() {
        return receiveBatchMapper.findLatest();
    }

    public ReceiveBatchDetail findDetail(Long id) {
        ReceiveBatchDetail detail = receiveBatchMapper.findDetailById(id);
        if (detail == null) {
            throw new ApiException(404, "接收批次不存在");
        }

        List<ReceiveRecordView> records = receiveBatchMapper.findRecordsByBatchId(id);
        detail.setRecords(records);
        return detail;
    }

    @Transactional
    public ReceiveBatchDetail process(Long id, ReceiveBatchProcessRequest request, AuthSession session) {
        ReceiveBatchDetail detail = receiveBatchMapper.findDetailById(id);
        if (detail == null) {
            throw new ApiException(404, "接收批次不存在");
        }

        String action = request.action().trim().toUpperCase();
        String nextStatus;
        String recordStatus;
        switch (action) {
            case "START_REVIEW" -> {
                nextStatus = "IN_REVIEW";
                recordStatus = "IN_REVIEW";
            }
            case "COMPLETE" -> {
                nextStatus = "PROCESSED";
                recordStatus = "PROCESSED";
            }
            case "RESET" -> {
                nextStatus = "IMPORTED";
                recordStatus = "IMPORTED";
            }
            default -> throw new ApiException(400, "不支持的处理动作: " + request.action());
        }

        String remark = request.remark() == null || request.remark().isBlank()
                ? detail.getRemark()
                : request.remark().trim();

        int updated = receiveBatchMapper.updateBatchStatus(id, nextStatus, remark, session.userId());
        if (updated < 1) {
            throw new ApiException(500, "接收批次处理失败");
        }

        receiveBatchMapper.updateRecordStatusByBatchId(id, recordStatus, session.displayName());
        return findDetail(id);
    }
}
