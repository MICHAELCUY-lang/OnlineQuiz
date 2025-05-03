package quiz.dao;

import quiz.model.Question;
import quiz.model.QuizOption;
import quiz.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class QuestionDAO {
    
    // Create a new question with options
    public boolean addQuestion(Question question, List<QuizOption> options) {
        String questionSql = "INSERT INTO questions (subject_id, question_text, correct_answer, created_by) VALUES (?, ?, ?, ?)";
        String optionSql = "INSERT INTO quiz (question_id, option_text, is_correct) VALUES (?, ?, ?)";
        
        Connection conn = null;
        PreparedStatement pstmtQuestion = null;
        PreparedStatement pstmtOption = null;
        ResultSet generatedKeys = null;
        
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);
            
            // Insert question
            pstmtQuestion = conn.prepareStatement(questionSql, Statement.RETURN_GENERATED_KEYS);
            pstmtQuestion.setInt(1, question.getSubjectId());
            pstmtQuestion.setString(2, question.getQuestionText());
            pstmtQuestion.setString(3, question.getCorrectAnswer());
            pstmtQuestion.setInt(4, question.getCreatedBy());
            
            int affectedRows = pstmtQuestion.executeUpdate();
            
            if (affectedRows == 0) {
                conn.rollback();
                return false;
            }
            
            // Get generated question ID
            generatedKeys = pstmtQuestion.getGeneratedKeys();
            if (generatedKeys.next()) {
                int questionId = generatedKeys.getInt(1);
                question.setQuestionId(questionId);
                
                // Insert options
                pstmtOption = conn.prepareStatement(optionSql);
                for (QuizOption option : options) {
                    pstmtOption.setInt(1, questionId);
                    pstmtOption.setString(2, option.getOptionText());
                    pstmtOption.setBoolean(3, option.isCorrect());
                    pstmtOption.addBatch();
                }
                
                int[] optionResults = pstmtOption.executeBatch();
                for (int result : optionResults) {
                    if (result == 0) {
                        conn.rollback();
                        return false;
                    }
                }
                
                conn.commit();
                return true;
            } else {
                conn.rollback();
                return false;
            }
        } catch (SQLException e) {
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (generatedKeys != null) generatedKeys.close();
                if (pstmtOption != null) pstmtOption.close();
                if (pstmtQuestion != null) pstmtQuestion.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    // Get question by ID with options
    public Question getQuestionById(int questionId) {
        String questionSql = "SELECT * FROM questions WHERE question_id = ?";
        String optionsSql = "SELECT * FROM quiz WHERE question_id = ?";
        
        Question question = null;
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmtQuestion = conn.prepareStatement(questionSql);
             PreparedStatement pstmtOptions = conn.prepareStatement(optionsSql)) {
            
            pstmtQuestion.setInt(1, questionId);
            try (ResultSet rsQuestion = pstmtQuestion.executeQuery()) {
                if (rsQuestion.next()) {
                    question = new Question();
                    question.setQuestionId(rsQuestion.getInt("question_id"));
                    question.setSubjectId(rsQuestion.getInt("subject_id"));
                    question.setQuestionText(rsQuestion.getString("question_text"));
                    question.setCorrectAnswer(rsQuestion.getString("correct_answer"));
                    question.setCreatedBy(rsQuestion.getInt("created_by"));
                    question.setCreatedDate(rsQuestion.getTimestamp("created_date"));
                }
            }
            
            if (question != null) {
                pstmtOptions.setInt(1, questionId);
                try (ResultSet rsOptions = pstmtOptions.executeQuery()) {
                    while (rsOptions.next()) {
                        QuizOption option = new QuizOption();
                        option.setQuizId(rsOptions.getInt("quiz_id"));
                        option.setQuestionId(rsOptions.getInt("question_id"));
                        option.setOptionText(rsOptions.getString("option_text"));
                        option.setCorrect(rsOptions.getBoolean("is_correct"));
                        question.addOption(option);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return question;
    }
    
    // Get all questions by subject
    public List<Question> getQuestionsBySubject(int subjectId) {
        List<Question> questions = new ArrayList<>();
        String sql = "SELECT * FROM questions WHERE subject_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, subjectId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Question question = new Question();
                    question.setQuestionId(rs.getInt("question_id"));
                    question.setSubjectId(rs.getInt("subject_id"));
                    question.setQuestionText(rs.getString("question_text"));
                    question.setCorrectAnswer(rs.getString("correct_answer"));
                    question.setCreatedBy(rs.getInt("created_by"));
                    question.setCreatedDate(rs.getTimestamp("created_date"));
                    
                    // Get options for this question
                    question.setOptions(getOptionsForQuestion(question.getQuestionId()));
                    
                    questions.add(question);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return questions;
    }
    
    // Get options for a question
    private List<QuizOption> getOptionsForQuestion(int questionId) {
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
    
    // Get all questions with options
    public List<Question> getAllQuestions() {
        List<Question> questions = new ArrayList<>();
        String sql = "SELECT * FROM questions";
        
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                Question question = new Question();
                question.setQuestionId(rs.getInt("question_id"));
                question.setSubjectId(rs.getInt("subject_id"));
                question.setQuestionText(rs.getString("question_text"));
                question.setCorrectAnswer(rs.getString("correct_answer"));
                question.setCreatedBy(rs.getInt("created_by"));
                question.setCreatedDate(rs.getTimestamp("created_date"));
                
                // Get options for this question
                question.setOptions(getOptionsForQuestion(question.getQuestionId()));
                
                questions.add(question);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return questions;
    }
    
    // Update question and options
    public boolean updateQuestion(Question question, List<QuizOption> options) {
        String questionSql = "UPDATE questions SET subject_id = ?, question_text = ?, correct_answer = ? WHERE question_id = ?";
        String deleteOptionsSql = "DELETE FROM quiz WHERE question_id = ?";
        String insertOptionsSql = "INSERT INTO quiz (question_id, option_text, is_correct) VALUES (?, ?, ?)";
        
        Connection conn = null;
        PreparedStatement pstmtQuestion = null;
        PreparedStatement pstmtDeleteOptions = null;
        PreparedStatement pstmtInsertOptions = null;
        
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);
            
            // Update question
            pstmtQuestion = conn.prepareStatement(questionSql);
            pstmtQuestion.setInt(1, question.getSubjectId());
            pstmtQuestion.setString(2, question.getQuestionText());
            pstmtQuestion.setString(3, question.getCorrectAnswer());
            pstmtQuestion.setInt(4, question.getQuestionId());
            
            int affectedRows = pstmtQuestion.executeUpdate();
            
            if (affectedRows == 0) {
                conn.rollback();
                return false;
            }
            
            // Delete existing options
            pstmtDeleteOptions = conn.prepareStatement(deleteOptionsSql);
            pstmtDeleteOptions.setInt(1, question.getQuestionId());
            pstmtDeleteOptions.executeUpdate();
            
            // Insert new options
            pstmtInsertOptions = conn.prepareStatement(insertOptionsSql);
            for (QuizOption option : options) {
                pstmtInsertOptions.setInt(1, question.getQuestionId());
                pstmtInsertOptions.setString(2, option.getOptionText());
                pstmtInsertOptions.setBoolean(3, option.isCorrect());
                pstmtInsertOptions.addBatch();
            }
            
            int[] optionResults = pstmtInsertOptions.executeBatch();
            for (int result : optionResults) {
                if (result == 0) {
                    conn.rollback();
                    return false;
                }
            }
            
            conn.commit();
            return true;
        } catch (SQLException e) {
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (pstmtInsertOptions != null) pstmtInsertOptions.close();
                if (pstmtDeleteOptions != null) pstmtDeleteOptions.close();
                if (pstmtQuestion != null) pstmtQuestion.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    // Delete question and its options
    public boolean deleteQuestion(int questionId) {
        String sql = "DELETE FROM questions WHERE question_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, questionId);
            
            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    // Get random questions for a quiz
    public List<Question> getRandomQuestions(int subjectId, int limit) {
        List<Question> questions = new ArrayList<>();
        String sql = "SELECT * FROM questions WHERE subject_id = ? ORDER BY RAND() LIMIT ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, subjectId);
            pstmt.setInt(2, limit);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Question question = new Question();
                    question.setQuestionId(rs.getInt("question_id"));
                    question.setSubjectId(rs.getInt("subject_id"));
                    question.setQuestionText(rs.getString("question_text"));
                    question.setCorrectAnswer(rs.getString("correct_answer"));
                    question.setCreatedBy(rs.getInt("created_by"));
                    question.setCreatedDate(rs.getTimestamp("created_date"));
                    
                    // Get options for this question
                    question.setOptions(getOptionsForQuestion(question.getQuestionId()));
                    
                    questions.add(question);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return questions;
    }
}