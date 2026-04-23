package cn.foursurvey.backend.menu.persistence;

import cn.foursurvey.backend.menu.model.MenuFlatView;
import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface MenuMapper {

    @Select("""
            SELECT DISTINCT
              m.id,
              m.parent_id,
              m.menu_code,
              m.menu_name,
              m.route_path,
              m.icon_name,
              m.sort_no
            FROM sys_menu m
            INNER JOIN sys_role_menu rm ON rm.menu_id = m.id
            INNER JOIN sys_user_role ur ON ur.role_id = rm.role_id
            WHERE ur.user_id = #{userId}
              AND m.enabled = 1
              AND m.deleted = 0
            ORDER BY m.sort_no ASC, m.id ASC
            """)
    List<MenuFlatView> findCurrentMenus(@Param("userId") Long userId);
}
