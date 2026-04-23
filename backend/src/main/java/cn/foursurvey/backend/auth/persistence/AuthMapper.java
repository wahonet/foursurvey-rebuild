package cn.foursurvey.backend.auth.persistence;

import cn.foursurvey.backend.auth.model.AuthRoleView;
import cn.foursurvey.backend.auth.model.LoginUserRecord;
import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface AuthMapper {

    @Select("""
            SELECT
              u.id,
              u.org_id,
              o.org_name,
              u.username,
              u.display_name,
              u.password_hash,
              u.password_salt,
              u.account_status,
              u.enabled
            FROM sys_user u
            LEFT JOIN sys_org o ON o.id = u.org_id
            WHERE u.username = #{username}
              AND u.deleted = 0
            LIMIT 1
            """)
    LoginUserRecord findByUsername(@Param("username") String username);

    @Select("""
            SELECT
              r.id,
              r.role_code AS code,
              r.role_name AS name
            FROM sys_user_role ur
            INNER JOIN sys_role r ON r.id = ur.role_id
            WHERE ur.user_id = #{userId}
            ORDER BY r.sort_no ASC, r.id ASC
            """)
    List<AuthRoleView> findRolesByUserId(@Param("userId") Long userId);
}
