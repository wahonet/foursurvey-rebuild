package cn.foursurvey.backend.receive.model;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record ReceiveBatchProcessRequest(
        @NotBlank(message = "处理动作不能为空")
        String action,

        @Size(max = 500, message = "备注不能超过500个字符")
        String remark) {
}
