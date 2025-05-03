// Score.java
package quiz.model;

import java.sql.Timestamp;

public class Score {
    private int scoreId;
    private int userId;
    private int historyId;
    private int totalScore;
    private Timestamp dateTaken;
    private int subjectId;
    private String username; // For joining with users table
    private String subjectName; // For joining with subjects table
    
    // Default constructor
    public Score() {
    }
    
    // Parameterized constructor
    public Score(int scoreId, int userId, int historyId, int totalScore, Timestamp dateTaken, int subjectId) {
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
    
    public int getSubjectId() {
        return subjectId;
    }
    
    public void setSubjectId(int subjectId) {
        this.subjectId = subjectId;
    }
    
    public String getUsername() {
        return username;
    }
    
    public void setUsername(String username) {
        this.username = username;
    }
    
    public String getSubjectName() {
        return subjectName;
    }
    
    public void setSubjectName(String subjectName) {
        this.subjectName = subjectName;
    }
}