package cn.foursurvey.backend.receive.persistence;

import cn.foursurvey.backend.receive.model.ReceiveBatchDetail;
import cn.foursurvey.backend.receive.model.ReceiveBatchListItem;
import cn.foursurvey.backend.receive.model.ReceiveRecordView;
import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface ReceiveBatchMapper {

    @Select("""
            SELECT
              b.id,
              b.batch_no,
              b.batch_name,
              b.receive_source,
              b.record_count,
              b.receive_status,
              o.org_name AS receive_org_name,
              u.display_name AS operator_name,
              b.received_at
            FROM fs_receive_batch b
            LEFT JOIN sys_org o ON o.id = b.receive_org_id
            LEFT JOIN sys_user u ON u.id = b.operator_id
            ORDER BY b.received_at DESC, b.id DESC
            LIMIT 20
            """)
    List<ReceiveBatchListItem> findLatest();

    @Select("""
            SELECT
              b.id,
              b.batch_no,
              b.batch_name,
              b.receive_source,
              b.package_name,
              b.package_path,
              b.record_count,
              b.receive_status,
              o.org_name AS receive_org_name,
              u.display_name AS operator_name,
              b.received_at,
              b.remark
            FROM fs_receive_batch b
            LEFT JOIN sys_org o ON o.id = b.receive_org_id
            LEFT JOIN sys_user u ON u.id = b.operator_id
            WHERE b.id = #{id}
            LIMIT 1
            """)
    ReceiveBatchDetail findDetailById(@Param("id") Long id);

    @Select("""
            SELECT
              id,
              record_no,
              survey_type,
              object_name,
              category_code,
              region_code,
              address_text,
              receive_status,
              operator_name,
              operated_at
            FROM fs_receive_record
            WHERE batch_id = #{batchId}
            ORDER BY id ASC
            """)
    List<ReceiveRecordView> findRecordsByBatchId(@Param("batchId") Long batchId);
}
