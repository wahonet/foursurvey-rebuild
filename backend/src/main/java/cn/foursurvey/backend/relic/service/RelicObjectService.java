package cn.foursurvey.backend.relic.service;

import cn.foursurvey.backend.relic.model.RelicObjectListItem;
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
}
