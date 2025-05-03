package quiz.dao;

import quiz.model.ChartData;
import quiz.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ChartDataDAO {
    
    // Create a new chart data entry
    public boolean createChartData(ChartData chartData) {
        String sql = "INSERT INTO chart_data (user_id, subject_id, data_type, data_value, data_label) VALUES (?, ?, ?, ?, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            if (chartData.getUserId() != null) {
                pstmt.setInt(1, chartData.getUserId());
            } else {
                pstmt.setNull(1, Types.INTEGER);
            }
            
            if (chartData.getSubjectId() != null) {
                pstmt.setInt(2, chartData.getSubjectId());
            } else {
                pstmt.setNull(2, Types.INTEGER);
            }
            
            pstmt.setString(3, chartData.getDataType());
            pstmt.setFloat(4, chartData.getDataValue());
            pstmt.setString(5, chartData.getDataLabel());
            
            int affectedRows = pstmt.executeUpdate();
            
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        chartData.setChartId(generatedKeys.getInt(1));
                        return true;
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    // Get chart data by user
    public List<ChartData> getChartDataByUser(int userId) {
        List<ChartData> chartDataList = new ArrayList<>();
        String sql = "SELECT * FROM chart_data WHERE user_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    ChartData chartData = new ChartData();
                    chartData.setChartId(rs.getInt("chart_id"));
                    chartData.setUserId(rs.getInt("user_id"));
                    
                    Integer subjectId = rs.getInt("subject_id");
                    if (!rs.wasNull()) {
                        chartData.setSubjectId(subjectId);
                    }
                    
                    chartData.setDataType(rs.getString("data_type"));
                    chartData.setDataValue(rs.getFloat("data_value"));
                    chartData.setDataLabel(rs.getString("data_label"));
                    chartData.setDataDate(rs.getTimestamp("data_date"));
                    
                    chartDataList.add(chartData);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return chartDataList;
    }
    
    // Get chart data by subject
    public List<ChartData> getChartDataBySubject(int subjectId) {
        List<ChartData> chartDataList = new ArrayList<>();
        String sql = "SELECT * FROM chart_data WHERE subject_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, subjectId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    ChartData chartData = new ChartData();
                    chartData.setChartId(rs.getInt("chart_id"));
                    
                    Integer userId = rs.getInt("user_id");
                    if (!rs.wasNull()) {
                        chartData.setUserId(userId);
                    }
                    
                    chartData.setSubjectId(rs.getInt("subject_id"));
                    chartData.setDataType(rs.getString("data_type"));
                    chartData.setDataValue(rs.getFloat("data_value"));
                    chartData.setDataLabel(rs.getString("data_label"));
                    chartData.setDataDate(rs.getTimestamp("data_date"));
                    
                    chartDataList.add(chartData);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return chartDataList;
    }
    
    // Get chart data by user and subject
    public List<ChartData> getChartDataByUserAndSubject(int userId, int subjectId) {
        List<ChartData> chartDataList = new ArrayList<>();
        String sql = "SELECT * FROM chart_data WHERE user_id = ? AND subject_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            pstmt.setInt(2, subjectId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    ChartData chartData = new ChartData();
                    chartData.setChartId(rs.getInt("chart_id"));
                    chartData.setUserId(rs.getInt("user_id"));
                    chartData.setSubjectId(rs.getInt("subject_id"));
                    chartData.setDataType(rs.getString("data_type"));
                    chartData.setDataValue(rs.getFloat("data_value"));
                    chartData.setDataLabel(rs.getString("data_label"));
                    chartData.setDataDate(rs.getTimestamp("data_date"));
                    
                    chartDataList.add(chartData);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return chartDataList;
    }
    
    // Get chart data by data type
    public List<ChartData> getChartDataByType(String dataType) {
        List<ChartData> chartDataList = new ArrayList<>();
        String sql = "SELECT * FROM chart_data WHERE data_type = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, dataType);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    ChartData chartData = new ChartData();
                    chartData.setChartId(rs.getInt("chart_id"));
                    
                    Integer userId = rs.getInt("user_id");
                    if (!rs.wasNull()) {
                        chartData.setUserId(userId);
                    }
                    
                    Integer subjectId = rs.getInt("subject_id");
                    if (!rs.wasNull()) {
                        chartData.setSubjectId(subjectId);
                    }
                    
                    chartData.setDataType(rs.getString("data_type"));
                    chartData.setDataValue(rs.getFloat("data_value"));
                    chartData.setDataLabel(rs.getString("data_label"));
                    chartData.setDataDate(rs.getTimestamp("data_date"));
                    
                    chartDataList.add(chartData);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return chartDataList;
    }
    
    // Update chart data
    public boolean updateChartData(ChartData chartData) {
        String sql = "UPDATE chart_data SET data_value = ?, data_label = ? WHERE chart_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setFloat(1, chartData.getDataValue());
            pstmt.setString(2, chartData.getDataLabel());
            pstmt.setInt(3, chartData.getChartId());
            
            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    // Delete chart data
    public boolean deleteChartData(int chartId) {
        String sql = "DELETE FROM chart_data WHERE chart_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, chartId);
            
            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    // Generate performance chart data from scores
    public void generatePerformanceData(int userId) {
        // First, clean existing performance data for this user
        String deleteSql = "DELETE FROM chart_data WHERE user_id = ? AND data_type = 'performance'";
        
        // Query to get average scores by subject
        String querySql = "SELECT s.subject_id, s.subject_name, AVG(sc.total_score) as avg_score " +
                          "FROM scores sc " +
                          "JOIN subjects s ON sc.subject_id = s.subject_id " +
                          "WHERE sc.user_id = ? " +
                          "GROUP BY s.subject_id, s.subject_name";
        
        // Insert new chart data
        String insertSql = "INSERT INTO chart_data (user_id, subject_id, data_type, data_value, data_label) VALUES (?, ?, 'performance', ?, ?)";
        
        Connection conn = null;
        PreparedStatement deleteStmt = null;
        PreparedStatement queryStmt = null;
        PreparedStatement insertStmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);
            
            // Delete existing data
            deleteStmt = conn.prepareStatement(deleteSql);
            deleteStmt.setInt(1, userId);
            deleteStmt.executeUpdate();
            
            // Query for new data
            queryStmt = conn.prepareStatement(querySql);
            queryStmt.setInt(1, userId);
            rs = queryStmt.executeQuery();
            
            // Insert new data
            insertStmt = conn.prepareStatement(insertSql);
            
            while (rs.next()) {
                int subjectId = rs.getInt("subject_id");
                String subjectName = rs.getString("subject_name");
                float avgScore = rs.getFloat("avg_score");
                
                insertStmt.setInt(1, userId);
                insertStmt.setInt(2, subjectId);
                insertStmt.setFloat(3, avgScore);
                insertStmt.setString(4, subjectName + " Performance");
                insertStmt.addBatch();
            }
            
            insertStmt.executeBatch();
            conn.commit();
        } catch (SQLException e) {
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (insertStmt != null) insertStmt.close();
                if (queryStmt != null) queryStmt.close();
                if (deleteStmt != null) deleteStmt.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}