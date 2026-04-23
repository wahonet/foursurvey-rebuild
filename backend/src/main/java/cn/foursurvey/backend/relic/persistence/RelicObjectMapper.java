package cn.foursurvey.backend.relic.persistence;

import cn.foursurvey.backend.relic.model.RelicObjectListItem;
import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface RelicObjectMapper {

    @Select("""
            SELECT
              r.id,
              r.object_code,
              r.object_name,
              r.source_type,
              r.category_code,
              r.survey_status,
              r.check_status,
              r.address_text,
              o.org_name
            FROM fs_relic_object r
            LEFT JOIN sys_org o ON o.id = r.org_id
            WHERE (
                #{keyword} IS NULL
                OR #{keyword} = ''
                OR r.object_code LIKE CONCAT('%', #{keyword}, '%')
                OR r.object_name LIKE CONCAT('%', #{keyword}, '%')
            )
            ORDER BY r.updated_at DESC, r.id DESC
            LIMIT 50
            """)
    List<RelicObjectListItem> findLatest(@Param("keyword") String keyword);
}
