package quiz.dao;

import quiz.model.QuizAnswer;
import quiz.model.QuizHistory;
import quiz.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class QuizHistoryDAO {
    
    // Create a new quiz history
    public boolean createQuizHistory(QuizHistory history) {
        String sql = "INSERT INTO quiz_history (user_id) VALUES (?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            pstmt.setInt(1, history.getUserId());
            
            int affectedRows = pstmt.executeUpdate();
            
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        history.setHistoryId(generatedKeys.getInt(1));
                        return true;
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    // End a quiz history (set end time)
    public boolean endQuizHistory(int historyId) {
        String sql = "UPDATE quiz_history SET end_time = CURRENT_TIMESTAMP WHERE history_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, historyId);
            
            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    // Add an answer to a quiz history
    public boolean addQuizAnswer(QuizAnswer answer) {
        String sql = "INSERT INTO quiz_answers (history_id, question_id, selected_option_id, is_correct) VALUES (?, ?, ?, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            pstmt.setInt(1, answer.getHistoryId());
            pstmt.setInt(2, answer.getQuestionId());
            pstmt.setInt(3, answer.getSelectedOptionId());
            pstmt.setBoolean(4, answer.isCorrect());
            
            int affectedRows = pstmt.executeUpdate();
            
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        answer.setAnswerId(generatedKeys.getInt(1));
                        return true;
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    // Get quiz history by ID with answers
    public QuizHistory getQuizHistoryById(int historyId) {
        String historySql = "SELECT * FROM quiz_history WHERE history_id = ?";
        String answersSql = "SELECT * FROM quiz_answers WHERE history_id = ?";
        
        QuizHistory history = null;
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmtHistory = conn.prepareStatement(historySql);
             PreparedStatement pstmtAnswers = conn.prepareStatement(answersSql)) {
            
            pstmtHistory.setInt(1, historyId);
            try (ResultSet rsHistory = pstmtHistory.executeQuery()) {
                if (rsHistory.next()) {
                    history = new QuizHistory();
                    history.setHistoryId(rsHistory.getInt("history_id"));
                    history.setUserId(rsHistory.getInt("user_id"));
                    history.setStartTime(rsHistory.getTimestamp("start_time"));
                    history.setEndTime(rsHistory.getTimestamp("end_time"));
                }
            }
            
            if (history != null) {
                pstmtAnswers.setInt(1, historyId);
                try (ResultSet rsAnswers = pstmtAnswers.executeQuery()) {
                    while (rsAnswers.next()) {
                        QuizAnswer answer = new QuizAnswer();
                        answer.setAnswerId(rsAnswers.getInt("answer_id"));
                        answer.setHistoryId(rsAnswers.getInt("history_id"));
                        answer.setQuestionId(rsAnswers.getInt("question_id"));
                        answer.setSelectedOptionId(rsAnswers.getInt("selected_option_id"));
                        answer.setCorrect(rsAnswers.getBoolean("is_correct"));
                        history.addAnswer(answer);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return history;
    }
    
    // Get all quiz histories for a user
    public List<QuizHistory> getQuizHistoriesByUser(int userId) {
        List<QuizHistory> histories = new ArrayList<>();
        String sql = "SELECT * FROM quiz_history WHERE user_id = ? ORDER BY start_time DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    QuizHistory history = new QuizHistory();
                    history.setHistoryId(rs.getInt("history_id"));
                    history.setUserId(rs.getInt("user_id"));
                    history.setStartTime(rs.getTimestamp("start_time"));
                    history.setEndTime(rs.getTimestamp("end_time"));
                    
                    // Get answers for this history
                    QuizHistory fullHistory = getQuizHistoryById(history.getHistoryId());
                    if (fullHistory != null) {
                        history.setAnswers(fullHistory.getAnswers());
                    }
                    
                    histories.add(history);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return histories;
    }
    
    // Get correct answer count for a quiz history
    public int getCorrectAnswerCount(int historyId) {
        String sql = "SELECT COUNT(*) FROM quiz_answers WHERE history_id = ? AND is_correct = TRUE";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, historyId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return 0;
    }
    
    // Get total question count for a quiz history
    public int getTotalQuestionCount(int historyId) {
        String sql = "SELECT COUNT(*) FROM quiz_answers WHERE history_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, historyId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return 0;
    }
}