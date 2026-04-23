package cn.foursurvey.backend.menu.model;

import java.util.ArrayList;
import java.util.List;

public class MenuNodeView {

    private final Long id;
    private final Long parentId;
    private final String menuCode;
    private final String menuName;
    private final String routePath;
    private final String iconName;
    private final Integer sortNo;
    private final List<MenuNodeView> children = new ArrayList<>();

    public MenuNodeView(Long id, Long parentId, String menuCode, String menuName, String routePath, String iconName, Integer sortNo) {
        this.id = id;
        this.parentId = parentId;
        this.menuCode = menuCode;
        this.menuName = menuName;
        this.routePath = routePath;
        this.iconName = iconName;
        this.sortNo = sortNo;
    }

    public Long getId() {
        return id;
    }

    public Long getParentId() {
        return parentId;
    }

    public String getMenuCode() {
        return menuCode;
    }

    public String getMenuName() {
        return menuName;
    }

    public String getRoutePath() {
        return routePath;
    }

    public String getIconName() {
        return iconName;
    }

    public Integer getSortNo() {
        return sortNo;
    }

    public List<MenuNodeView> getChildren() {
        return children;
    }
}
