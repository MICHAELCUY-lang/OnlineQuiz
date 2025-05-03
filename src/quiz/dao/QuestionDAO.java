// QuestionDAO.java
package quiz.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import quiz.model.Question;

public class QuestionDAO {
    
    // Get all questions
    public List<Question> getAllQuestions() {
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        List<Question> questions = new ArrayList<>();
        
        try {
            conn = DbUtil.getConnection();
            stmt = conn.createStatement();
            String sql = "SELECT q.*, s.subject_name FROM questions q JOIN subjects s ON q.subject_id = s.subject_id";
            rs = stmt.executeQuery(sql);
            
            while (rs.next()) {
                Question question = new Question();
                question.setQuestionId(rs.getInt("question_id"));
                question.setSubjectId(rs.getInt("subject_id"));
                question.setQuestionText(rs.getString("question_text"));
                question.setCorrectAnswer(rs.getString("correct_answer"));
                question.setCreatedBy(rs.getInt("created_by"));
                question.setCreatedDate(rs.getTimestamp("created_date"));
                question.setSubjectName(rs.getString("subject_name"));
                questions.add(question);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        return questions;
    }
    
    // Get questions by subject
    public List<Question> getQuestionsBySubject(int subjectId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<Question> questions = new ArrayList<>();
        
        try {
            conn = DbUtil.getConnection();
            String sql = "SELECT q.*, s.subject_name FROM questions q JOIN subjects s ON q.subject_id = s.subject_id WHERE q.subject_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, subjectId);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Question question = new Question();
                question.setQuestionId(rs.getInt("question_id"));
                question.setSubjectId(rs.getInt("subject_id"));
                question.setQuestionText(rs.getString("question_text"));
                question.setCorrectAnswer(rs.getString("correct_answer"));
                question.setCreatedBy(rs.getInt("created_by"));
                question.setCreatedDate(rs.getTimestamp("created_date"));
                question.setSubjectName(rs.getString("subject_name"));
                questions.add(question);
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
        
        return questions;
    }
    
    // Get question by ID
    public Question getQuestionById(int questionId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Question question = null;
        
        try {
            conn = DbUtil.getConnection();
            String sql = "SELECT q.*, s.subject_name FROM questions q JOIN subjects s ON q.subject_id = s.subject_id WHERE q.question_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, questionId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                question = new Question();
                question.setQuestionId(rs.getInt("question_id"));
                question.setSubjectId(rs.getInt("subject_id"));
                question.setQuestionText(rs.getString("question_text"));
                question.setCorrectAnswer(rs.getString("correct_answer"));
                question.setCreatedBy(rs.getInt("created_by"));
                question.setCreatedDate(rs.getTimestamp("created_date"));
                question.setSubjectName(rs.getString("subject_name"));
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
        
        return question;
    }
    
    // Add new question
    public boolean addQuestion(Question question) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean success = false;
        
        try {
            conn = DbUtil.getConnection();
            String sql = "INSERT INTO questions (subject_id, question_text, correct_answer, created_by) VALUES (?, ?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, question.getSubjectId());
            pstmt.setString(2, question.getQuestionText());
            pstmt.setString(3, question.getCorrectAnswer());
            pstmt.setInt(4, question.getCreatedBy());
            
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