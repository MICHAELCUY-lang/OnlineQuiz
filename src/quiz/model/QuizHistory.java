package quiz.model;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class QuizHistory {
    private int historyId;
    private int userId;
    private Timestamp startTime;
    private Timestamp endTime;
    private List<QuizAnswer> answers;
    
    public QuizHistory() {
        this.answers = new ArrayList<>();
    }
    
    public QuizHistory(int historyId, int userId, Timestamp startTime, Timestamp endTime) {
        this.historyId = historyId;
        this.userId = userId;
        this.startTime = startTime;
        this.endTime = endTime;
        this.answers = new ArrayList<>();
    }
    
    // Getters and Setters
    public int getHistoryId() {
        return historyId;
    }
    
    public void setHistoryId(int historyId) {
        this.historyId = historyId;
    }
    
    public int getUserId() {
        return userId;
    }
    
    public void setUserId(int userId) {
        this.userId = userId;
    }
    
    public Timestamp getStartTime() {
        return startTime;
    }
    
    public void setStartTime(Timestamp startTime) {
        this.startTime = startTime;
    }
    
    public Timestamp getEndTime() {
        return endTime;
    }
    
    public void setEndTime(Timestamp endTime) {
        this.endTime = endTime;
    }
    
    public List<QuizAnswer> getAnswers() {
        return answers;
    }
    
    public void setAnswers(List<QuizAnswer> answers) {
        this.answers = answers;
    }
    
    public void addAnswer(QuizAnswer answer) {
        this.answers.add(answer);
    }
    
    @Override
    public String toString() {
        return "QuizHistory{" +
                "historyId=" + historyId +
                ", userId=" + userId +
                ", startTime=" + startTime +
                ", endTime=" + endTime +
                ", answers=" + answers +
                '}';
    }
}