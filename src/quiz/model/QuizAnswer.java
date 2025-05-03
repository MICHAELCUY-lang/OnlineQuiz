package quiz.model;

public class QuizAnswer {
    private int answerId;
    private int historyId;
    private int questionId;
    private int selectedOptionId;
    private boolean isCorrect;
    
    public QuizAnswer() {
    }
    
    public QuizAnswer(int answerId, int historyId, int questionId, int selectedOptionId, boolean isCorrect) {
        this.answerId = answerId;
        this.historyId = historyId;
        this.questionId = questionId;
        this.selectedOptionId = selectedOptionId;
        this.isCorrect = isCorrect;
    }
    
    // Getters and Setters
    public int getAnswerId() {
        return answerId;
    }
    
    public void setAnswerId(int answerId) {
        this.answerId = answerId;
    }
    
    public int getHistoryId() {
        return historyId;
    }
    
    public void setHistoryId(int historyId) {
        this.historyId = historyId;
    }
    
    public int getQuestionId() {
        return questionId;
    }
    
    public void setQuestionId(int questionId) {
        this.questionId = questionId;
    }
    
    public int getSelectedOptionId() {
        return selectedOptionId;
    }
    
    public void setSelectedOptionId(int selectedOptionId) {
        this.selectedOptionId = selectedOptionId;
    }
    
    public boolean isCorrect() {
        return isCorrect;
    }
    
    public void setCorrect(boolean isCorrect) {
        this.isCorrect = isCorrect;
    }
    
    @Override
    public String toString() {
        return "QuizAnswer{" +
                "answerId=" + answerId +
                ", historyId=" + historyId +
                ", questionId=" + questionId +
                ", selectedOptionId=" + selectedOptionId +
                ", isCorrect=" + isCorrect +
                '}';
    }
}