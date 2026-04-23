package cn.foursurvey.backend.receive.web;

import cn.foursurvey.backend.common.api.ApiResponse;
import cn.foursurvey.backend.receive.model.ReceiveBatchDetail;
import cn.foursurvey.backend.receive.model.ReceiveBatchListItem;
import cn.foursurvey.backend.receive.service.ReceiveBatchService;
import java.util.List;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/receive-batches")
public class ReceiveBatchController {

    private final ReceiveBatchService receiveBatchService;

    public ReceiveBatchController(ReceiveBatchService receiveBatchService) {
        this.receiveBatchService = receiveBatchService;
    }

    @GetMapping
    public ApiResponse<List<ReceiveBatchListItem>> list() {
        return ApiResponse.ok(receiveBatchService.findLatest());
    }

    @GetMapping("/{id}")
    public ApiResponse<ReceiveBatchDetail> detail(@PathVariable Long id) {
        return ApiResponse.ok(receiveBatchService.findDetail(id));
    }
}
