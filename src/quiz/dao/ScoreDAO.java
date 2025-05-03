package quiz.dao;

import quiz.model.Score;
import quiz.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ScoreDAO {
    
    // Create a new score record
    public boolean createScore(Score score) {
        String sql = "INSERT INTO scores (user_id, history_id, total_score, subject_id) VALUES (?, ?, ?, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            pstmt.setInt(1, score.getUserId());
            pstmt.setInt(2, score.getHistoryId());
            pstmt.setInt(3, score.getTotalScore());
            
            if (score.getSubjectId() != null) {
                pstmt.setInt(4, score.getSubjectId());
            } else {
                pstmt.setNull(4, Types.INTEGER);
            }
            
            int affectedRows = pstmt.executeUpdate();
            
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        score.setScoreId(generatedKeys.getInt(1));
                        return true;
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    // Get score by ID
    public Score getScoreById(int scoreId) {
        String sql = "SELECT * FROM scores WHERE score_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, scoreId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    Score score = new Score();
                    score.setScoreId(rs.getInt("score_id"));
                    score.setUserId(rs.getInt("user_id"));
                    score.setHistoryId(rs.getInt("history_id"));
                    score.setTotalScore(rs.getInt("total_score"));
                    score.setDateTaken(rs.getTimestamp("date_taken"));
                    
                    Integer subjectId = rs.getInt("subject_id");
                    if (!rs.wasNull()) {
                        score.setSubjectId(subjectId);
                    }
                    
                    return score;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }
    
    // Get score by history ID
    public Score getScoreByHistoryId(int historyId) {
        String sql = "SELECT * FROM scores WHERE history_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, historyId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    Score score = new Score();
                    score.setScoreId(rs.getInt("score_id"));
                    score.setUserId(rs.getInt("user_id"));
                    score.setHistoryId(rs.getInt("history_id"));
                    score.setTotalScore(rs.getInt("total_score"));
                    score.setDateTaken(rs.getTimestamp("date_taken"));
                    
                    Integer subjectId = rs.getInt("subject_id");
                    if (!rs.wasNull()) {
                        score.setSubjectId(subjectId);
                    }
                    
                    return score;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }
    
    // Get all scores for a user
    public List<Score> getScoresByUser(int userId) {
        List<Score> scores = new ArrayList<>();
        String sql = "SELECT * FROM scores WHERE user_id = ? ORDER BY date_taken DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Score score = new Score();
                    score.setScoreId(rs.getInt("score_id"));
                    score.setUserId(rs.getInt("user_id"));
                    score.setHistoryId(rs.getInt("history_id"));
                    score.setTotalScore(rs.getInt("total_score"));
                    score.setDateTaken(rs.getTimestamp("date_taken"));
                    
                    Integer subjectId = rs.getInt("subject_id");
                    if (!rs.wasNull()) {
                        score.setSubjectId(subjectId);
                    }
                    
                    scores.add(score);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return scores;
    }
    
    // Get all scores for a user by subject
    public List<Score> getScoresByUserAndSubject(int userId, int subjectId) {
        List<Score> scores = new ArrayList<>();
        String sql = "SELECT * FROM scores WHERE user_id = ? AND subject_id = ? ORDER BY date_taken DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            pstmt.setInt(2, subjectId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Score score = new Score();
                    score.setScoreId(rs.getInt("score_id"));
                    score.setUserId(rs.getInt("user_id"));
                    score.setHistoryId(rs.getInt("history_id"));
                    score.setTotalScore(rs.getInt("total_score"));
                    score.setDateTaken(rs.getTimestamp("date_taken"));
                    score.setSubjectId(subjectId);
                    
                    scores.add(score);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return scores;
    }
    
    // Get average score by subject
    public double getAverageScoreBySubject(int subjectId) {
        String sql = "SELECT AVG(total_score) FROM scores WHERE subject_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, subjectId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return 0.0;
    }
    
    // Get average score by user and subject
    public double getAverageScoreByUserAndSubject(int userId, int subjectId) {
        String sql = "SELECT AVG(total_score) FROM scores WHERE user_id = ? AND subject_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            pstmt.setInt(2, subjectId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return 0.0;
    }
    
    // Get user's scores by subject for chart data
    public Map<String, Double> getUserScoresBySubject(int userId) {
        Map<String, Double> subjectScores = new HashMap<>();
        String sql = "SELECT s.subject_name, AVG(sc.total_score) as avg_score " +
                     "FROM scores sc " +
                     "JOIN subjects s ON sc.subject_id = s.subject_id " +
                     "WHERE sc.user_id = ? " +
                     "GROUP BY s.subject_id, s.subject_name";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    String subjectName = rs.getString("subject_name");
                    double avgScore = rs.getDouble("avg_score");
                    subjectScores.put(subjectName, avgScore);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return subjectScores;
    }
    
    // Update score
    public boolean updateScore(Score score) {
        String sql = "UPDATE scores SET total_score = ? WHERE score_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, score.getTotalScore());
            pstmt.setInt(2, score.getScoreId());
            
            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    // Delete score
    public boolean deleteScore(int scoreId) {
        String sql = "DELETE FROM scores WHERE score_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, scoreId);
            
            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
}