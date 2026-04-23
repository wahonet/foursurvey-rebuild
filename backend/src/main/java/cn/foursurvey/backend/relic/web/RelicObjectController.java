package cn.foursurvey.backend.relic.web;

import cn.foursurvey.backend.common.api.ApiResponse;
import cn.foursurvey.backend.relic.model.RelicObjectListItem;
import cn.foursurvey.backend.relic.service.RelicObjectService;
import java.util.List;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/relic-objects")
public class RelicObjectController {

    private final RelicObjectService relicObjectService;

    public RelicObjectController(RelicObjectService relicObjectService) {
        this.relicObjectService = relicObjectService;
    }

    @GetMapping
    public ApiResponse<List<RelicObjectListItem>> list(
            @RequestParam(required = false) String keyword) {
        return ApiResponse.ok(relicObjectService.findLatest(keyword));
    }
}
