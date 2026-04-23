package cn.foursurvey.backend.dict.web;

import cn.foursurvey.backend.common.api.ApiResponse;
import cn.foursurvey.backend.dict.model.DictItemView;
import cn.foursurvey.backend.dict.service.DictService;
import java.util.List;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/dicts")
public class DictController {

    private final DictService dictService;

    public DictController(DictService dictService) {
        this.dictService = dictService;
    }

    @GetMapping("/{dictCode}/items")
    public ApiResponse<List<DictItemView>> findItems(@PathVariable String dictCode) {
        return ApiResponse.ok(dictService.findItemsByCode(dictCode));
    }
}
