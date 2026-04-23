package cn.foursurvey.backend.menu.service;

import cn.foursurvey.backend.menu.model.MenuFlatView;
import cn.foursurvey.backend.menu.model.MenuNodeView;
import cn.foursurvey.backend.menu.persistence.MenuMapper;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Service;

@Service
public class MenuService {

    private final MenuMapper menuMapper;

    public MenuService(MenuMapper menuMapper) {
        this.menuMapper = menuMapper;
    }

    public List<MenuNodeView> findCurrentMenus(Long userId) {
        List<MenuFlatView> rows = menuMapper.findCurrentMenus(userId);
        Map<Long, MenuNodeView> nodeMap = new LinkedHashMap<>();
        List<MenuNodeView> roots = new ArrayList<>();

        for (MenuFlatView row : rows) {
            nodeMap.put(row.id(), new MenuNodeView(
                    row.id(),
                    row.parentId(),
                    row.menuCode(),
                    row.menuName(),
                    row.routePath(),
                    row.iconName(),
                    row.sortNo()));
        }

        for (MenuNodeView node : nodeMap.values()) {
            if (node.getParentId() == null || !nodeMap.containsKey(node.getParentId())) {
                roots.add(node);
                continue;
            }
            nodeMap.get(node.getParentId()).getChildren().add(node);
        }

        sortTree(roots);
        return roots;
    }

    private void sortTree(List<MenuNodeView> nodes) {
        nodes.sort(Comparator.comparing(MenuNodeView::getSortNo).thenComparing(MenuNodeView::getId));
        for (MenuNodeView node : nodes) {
            sortTree(node.getChildren());
        }
    }
}
