package cn.foursurvey.backend.dict.model;

public record DictItemView(
        Long id,
        String itemCode,
        String itemName,
        String itemValue,
        Integer sortNo) {
}
