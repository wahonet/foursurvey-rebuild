package cn.foursurvey.backend.receive.service;

import cn.foursurvey.backend.common.exception.ApiException;
import cn.foursurvey.backend.receive.model.ReceiveBatchDetail;
import cn.foursurvey.backend.receive.model.ReceiveBatchListItem;
import cn.foursurvey.backend.receive.model.ReceiveRecordView;
import cn.foursurvey.backend.receive.persistence.ReceiveBatchMapper;
import java.util.List;
import org.springframework.stereotype.Service;

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
}
