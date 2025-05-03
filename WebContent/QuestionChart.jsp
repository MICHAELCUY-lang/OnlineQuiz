<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>QUIZZEAH! - Question Statistics</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f5f5f5;
            color: #333;
        }
        .container {
            width: 100%;
            max-width: 800px;
            margin: 0 auto;
            background-color: #fff;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }
        .header {
            background-color: #e0e0e0;
            padding: 15px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .logo {
            font-size: 24px;
            font-weight: bold;
            color: #2c3e50;
        }
        .user {
            font-weight: bold;
            color: #e74c3c;
        }
        .content {
            padding: 20px;
        }
        .question-stats {
            display: flex;
            flex-wrap: wrap;
            justify-content: space-between;
        }
        .stat-box {
            width: 31%;
            margin-bottom: 20px;
            background-color: #e0e0e0;
            padding: 10px;
        }
        .question-number {
            display: flex;
            align-items: center;
            margin-bottom: 10px;
        }
        .question-number span {
            font-weight: bold;
            margin-right: 5px;
        }
        .chart-container {
            text-align: center;
        }
        .pie-chart {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            margin: 0 auto 10px;
        }
        .legend {
            text-align: left;
            font-size: 14px;
        }
        .legend-item {
            display: flex;
            align-items: center;
            margin-bottom: 5px;
        }
        .color-dot {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            margin-right: 5px;
            display: inline-block;
        }
        .blue-dot {
            background-color: #4285f4;
        }
        .gray-dot {
            background-color: #f5f5f5;
        }
        .buttons {
            text-align: right;
            margin-top: 20px;
        }
        .btn {
            display: inline-block;
            padding: 8px 15px;
            background-color: #e0e0e0;
            text-decoration: none;
            color: #333;
            font-weight: bold;
            border-radius: 5px;
        }
        .correct-icon {
            display: inline-flex;
            justify-content: center;
            align-items: center;
            width: 20px;
            height: 20px;
            border-radius: 50%;
            background-color: #fff;
            color: green;
        }
        .wrong-icon {
            display: inline-flex;
            justify-content: center;
            align-items: center;
            width: 20px;
            height: 20px;
            border-radius: 50%;
            background-color: #fff;
            color: red;
        }
        hr {
            margin: 10px 0;
            border: none;
            height: 2px;
            background-color: #fff;
        }
    </style>
</head>
<body>
    <%
        // Check if user is logged in
        String username = (String) session.getAttribute("username");
        if (username == null) {
            response.sendRedirect("Login.jsp");
            return;
        }
        
        // Get user_id from session
        Integer userId = (Integer) session.getAttribute("user_id");
        
        // If user_id is not in the session, try to get it from the database using username
        if (userId == null) {
            Connection tempConn = null;
            PreparedStatement tempStmt = null;
            ResultSet tempRs = null;
            
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                tempConn = DriverManager.getConnection("jdbc:mysql://localhost:3306/quiz_db", "root", "");
                
                tempStmt = tempConn.prepareStatement("SELECT user_id FROM users WHERE username = ?");
                tempStmt.setString(1, username);
                tempRs = tempStmt.executeQuery();
                
                if (tempRs.next()) {
                    userId = tempRs.getInt("user_id");
                    session.setAttribute("user_id", userId);
                } else {
                    response.sendRedirect("Login.jsp");
                    return;
                }
            } catch (Exception e) {
                response.sendRedirect("Login.jsp");
                return;
            } finally {
                try { if (tempRs != null) tempRs.close(); } catch (Exception e) { }
                try { if (tempStmt != null) tempStmt.close(); } catch (Exception e) { }
                try { if (tempConn != null) tempConn.close(); } catch (Exception e) { }
            }
        }
        
        // Get subject_id and history_id from parameters or session
        int subjectId = 0;
        int historyId = 0;
        
        // First try to get from parameters
        String subjectIdParam = request.getParameter("subject_id");
        String historyIdParam = request.getParameter("history_id");
        
        if (subjectIdParam != null && historyIdParam != null) {
            try {
                subjectId = Integer.parseInt(subjectIdParam);
                historyId = Integer.parseInt(historyIdParam);
                session.setAttribute("subject_id", subjectId);
                session.setAttribute("history_id", historyId);
            } catch (NumberFormatException e) {
                // Parameter format is invalid
            }
        }
        
        // If not found in parameters, try from session
        if (subjectId == 0 || historyId == 0) {
            Object sessionSubjectId = session.getAttribute("subject_id");
            Object sessionHistoryId = session.getAttribute("history_id");
            
            if (sessionSubjectId != null && sessionHistoryId != null) {
                try {
                    subjectId = (Integer) sessionSubjectId;
                    historyId = (Integer) sessionHistoryId;
                } catch (ClassCastException e) {
                    // Session values are invalid
                }
            }
        }
        
        // If still not found, get the most recent quiz for this user
        if (subjectId == 0 || historyId == 0) {
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            
            try {
                // Database connection
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/quiz_db", "root", "");
                
                // Get most recent quiz history and subject
                pstmt = conn.prepareStatement(
                    "SELECT sc.history_id, sc.subject_id " +
                    "FROM scores sc " +
                    "WHERE sc.user_id = ? " +
                    "ORDER BY sc.date_taken DESC LIMIT 1"
                );
                pstmt.setInt(1, userId);
                rs = pstmt.executeQuery();
                
                if (rs.next()) {
                    historyId = rs.getInt("history_id");
                    subjectId = rs.getInt("subject_id");
                    session.setAttribute("history_id", historyId);
                    session.setAttribute("subject_id", subjectId);
                } else {
                    // No quiz history found, create dummy data for display
                    historyId = 1;
                    subjectId = 1;
                }
                
                rs.close();
                pstmt.close();
                conn.close();
            } catch (Exception e) {
                // If there's an error, just use default values
                historyId = 1;
                subjectId = 1;
            } finally {
                try { if (rs != null) rs.close(); } catch (Exception e) { }
                try { if (pstmt != null) pstmt.close(); } catch (Exception e) { }
                try { if (conn != null) conn.close(); } catch (Exception e) { }
            }
        }
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            // Database connection
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/quiz_db", "root", "");
            
            // Get questions and user answers for the selected quiz history
            String sql = "SELECT q.question_id, q.question_text, qa.is_correct " +
                         "FROM questions q " +
                         "JOIN quiz_answers qa ON q.question_id = qa.question_id " +
                         "WHERE qa.history_id = ? AND q.subject_id = ? " +
                         "ORDER BY q.question_id";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, historyId);
            pstmt.setInt(2, subjectId);
            rs = pstmt.executeQuery();
            
            List<Map<String, Object>> questions = new ArrayList<>();
            while (rs.next()) {
                Map<String, Object> question = new HashMap<>();
                question.put("id", rs.getInt("question_id"));
                question.put("text", rs.getString("question_text"));
                question.put("isCorrect", rs.getBoolean("is_correct"));
                
                // Get statistics for each question
                PreparedStatement statPstmt = conn.prepareStatement(
                    "SELECT COUNT(*) as total, SUM(CASE WHEN is_correct THEN 1 ELSE 0 END) as correct " +
                    "FROM quiz_answers WHERE question_id = ?"
                );
                statPstmt.setInt(1, rs.getInt("question_id"));
                ResultSet statRs = statPstmt.executeQuery();
                
                if (statRs.next()) {
                    int total = statRs.getInt("total");
                    int correct = statRs.getInt("correct");
                    question.put("correctPercentage", total > 0 ? (correct * 100 / total) : 75); // Default to 75% if no data
                    question.put("wrongPercentage", total > 0 ? ((total - correct) * 100 / total) : 25); // Default to 25% if no data
                } else {
                    // Default values if no statistics are found
                    question.put("correctPercentage", 75);
                    question.put("wrongPercentage", 25);
                }
                
                statRs.close();
                statPstmt.close();
                
                questions.add(question);
            }
            
            // If no questions found, add dummy data
            if (questions.isEmpty()) {
                for (int i = 1; i <= 3; i++) {
                    Map<String, Object> question = new HashMap<>();
                    question.put("id", i);
                    question.put("text", "Sample Question " + i);
                    question.put("isCorrect", i % 2 == 0); // Alternate between correct and incorrect
                    question.put("correctPercentage", 75);
                    question.put("wrongPercentage", 25);
                    questions.add(question);
                }
            }
    %>
   

