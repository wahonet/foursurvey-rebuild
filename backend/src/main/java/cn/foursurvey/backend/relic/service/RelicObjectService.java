package cn.foursurvey.backend.relic.service;

import cn.foursurvey.backend.common.exception.ApiException;
import cn.foursurvey.backend.relic.model.RelicObjectDetail;
import cn.foursurvey.backend.relic.model.RelicObjectListItem;
import cn.foursurvey.backend.relic.model.RelicObjectPointView;
import cn.foursurvey.backend.relic.persistence.RelicObjectMapper;
import java.util.List;
import org.springframework.stereotype.Service;

@Service
public class RelicObjectService {

    private final RelicObjectMapper relicObjectMapper;

    public RelicObjectService(RelicObjectMapper relicObjectMapper) {
        this.relicObjectMapper = relicObjectMapper;
    }

    public List<RelicObjectListItem> findLatest(String keyword) {
        return relicObjectMapper.findLatest(keyword);
    }

    public RelicObjectDetail findDetail(Long id) {
        RelicObjectDetail detail = relicObjectMapper.findDetailById(id);
        if (detail == null) {
            throw new ApiException(404, "对象详情不存在");
        }

        List<RelicObjectPointView> points = relicObjectMapper.findPointsByObjectId(id);
        detail.setPoints(points);
        return detail;
    }
}
