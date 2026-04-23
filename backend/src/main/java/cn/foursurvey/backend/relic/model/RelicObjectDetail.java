package cn.foursurvey.backend.relic.model;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class RelicObjectDetail {

    private Long id;
    private String objectCode;
    private String objectName;
    private String sourceType;
    private String categoryCode;
    private String levelCode;
    private String surveyStatus;
    private String checkStatus;
    private String addressText;
    private String eraText;
    private String abstractText;
    private String currentUse;
    private String protectionScope;
    private String constructionControl;
    private String orgName;
    private LocalDateTime fillStartedAt;
    private LocalDateTime submittedAt;
    private List<RelicObjectPointView> points = new ArrayList<>();

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getObjectCode() {
        return objectCode;
    }

    public void setObjectCode(String objectCode) {
        this.objectCode = objectCode;
    }

    public String getObjectName() {
        return objectName;
    }

    public void setObjectName(String objectName) {
        this.objectName = objectName;
    }

    public String getSourceType() {
        return sourceType;
    }

    public void setSourceType(String sourceType) {
        this.sourceType = sourceType;
    }

    public String getCategoryCode() {
        return categoryCode;
    }

    public void setCategoryCode(String categoryCode) {
        this.categoryCode = categoryCode;
    }

    public String getLevelCode() {
        return levelCode;
    }

    public void setLevelCode(String levelCode) {
        this.levelCode = levelCode;
    }

    public String getSurveyStatus() {
        return surveyStatus;
    }

    public void setSurveyStatus(String surveyStatus) {
        this.surveyStatus = surveyStatus;
    }

    public String getCheckStatus() {
        return checkStatus;
    }

    public void setCheckStatus(String checkStatus) {
        this.checkStatus = checkStatus;
    }

    public String getAddressText() {
        return addressText;
    }

    public void setAddressText(String addressText) {
        this.addressText = addressText;
    }

    public String getEraText() {
        return eraText;
    }

    public void setEraText(String eraText) {
        this.eraText = eraText;
    }

    public String getAbstractText() {
        return abstractText;
    }

    public void setAbstractText(String abstractText) {
        this.abstractText = abstractText;
    }

    public String getCurrentUse() {
        return currentUse;
    }

    public void setCurrentUse(String currentUse) {
        this.currentUse = currentUse;
    }

    public String getProtectionScope() {
        return protectionScope;
    }

    public void setProtectionScope(String protectionScope) {
        this.protectionScope = protectionScope;
    }

    public String getConstructionControl() {
        return constructionControl;
    }

    public void setConstructionControl(String constructionControl) {
        this.constructionControl = constructionControl;
    }

    public String getOrgName() {
        return orgName;
    }

    public void setOrgName(String orgName) {
        this.orgName = orgName;
    }

    public LocalDateTime getFillStartedAt() {
        return fillStartedAt;
    }

    public void setFillStartedAt(LocalDateTime fillStartedAt) {
        this.fillStartedAt = fillStartedAt;
    }

    public LocalDateTime getSubmittedAt() {
        return submittedAt;
    }

    public void setSubmittedAt(LocalDateTime submittedAt) {
        this.submittedAt = submittedAt;
    }

    public List<RelicObjectPointView> getPoints() {
        return points;
    }

    public void setPoints(List<RelicObjectPointView> points) {
        this.points = points == null ? new ArrayList<>() : points;
    }
}
