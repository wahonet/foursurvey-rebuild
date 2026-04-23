package cn.foursurvey.backend.relic.model;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record RelicObjectUpdateRequest(
        @NotBlank(message = "对象名称不能为空")
        @Size(max = 200, message = "对象名称不能超过200个字符")
        String objectName,

        @Size(max = 64, message = "类别编码不能超过64个字符")
        String categoryCode,

        @Size(max = 32, message = "普查状态不能超过32个字符")
        String surveyStatus,

        @Size(max = 32, message = "核查状态不能超过32个字符")
        String checkStatus,

        @Size(max = 500, message = "地址不能超过500个字符")
        String addressText,

        @Size(max = 100, message = "年代不能超过100个字符")
        String eraText,

        @Size(max = 200, message = "现状用途不能超过200个字符")
        String currentUse,

        String abstractText,
        String protectionScope,
        String constructionControl) {
}
