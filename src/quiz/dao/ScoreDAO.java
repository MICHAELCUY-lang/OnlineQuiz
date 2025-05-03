// ScoreDAO.java
package quiz.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import quiz.model.Score;

public class ScoreDAO {
    
    // Record score
    public boolean recordScore(Score score) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean success = false;
        
        try {
            conn = DbUtil.getConnection();
            String sql = "INSERT INTO scores (user_id, history_id, total_score, subject_id) VALUES (?, ?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, score.getUserId());
            pstmt.setInt(2, score.getHistoryId());
            pstmt.setInt(3, score.getTotalScore());
            pstmt.setInt(4, score.getSubjectId());
            
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
    
    // Get scores by user
    public List<Score> getScoresByUser(int userId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<Score> scores = new ArrayList<>();
        
        try {
            conn = DbUtil.getConnection();
            String sql = "SELECT s.*, u.username, sb.subject_name FROM scores s " +
                         "JOIN users u ON s.user_id = u.user_id " +
                         "LEFT JOIN subjects sb ON s.subject_id = sb.subject_id " +
                         "WHERE s.user_id = ? ORDER BY s.date_taken DESC";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Score score = new Score();
                score.setScoreId(rs.getInt("score_id"));
                score.setUserId(rs.getInt("user_id"));
                score.setHistoryId(rs.getInt("history_id"));
                score.setTotalScore(rs.getInt("total_score"));
                score.setDateTaken(rs.getTimestamp("date_taken"));
                score.setSubjectId(rs.getInt("subject_id"));
                score.setUsername(rs.getString("username"));
                score.setSubjectName(rs.getString("subject_name"));
                scores.add(score);
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
        
        return scores;
    }
    
    // Get chart data
    public List<Object[]> getChartData(int userId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<Object[]> chartData = new ArrayList<>();
        
        try {
            conn = DbUtil.getConnection();
            String sql = "SELECT cd.*, s.subject_name FROM chart_data cd " +
                         "LEFT JOIN subjects s ON cd.subject_id = s.subject_id " +
                         "WHERE cd.user_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Object[] data = new Object[4];
                data[0] = rs.getString("subject_name");
                data[1] = rs.getFloat("data_value");
                data[2] = rs.getString("data_label");
                data[3] = rs.getTimestamp("data_date");
                chartData.add(data);
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
        
        return chartData;
    }
    
    // Add chart data
    public boolean addChartData(int userId, int subjectId, String dataType, float dataValue, String dataLabel) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean success = false;
        
        try {
            conn = DbUtil.getConnection();
            String sql = "INSERT INTO chart_data (user_id, subject_id, data_type, data_value, data_label) VALUES (?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            pstmt.setInt(2, subjectId);
            pstmt.setString(3, dataType);
            pstmt.setFloat(4, dataValue);
            pstmt.setString(5, dataLabel);
            
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