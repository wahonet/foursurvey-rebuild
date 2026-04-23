package cn.foursurvey.backend.org.model;

import java.util.ArrayList;
import java.util.List;

public class OrgNodeView {

    private final Long id;
    private final Long parentId;
    private final String orgCode;
    private final String orgName;
    private final String orgType;
    private final String regionCode;
    private final Integer sortNo;
    private final List<OrgNodeView> children = new ArrayList<>();

    public OrgNodeView(Long id, Long parentId, String orgCode, String orgName, String orgType, String regionCode, Integer sortNo) {
        this.id = id;
        this.parentId = parentId;
        this.orgCode = orgCode;
        this.orgName = orgName;
        this.orgType = orgType;
        this.regionCode = regionCode;
        this.sortNo = sortNo;
    }

    public Long getId() {
        return id;
    }

    public Long getParentId() {
        return parentId;
    }

    public String getOrgCode() {
        return orgCode;
    }

    public String getOrgName() {
        return orgName;
    }

    public String getOrgType() {
        return orgType;
    }

    public String getRegionCode() {
        return regionCode;
    }

    public Integer getSortNo() {
        return sortNo;
    }

    public List<OrgNodeView> getChildren() {
        return children;
    }
}
