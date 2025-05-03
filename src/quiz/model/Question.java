// Question.java
package quiz.model;

import java.sql.Timestamp;

public class Question {
    private int questionId;
    private int subjectId;
    private String questionText;
    private String correctAnswer;
    private int createdBy;
    private Timestamp createdDate;
    private String subjectName; // For joining with subjects table
    
    // Default constructor
    public Question() {
    }
    
    // Parameterized constructor
    public Question(int questionId, int subjectId, String questionText, String correctAnswer, 
                   int createdBy, Timestamp createdDate) {
        this.questionId = questionId;
        this.subjectId = subjectId;
        this.questionText = questionText;
        this.correctAnswer = correctAnswer;
        this.createdBy = createdBy;
        this.createdDate = createdDate;
    }
    
    // Getters and Setters
    public int getQuestionId() {
        return questionId;
    }
    
    public void setQuestionId(int questionId) {
        this.questionId = questionId;
    }
    
    public int getSubjectId() {
        return subjectId;
    }
    
    public void setSubjectId(int subjectId) {
        this.subjectId = subjectId;
    }
    
    public String getQuestionText() {
        return questionText;
    }
    
    public void setQuestionText(String questionText) {
        this.questionText = questionText;
    }
    
    public String getCorrectAnswer() {
        return correctAnswer;
    }
    
    public void setCorrectAnswer(String correctAnswer) {
        this.correctAnswer = correctAnswer;
    }
    
    public int getCreatedBy() {
        return createdBy;
    }
    
    public void setCreatedBy(int createdBy) {
        this.createdBy = createdBy;
    }
    
    public Timestamp getCreatedDate() {
        return createdDate;
    }
    
    public void setCreatedDate(Timestamp createdDate) {
        this.createdDate = createdDate;
    }
    
    public String getSubjectName() {
        return subjectName;
    }
    
    public void setSubjectName(String subjectName) {
        this.subjectName = subjectName;
    }
}