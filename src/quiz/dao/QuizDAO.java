// QuizDAO.java
package quiz.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import quiz.model.QuizOption;

public class QuizDAO {
    
    // Get options for a question
    public List<QuizOption> getOptionsForQuestion(int questionId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<QuizOption> options = new ArrayList<>();
        
        try {
            conn = DbUtil.getConnection();
            String sql = "SELECT * FROM quiz WHERE question_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, questionId);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                QuizOption option = new QuizOption();
                option.setQuizId(rs.getInt("quiz_id"));
                option.setQuestionId(rs.getInt("question_id"));
                option.setOptionText(rs.getString("option_text"));
                option.setCorrect(rs.getBoolean("is_correct"));
                options.add(option);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        return options;
    }
    
    // Add options for a question
    public boolean addOptionsForQuestion(int questionId, List<QuizOption> options) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean success = false;
        
        try {
            conn = DbUtil.getConnection();
            conn.setAutoCommit(false);
            
            String sql = "INSERT INTO quiz (question_id, option_text, is_correct) VALUES (?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            
            for (QuizOption option : options) {
                pstmt.setInt(1, questionId);
                pstmt.setString(2, option.getOptionText());
                pstmt.setBoolean(3, option.isCorrect());
                pstmt.addBatch();
            }
            
            int[] results = pstmt.executeBatch();
            conn.commit();
            
            // Check if all inserts were successful
            success = true;
            for (int result : results) {
                if (result <= 0) {
                    success = false;
                    break;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                }
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        return success;
    }
    
    // Create a quiz history entry
    public int createQuizHistory(int userId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int historyId = -1;
        
        try {
            conn = DbUtil.getConnection();
            String sql = "INSERT INTO quiz_history (user_id) VALUES (?)";
            pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            pstmt.setInt(1, userId);
            
            int rowsAffected = pstmt.executeUpdate();
            if (rowsAffected > 0) {
                rs = pstmt.getGeneratedKeys();
                if (rs.next()) {
                    historyId = rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        return historyId;
    }
    
    // Record quiz answer
    public boolean recordQuizAnswer(int historyId, int questionId, int selectedOptionId, boolean isCorrect) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean success = false;
        
        try {
            conn = DbUtil.getConnection();
            String sql = "INSERT INTO quiz_answers (history_id, question_id, selected_option_id, is_correct) VALUES (?, ?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, historyId);
            pstmt.setInt(2, questionId);
            pstmt.setInt(3, selectedOptionId);
            pstmt.setBoolean(4, isCorrect);
            
            int rowsAffected = pstmt.executeUpdate();
            success = (rowsAffected > 0);
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        return success;
    }
    
    // Complete quiz history (set end time)
    public boolean completeQuizHistory(int historyId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean success = false;
        
        try {
            conn = DbUtil.getConnection();
            String sql = "UPDATE quiz_history SET end_time = CURRENT_TIMESTAMP WHERE history_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, historyId);
            
            int rowsAffected = pstmt.executeUpdate();
            success = (rowsAffected > 0);
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        return success;
    }
}