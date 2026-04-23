package cn.foursurvey.backend.dict.persistence;

import cn.foursurvey.backend.dict.model.DictItemView;
import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface DictMapper {

    @Select("""
            SELECT
              i.id,
              i.item_code,
              i.item_name,
              i.item_value,
              i.sort_no
            FROM base_dict_item i
            INNER JOIN base_dict_type t ON t.id = i.dict_type_id
            WHERE t.dict_code = #{dictCode}
              AND t.enabled = 1
              AND i.enabled = 1
            ORDER BY i.sort_no ASC, i.id ASC
            """)
    List<DictItemView> findItemsByDictCode(@Param("dictCode") String dictCode);
}
