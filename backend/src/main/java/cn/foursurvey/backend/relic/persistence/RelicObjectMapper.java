package cn.foursurvey.backend.relic.persistence;

import cn.foursurvey.backend.relic.model.RelicObjectDetail;
import cn.foursurvey.backend.relic.model.RelicObjectListItem;
import cn.foursurvey.backend.relic.model.RelicObjectPointView;
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

    @Select("""
            SELECT
              r.id,
              r.object_code,
              r.object_name,
              r.source_type,
              r.category_code,
              r.level_code,
              r.survey_status,
              r.check_status,
              r.address_text,
              r.era_text,
              r.abstract_text,
              r.current_use,
              r.protection_scope,
              r.construction_control,
              o.org_name,
              r.fill_started_at,
              r.submitted_at
            FROM fs_relic_object r
            LEFT JOIN sys_org o ON o.id = r.org_id
            WHERE r.id = #{id}
            LIMIT 1
            """)
    RelicObjectDetail findDetailById(@Param("id") Long id);

    @Select("""
            SELECT
              id,
              point_type,
              longitude,
              latitude,
              altitude,
              coordinate_system,
              source_type
            FROM fs_relic_point
            WHERE relic_object_id = #{relicObjectId}
            ORDER BY id ASC
            """)
    List<RelicObjectPointView> findPointsByObjectId(@Param("relicObjectId") Long relicObjectId);
}
