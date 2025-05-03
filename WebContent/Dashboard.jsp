<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>QUIZZEAH! - Dashboard</title>
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
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }
        .logo {
            font-size: 28px;
            font-weight: bold;
            color: #2c3e50;
        }
        .logo span {
            color: #e74c3c;
        }
        .user-nav {
            display: flex;
            align-items: center;
            gap: 20px;
        }
        .user-nav a {
            text-decoration: none;
            color: #2c3e50;
            font-weight: 500;
        }
        .user-nav a:hover {
            color: #e74c3c;
        }
        .username {
            font-weight: bold;
            color: #e74c3c;
        }
        .welcome {
            background-color: white;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 30px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .welcome h1 {
            margin: 0;
            font-size: 24px;
            color: #2c3e50;
        }
        .welcome p {
            margin: 10px 0 0;
            color: #7f8c8d;
        }
        .quiz-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
        }
        .quiz-card {
            background-color: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .quiz-title {
            font-size: 20px;
            font-weight: bold;
            margin: 0 0 10px;
            color: #2c3e50;
        }
        .quiz-meta {
            color: #7f8c8d;
            margin-bottom: 15px;
            font-size: 14px;
        }
        .quiz-meta div {
            margin-bottom: 5px;
        }
        .attempt-btn {
            display: inline-block;
            background-color: #e74c3c;
            color: white;
            padding: 8px 20px;
            border-radius: 5px;
            text-decoration: none;
            font-weight: bold;
            transition: background-color 0.3s;
        }
        .attempt-btn:hover {
            background-color: #c0392b;
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
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            // Database connection
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/quiz_db", "root", "");
            
            // Get subjects
            pstmt = conn.prepareStatement("SELECT subject_id, subject_name, description FROM subjects ORDER BY subject_name");
            rs = pstmt.executeQuery();
            
            List<Map<String, Object>> subjects = new ArrayList<>();
            while (rs.next()) {
                Map<String, Object> subject = new HashMap<>();
                subject.put("id", rs.getInt("subject_id"));
                subject.put("name", rs.getString("subject_name"));
                subject.put("description", rs.getString("description"));
                subjects.add(subject);
            }
    %>


<div class="header">
    <div class="logo">QUIZZEAH! <span>✍(ᴗ‿ᴗ)</span></div>
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
        
        <div class="welcome">
            <h1>Hello dear user!</h1>
            <p>Ready for the test? Keep it up my sweetheart, choose which one you wanna take</p>
        </div>
        
        <div class="quiz-grid">
            <% for (Map<String, Object> subject : subjects) { %>
                <div class="quiz-card">
                    <h3 class="quiz-title"><%= subject.get("name") %></h3>
                    <div class="quiz-meta">
                        <div>70 questions</div>
                        <div>2 hours 30 minutes</div>
                        <div>Open book</div>
                    </div>
                    <a href="Quiz.jsp?subject_id=<%= subject.get("id") %>" class="attempt-btn">Attempt</a>
                </div>
            <% } %>
            
            <!-- Additional cards to match the Figma design -->
            <div class="quiz-card">
                <h3 class="quiz-title">Math</h3>
                <div class="quiz-meta">
                    <div>70 questions</div>
                    <div>2 hours 30 minutes</div>
                    <div>Open book</div>
                </div>
                <a href="#" class="attempt-btn">Attempt</a>
            </div>
            
            <div class="quiz-card">
                <h3 class="quiz-title">Math</h3>
                <div class="quiz-meta">
                    <div>70 questions</div>
                    <div>2 hours 30 minutes</div>
                    <div>Open book</div>
                </div>
                <a href="#" class="attempt-btn">Attempt</a>
            </div>
            
            <div class="quiz-card">
                <h3 class="quiz-title">Math</h3>
                <div class="quiz-meta">
                    <div>70 questions</div>
                    <div>2 hours 30 minutes</div>
                    <div>Open book</div>
                </div>
                <a href="#" class="attempt-btn">Attempt</a>
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