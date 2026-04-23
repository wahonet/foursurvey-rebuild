package cn.foursurvey.backend.menu.model;

public record MenuFlatView(
        Long id,
        Long parentId,
        String menuCode,
        String menuName,
        String routePath,
        String iconName,
        Integer sortNo) {
}