<div class="header">
    <div class="logo">QUIZZEAH!✍(ᴗ‿ᴗ)</div>
    <div class="user-nav">
        <a href="Dashboard.jsp">Home</a>
        <a href="ScoreChart.jsp">Score</a>
        <a href="QuestionChart.jsp">Question Chart</a>
        <% 
        Boolean isTeacher = (Boolean) session.getAttribute("is_teacher");
        if (isTeacher != null && isTeacher) { 
        %>
            <a href="AdminPage.jsp">Admin</a>
        <% } %>
        <span class="username"><%= username %></span>
        <a href="Logout.jsp">Logout</a>
    </div>
</div>
        
        <div class="content">
            <div class="question-stats">
                <% for (Map<String, Object> question : questions) { 
                   int questionIndex = questions.indexOf(question) + 1;
                   boolean isCorrect = (Boolean) question.get("isCorrect");
                   int correctPercentage = (Integer) question.get("correctPercentage");
                   int wrongPercentage = (Integer) question.get("wrongPercentage");
                %>
                    <div class="stat-box">
                        <div class="question-number">
                            <span><%= questionIndex %>.</span>
                            <% if (isCorrect) { %>
                                <span class="correct-icon">✓</span>
                            <% } else { %>
                                <span class="wrong-icon">✗</span>
                            <% } %>
                        </div>
                        
                        <hr>
                        
                        <div class="chart-container">
                            <div class="pie-chart" style="background: conic-gradient(#4285f4 0% <%= correctPercentage %>%, #ffffff <%= correctPercentage %>% 100%);"></div>
                            
                            <div class="legend">
                                <div class="legend-item">
                                    <span class="color-dot blue-dot"></span>
                                    <span><%= correctPercentage %>% user right</span>
                                </div>
                                <div class="legend-item">
                                    <span class="color-dot gray-dot"></span>
                                    <span><%= wrongPercentage %>% user wrong</span>
                                </div>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>
            
            <div class="buttons">
                <a href="Dashboard.jsp" class="btn">next</a>
            </div>
        </div>
    </div>
    
    <%
        } catch (Exception e) {
            out.println("<div class='error'>Error: " + e.getMessage() + "</div>");
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) { }
            try { if (pstmt != null) pstmt.close(); } catch (Exception e) { }
            try { if (conn != null) conn.close(); } catch (Exception e) { }
        }
    %>
</body>
</html>