package cn.foursurvey.backend.receive.model;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class ReceiveBatchDetail {

    private Long id;
    private String batchNo;
    private String batchName;
    private String receiveSource;
    private String packageName;
    private String packagePath;
    private Integer recordCount;
    private String receiveStatus;
    private String receiveOrgName;
    private String operatorName;
    private LocalDateTime receivedAt;
    private String remark;
    private List<ReceiveRecordView> records = new ArrayList<>();

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getBatchNo() {
        return batchNo;
    }

    public void setBatchNo(String batchNo) {
        this.batchNo = batchNo;
    }

    public String getBatchName() {
        return batchName;
    }

    public void setBatchName(String batchName) {
        this.batchName = batchName;
    }

    public String getReceiveSource() {
        return receiveSource;
    }

    public void setReceiveSource(String receiveSource) {
        this.receiveSource = receiveSource;
    }

    public String getPackageName() {
        return packageName;
    }

    public void setPackageName(String packageName) {
        this.packageName = packageName;
    }

    public String getPackagePath() {
        return packagePath;
    }

    public void setPackagePath(String packagePath) {
        this.packagePath = packagePath;
    }

    public Integer getRecordCount() {
        return recordCount;
    }

    public void setRecordCount(Integer recordCount) {
        this.recordCount = recordCount;
    }

    public String getReceiveStatus() {
        return receiveStatus;
    }

    public void setReceiveStatus(String receiveStatus) {
        this.receiveStatus = receiveStatus;
    }

    public String getReceiveOrgName() {
        return receiveOrgName;
    }

    public void setReceiveOrgName(String receiveOrgName) {
        this.receiveOrgName = receiveOrgName;
    }

    public String getOperatorName() {
        return operatorName;
    }

    public void setOperatorName(String operatorName) {
        this.operatorName = operatorName;
    }

    public LocalDateTime getReceivedAt() {
        return receivedAt;
    }

    public void setReceivedAt(LocalDateTime receivedAt) {
        this.receivedAt = receivedAt;
    }

    public String getRemark() {
        return remark;
    }

    public void setRemark(String remark) {
        this.remark = remark;
    }

    public List<ReceiveRecordView> getRecords() {
        return records;
    }

    public void setRecords(List<ReceiveRecordView> records) {
        this.records = records == null ? new ArrayList<>() : records;
    }
}
