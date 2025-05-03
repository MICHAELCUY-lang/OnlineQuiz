package quiz.model;

import java.sql.Timestamp;

public class Score {
    private int scoreId;
    private int userId;
    private int historyId;
    private int totalScore;
    private Timestamp dateTaken;
    private Integer subjectId;
    
    public Score() {
    }
    
    public Score(int scoreId, int userId, int historyId, int totalScore, Timestamp dateTaken, Integer subjectId) {
        this.scoreId = scoreId;
        this.userId = userId;
        this.historyId = historyId;
        this.totalScore = totalScore;
        this.dateTaken = dateTaken;
        this.subjectId = subjectId;
    }
    
    // Getters and Setters
    public int getScoreId() {
        return scoreId;
    }
    
    public void setScoreId(int scoreId) {
        this.scoreId = scoreId;
    }
    
    public int getUserId() {
        return userId;
    }
    
    public void setUserId(int userId) {
        this.userId = userId;
    }
    
    public int getHistoryId() {
        return historyId;
    }
    
    public void setHistoryId(int historyId) {
        this.historyId = historyId;
    }
    
    public int getTotalScore() {
        return totalScore;
    }
    
    public void setTotalScore(int totalScore) {
        this.totalScore = totalScore;
    }
    
    public Timestamp getDateTaken() {
        return dateTaken;
    }
    
    public void setDateTaken(Timestamp dateTaken) {
        this.dateTaken = dateTaken;
    }
    
    public Integer getSubjectId() {
        return subjectId;
    }
    
    public void setSubjectId(Integer subjectId) {
        this.subjectId = subjectId;
    }
    
    @Override
    public String toString() {
        return "Score{" +
                "scoreId=" + scoreId +
                ", userId=" + userId +
                ", historyId=" + historyId +
                ", totalScore=" + totalScore +
                ", dateTaken=" + dateTaken +
                ", subjectId=" + subjectId +
                '}';
    }
}