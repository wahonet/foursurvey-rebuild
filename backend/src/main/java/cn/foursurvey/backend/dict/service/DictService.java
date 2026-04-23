package cn.foursurvey.backend.dict.service;

import cn.foursurvey.backend.dict.model.DictItemView;
import cn.foursurvey.backend.dict.persistence.DictMapper;
import java.util.List;
import org.springframework.stereotype.Service;

@Service
public class DictService {

    private final DictMapper dictMapper;

    public DictService(DictMapper dictMapper) {
        this.dictMapper = dictMapper;
    }

    public List<DictItemView> findItemsByCode(String dictCode) {
        return dictMapper.findItemsByDictCode(dictCode);
    }
}
