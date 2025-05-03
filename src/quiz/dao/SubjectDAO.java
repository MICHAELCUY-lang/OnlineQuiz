package quiz.dao;

import quiz.model.Subject;
import quiz.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SubjectDAO {
    
    // Add subject with better error handling
    public boolean addSubject(Subject subject) {
        String sql = "INSERT INTO subjects (subject_name, description) VALUES (?, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            pstmt.setString(1, subject.getSubjectName());
            pstmt.setString(2, subject.getDescription());
            
            int affectedRows = pstmt.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        subject.setSubjectId(generatedKeys.getInt(1));
                        return true;
                    }
                }
            }
        } catch (SQLException e) {
            if (e.getErrorCode() == 1062) { // MySQL duplicate entry
                System.err.println("Subject name already exists: " + subject.getSubjectName());
            } else {
                System.err.println("Error adding subject: " + e.getMessage());
            }
            e.printStackTrace();
        }
        
        return false;
    }
    
    // Get subject by ID with better error handling
    public Subject getSubjectById(int subjectId) {
        String sql = "SELECT * FROM subjects WHERE subject_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, subjectId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    Subject subject = new Subject();
                    subject.setSubjectId(rs.getInt("subject_id"));
                    subject.setSubjectName(rs.getString("subject_name"));
                    subject.setDescription(rs.getString("description"));
                    return subject;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error getting subject with ID " + subjectId + ": " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    
    // Get all subjects with better error handling
    public List<Subject> getAllSubjects() {
        List<Subject> subjects = new ArrayList<>();
        String sql = "SELECT * FROM subjects ORDER BY subject_name";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Subject subject = new Subject();
                    subject.setSubjectId(rs.getInt("subject_id"));
                    subject.setSubjectName(rs.getString("subject_name"));
                    subject.setDescription(rs.getString("description"));
                    subjects.add(subject);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error getting subjects: " + e.getMessage());
            e.printStackTrace();
        }
        
        return subjects;
    }
    
    // Update subject with better error handling
    public boolean updateSubject(Subject subject) {
        String sql = "UPDATE subjects SET subject_name = ?, description = ? WHERE subject_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, subject.getSubjectName());
            pstmt.setString(2, subject.getDescription());
            pstmt.setInt(3, subject.getSubjectId());
            
            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            if (e.getErrorCode() == 1062) { // MySQL duplicate entry
                System.err.println("Subject name already exists: " + subject.getSubjectName());
            } else {
                System.err.println("Error updating subject: " + e.getMessage());
            }
            e.printStackTrace();
        }
        
        return false;
    }
    
    // Delete subject with better error handling
    public boolean deleteSubject(int subjectId) {
        String sql = "DELETE FROM subjects WHERE subject_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, subjectId);
            
            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            if (e.getErrorCode() == 1451) { // MySQL foreign key constraint
                System.err.println("Cannot delete subject because it has related questions");
            } else {
                System.err.println("Error deleting subject: " + e.getMessage());
            }
            e.printStackTrace();
        }
        
        return false;
    }
}