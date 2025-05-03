package quiz.dao;

import quiz.model.QuizOption;
import quiz.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class QuizDAO {
    
    // Get options for a question
    public List<QuizOption> getOptionsForQuestion(int questionId) {
        List<QuizOption> options = new ArrayList<>();
        String sql = "SELECT * FROM quiz WHERE question_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, questionId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    QuizOption option = new QuizOption();
                    option.setQuizId(rs.getInt("quiz_id"));
                    option.setQuestionId(rs.getInt("question_id"));
                    option.setOptionText(rs.getString("option_text"));
                    option.setCorrect(rs.getBoolean("is_correct"));
                    options.add(option);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return options;
    }
    
    // Add options for a question
    public boolean addOptionsForQuestion(int questionId, List<QuizOption> options) {
        String sql = "INSERT INTO quiz (question_id, option_text, is_correct) VALUES (?, ?, ?)";
        
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                for (QuizOption option : options) {
                    pstmt.setInt(1, questionId);
                    pstmt.setString(2, option.getOptionText());
                    pstmt.setBoolean(3, option.isCorrect());
                    pstmt.addBatch();
                }
                
                int[] results = pstmt.executeBatch();
                
                // Check if all inserts were successful
                boolean success = true;
                for (int result : results) {
                    if (result <= 0) {
                        success = false;
                        break;
                    }
                }
                
                if (success) {
                    conn.commit();
                    return true;
                } else {
                    conn.rollback();
                    return false;
                }
            } catch (SQLException e) {
                conn.rollback();
                e.printStackTrace();
                return false;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // Create a quiz history entry
    public int createQuizHistory(int userId) {
        String sql = "INSERT INTO quiz_history (user_id) VALUES (?)";
        int historyId = -1;
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            pstmt.setInt(1, userId);
            
            int rowsAffected = pstmt.executeUpdate();
            if (rowsAffected > 0) {
                try (ResultSet rs = pstmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        historyId = rs.getInt(1);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return historyId;
    }
    
    // Record quiz answer
    public boolean recordQuizAnswer(int historyId, int questionId, int selectedOptionId, boolean isCorrect) {
        String sql = "INSERT INTO quiz_answers (history_id, question_id, selected_option_id, is_correct) VALUES (?, ?, ?, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, historyId);
            pstmt.setInt(2, questionId);
            pstmt.setInt(3, selectedOptionId);
            pstmt.setBoolean(4, isCorrect);
            
            int rowsAffected = pstmt.executeUpdate();
            return (rowsAffected > 0);
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // Complete quiz history (set end time)
    public boolean completeQuizHistory(int historyId) {
        String sql = "UPDATE quiz_history SET end_time = CURRENT_TIMESTAMP WHERE history_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, historyId);
            
            int rowsAffected = pstmt.executeUpdate();
            return (rowsAffected > 0);
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}