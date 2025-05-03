<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>

<%
    // Process quiz submission
    
    // Check if user is logged in
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("Login.jsp");
        return;
    }
    
    try {
        // Get form parameters
        int questionId = Integer.parseInt(request.getParameter("questionId"));
        int selectedOptionId = -1;
        
        // If user selected an option, get it, otherwise use -1 for skipped questions
        String selectedOption = request.getParameter("selectedOption");
        if (selectedOption != null && !selectedOption.isEmpty()) {
            selectedOptionId = Integer.parseInt(selectedOption);
        }
        
        int historyId = Integer.parseInt(request.getParameter("historyId"));
        int subjectId = Integer.parseInt(request.getParameter("subjectId"));
        
        // Get session data
        @SuppressWarnings("unchecked")
        List<Map<String, Object>> quizQuestions = (List<Map<String, Object>>) session.getAttribute("quizQuestions");
        
        @SuppressWarnings("unchecked")
        Map<Integer, Integer> userAnswers = (Map<Integer, Integer>) session.getAttribute("userAnswers");
        if (userAnswers == null) {
            userAnswers = new HashMap<>();
            session.setAttribute("userAnswers", userAnswers);
        }
        
        int currentQuestionIndex = (int) session.getAttribute("currentQuestionIndex");
        
        // Store the user's answer if they selected an option
        if (selectedOptionId > 0) {
            userAnswers.put(questionId, selectedOptionId);
            session.setAttribute("userAnswers", userAnswers);
        }
        
        // Get user_id from session or database
        Integer userId = (Integer) session.getAttribute("user_id");
        if (userId == null) {
            // Get user_id from database if not in session
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/quiz_db", "root", "");
                
                pstmt = conn.prepareStatement("SELECT user_id FROM users WHERE username = ?");
                pstmt.setString(1, username);
                rs = pstmt.executeQuery();
                
                if (rs.next()) {
                    userId = rs.getInt("user_id");
                    session.setAttribute("user_id", userId);
                } else {
                    throw new Exception("User not found");
                }
            } finally {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            }
        }
        
        // Check if we're navigating to previous question
        String action = request.getParameter("action");
        if ("previous".equals(action)) {
            if (currentQuestionIndex > 0) {
                currentQuestionIndex--;
                session.setAttribute("currentQuestionIndex", currentQuestionIndex);
            }
            response.sendRedirect("Quiz.jsp?subject_id=" + subjectId);
            return;
        }
        
        // Database operations
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            // Database connection
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/quiz_db", "root", "");
            
            // If user selected an option, save it to database
            if (selectedOptionId > 0) {
                // Check if the selected option is correct
                boolean isCorrect = false;
                pstmt = conn.prepareStatement("SELECT is_correct FROM quiz WHERE quiz_id = ?");
                pstmt.setInt(1, selectedOptionId);
                rs = pstmt.executeQuery();
                
                if (rs.next()) {
                    isCorrect = rs.getBoolean("is_correct");
                }
                rs.close();
                pstmt.close();
                
                // Check if this answer already exists
                boolean answerExists = false;
                pstmt = conn.prepareStatement(
                    "SELECT answer_id FROM quiz_answers WHERE history_id = ? AND question_id = ?");
                pstmt.setInt(1, historyId);
                pstmt.setInt(2, questionId);
                rs = pstmt.executeQuery();
                
                answerExists = rs.next();
                rs.close();
                pstmt.close();
                
                // Insert or update answer in quiz_answers table
                if (answerExists) {
                    pstmt = conn.prepareStatement(
                        "UPDATE quiz_answers SET selected_option_id = ?, is_correct = ? " +
                        "WHERE history_id = ? AND question_id = ?");
                    pstmt.setInt(1, selectedOptionId);
                    pstmt.setBoolean(2, isCorrect);
                    pstmt.setInt(3, historyId);
                    pstmt.setInt(4, questionId);
                    pstmt.executeUpdate();
                } else {
                    pstmt = conn.prepareStatement(
                        "INSERT INTO quiz_answers (history_id, question_id, selected_option_id, is_correct) " +
                        "VALUES (?, ?, ?, ?)");
                    pstmt.setInt(1, historyId);
                    pstmt.setInt(2, questionId);
                    pstmt.setInt(3, selectedOptionId);
                    pstmt.setBoolean(4, isCorrect);
                    pstmt.executeUpdate();
                }
                pstmt.close();
            }
            
            // If this is the last question or finish is clicked, calculate the score and redirect to results
            if (currentQuestionIndex == quizQuestions.size() - 1 || "finish".equals(action)) {
                // Calculate total score
                pstmt = conn.prepareStatement(
                    "SELECT COUNT(*) AS correct_count FROM quiz_answers WHERE history_id = ? AND is_correct = TRUE");
                pstmt.setInt(1, historyId);
                rs = pstmt.executeQuery();
                
                int totalScore = 0;
                if (rs.next()) {
                    totalScore = rs.getInt("correct_count");
                }
                rs.close();
                pstmt.close();
                
                // Update quiz_history with end time
                pstmt = conn.prepareStatement(
                    "UPDATE quiz_history SET end_time = NOW() WHERE history_id = ?");
                pstmt.setInt(1, historyId);
                pstmt.executeUpdate();
                pstmt.close();
                
                // Check if score already exists
                boolean scoreExists = false;
                pstmt = conn.prepareStatement(
                    "SELECT score_id FROM scores WHERE history_id = ?");
                pstmt.setInt(1, historyId);
                rs = pstmt.executeQuery();
                
                scoreExists = rs.next();
                rs.close();
                pstmt.close();
                
                // Insert or update score
                if (scoreExists) {
                    pstmt = conn.prepareStatement(
                        "UPDATE scores SET total_score = ? WHERE history_id = ?");
                    pstmt.setInt(1, totalScore);
                    pstmt.setInt(2, historyId);
                    pstmt.executeUpdate();
                } else {
                    pstmt = conn.prepareStatement(
                        "INSERT INTO scores (user_id, history_id, total_score, subject_id) VALUES (?, ?, ?, ?)");
                    pstmt.setInt(1, userId);
                    pstmt.setInt(2, historyId);
                    pstmt.setInt(3, totalScore);
                    pstmt.setInt(4, subjectId);
                    pstmt.executeUpdate();
                }
                pstmt.close();
                
                // Insert chart data for visualization
                float scorePercentage = ((float) totalScore / quizQuestions.size()) * 100;
                pstmt = conn.prepareStatement(
                    "INSERT INTO chart_data (user_id, subject_id, data_type, data_value, data_label) " +
                    "VALUES (?, ?, 'performance', ?, ?)");
                pstmt.setInt(1, userId);
                pstmt.setInt(2, subjectId);
                pstmt.setFloat(3, scorePercentage);
                pstmt.setString(4, "Quiz Performance");
                pstmt.executeUpdate();
                pstmt.close();
                
                // Store subject_id and history_id in session for charts
                session.setAttribute("subject_id", subjectId);
                session.setAttribute("history_id", historyId);
                
                // Clear quiz session data
                session.removeAttribute("quizQuestions");
                session.removeAttribute("currentQuestionIndex");
                session.removeAttribute("userAnswers");
                session.removeAttribute("quizStartTime");
                
                // Clear timer from localStorage using JavaScript
                %>
                <script>
                    localStorage.removeItem('quizEndTime');
                    window.location.href = "QuizResult.jsp?history_id=<%= historyId %>&subject_id=<%= subjectId %>";
                </script>
                <%
                return;
            } else {
                // Move to next question
                currentQuestionIndex++;
                session.setAttribute("currentQuestionIndex", currentQuestionIndex);
                %>
                <script>
                    window.location.href = "Quiz.jsp?subject_id=<%= subjectId %>";
                </script>
                <%
                return;
            }
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) { }
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) { }
            if (conn != null) try { conn.close(); } catch (Exception e) { }
        }
    } catch (Exception e) {
        // Log the error
        System.err.println("Error in SubmitAnswer.jsp: " + e.getMessage());
        e.printStackTrace(System.err);
        
        // Try to get subject_id from request or session
        int subjectId = 0;
        try {
            subjectId = Integer.parseInt(request.getParameter("subjectId"));
        } catch (NumberFormatException ex) {
            // If not in request, try from session
            Object sessionSubjectId = session.getAttribute("subject_id");
            if (sessionSubjectId instanceof Integer) {
                subjectId = (Integer) sessionSubjectId;
            }
        }
        
        // Redirect with error
        if (subjectId > 0) {
            request.setAttribute("error", "Terjadi kesalahan: " + e.getMessage());
            request.getRequestDispatcher("Quiz.jsp?subject_id=" + subjectId).forward(request, response);
        } else {
            request.setAttribute("error", "Terjadi kesalahan: " + e.getMessage());
            request.getRequestDispatcher("Dashboard.jsp").forward(request, response);
        }
    }
%>