package cn.foursurvey.backend.org.service;

import cn.foursurvey.backend.org.model.OrgFlatView;
import cn.foursurvey.backend.org.model.OrgNodeView;
import cn.foursurvey.backend.org.model.OrgTreePayload;
import cn.foursurvey.backend.org.persistence.OrgMapper;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Service;

@Service
public class OrgService {

    private final OrgMapper orgMapper;

    public OrgService(OrgMapper orgMapper) {
        this.orgMapper = orgMapper;
    }

    public OrgTreePayload buildOrgTree(Long currentOrgId) {
        List<OrgFlatView> rows = orgMapper.findAllEnabled();
        Map<Long, OrgNodeView> nodeMap = new LinkedHashMap<>();
        List<OrgNodeView> roots = new ArrayList<>();

        for (OrgFlatView row : rows) {
            nodeMap.put(row.id(), new OrgNodeView(
                    row.id(),
                    row.parentId(),
                    row.orgCode(),
                    row.orgName(),
                    row.orgType(),
                    row.regionCode(),
                    row.sortNo()));
        }

        for (OrgNodeView node : nodeMap.values()) {
            if (node.getParentId() == null || !nodeMap.containsKey(node.getParentId())) {
                roots.add(node);
                continue;
            }
            nodeMap.get(node.getParentId()).getChildren().add(node);
        }

        sortTree(roots);
        return new OrgTreePayload(currentOrgId, roots);
    }

    private void sortTree(List<OrgNodeView> nodes) {
        nodes.sort(Comparator.comparing(OrgNodeView::getSortNo).thenComparing(OrgNodeView::getId));
        for (OrgNodeView node : nodes) {
            sortTree(node.getChildren());
        }
    }
}
