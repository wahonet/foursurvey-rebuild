package cn.foursurvey.backend.org.persistence;

import cn.foursurvey.backend.org.model.OrgFlatView;
import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface OrgMapper {

    @Select("""
            SELECT
              id,
              parent_id,
              org_code,
              org_name,
              org_type,
              region_code,
              sort_no
            FROM sys_org
            WHERE enabled = 1
              AND deleted = 0
            ORDER BY sort_no ASC, id ASC
            """)
    List<OrgFlatView> findAllEnabled();
}
