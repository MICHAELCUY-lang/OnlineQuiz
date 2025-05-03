package quiz.model;

import java.sql.Timestamp;

public class ChartData {
    private int chartId;
    private Integer userId;
    private Integer subjectId;
    private String dataType;
    private float dataValue;
    private String dataLabel;
    private Timestamp dataDate;
    
    public ChartData() {
    }
    
    public ChartData(int chartId, Integer userId, Integer subjectId, String dataType, 
                     float dataValue, String dataLabel, Timestamp dataDate) {
        this.chartId = chartId;
        this.userId = userId;
        this.subjectId = subjectId;
        this.dataType = dataType;
        this.dataValue = dataValue;
        this.dataLabel = dataLabel;
        this.dataDate = dataDate;
    }
    
    // Getters and Setters
    public int getChartId() {
        return chartId;
    }
    
    public void setChartId(int chartId) {
        this.chartId = chartId;
    }
    
    public Integer getUserId() {
        return userId;
    }
    
    public void setUserId(Integer userId) {
        this.userId = userId;
    }
    
    public Integer getSubjectId() {
        return subjectId;
    }
    
    public void setSubjectId(Integer subjectId) {
        this.subjectId = subjectId;
    }
    
    public String getDataType() {
        return dataType;
    }
    
    public void setDataType(String dataType) {
        this.dataType = dataType;
    }
    
    public float getDataValue() {
        return dataValue;
    }
    
    public void setDataValue(float dataValue) {
        this.dataValue = dataValue;
    }
    
    public String getDataLabel() {
        return dataLabel;
    }
    
    public void setDataLabel(String dataLabel) {
        this.dataLabel = dataLabel;
    }
    
    public Timestamp getDataDate() {
        return dataDate;
    }
    
    public void setDataDate(Timestamp dataDate) {
        this.dataDate = dataDate;
    }
    
    @Override
    public String toString() {
        return "ChartData{" +
                "chartId=" + chartId +
                ", userId=" + userId +
                ", subjectId=" + subjectId +
                ", dataType='" + dataType + '\'' +
                ", dataValue=" + dataValue +
                ", dataLabel='" + dataLabel + '\'' +
                ", dataDate=" + dataDate +
                '}';
    }
}