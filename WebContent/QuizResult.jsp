<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>QUIZZEAH! - Quiz Results</title>
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
        .results-container {
            background-color: white;
            border-radius: 10px;
            padding: 30px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }
        .results-header {
            text-align: center;
            margin-bottom: 30px;
        }
        .results-header h1 {
            margin: 0;
            font-size: 28px;
            color: #2c3e50;
        }
        .results-header p {
            color: #7f8c8d;
            margin-top: 10px;
        }
        .score-box {
            background-color: #f8f9fa;
            border-radius: 10px;
            padding: 30px;
            text-align: center;
            margin-bottom: 30px;
        }
        .score {
            font-size: 64px;
            font-weight: bold;
            margin: 0;
        }
        .score-high {
            color: #27ae60;
        }
        .score-medium {
            color: #f39c12;
        }
        .score-low {
            color: #e74c3c;
        }
        .score-label {
            color: #7f8c8d;
            margin-top: 10px;
            font-size: 18px;
        }
        .quiz-details {
            display: flex;
            justify-content: space-between;
            margin-bottom: 30px;
        }
        .detail-box {
            flex: 1;
            background-color: #f8f9fa;
            border-radius: 10px;
            padding: 20px;
            margin: 0 10px;
            text-align: center;
        }
        .detail-value {
            font-size: 24px;
            font-weight: bold;
            color: #2c3e50;
            margin: 0;
        }
        .detail-label {
            color: #7f8c8d;
            margin-top: 5px;
        }
        .actions {
            display: flex;
            justify-content: center;
            gap: 20px;
            margin-top: 40px;
        }
        .btn {
            display: inline-block;
            padding: 10px 25px;
            border-radius: 5px;
            text-decoration: none;
            font-weight: bold;
            cursor: pointer;
            transition: background-color 0.3s;
        }
        .btn-primary {
            background-color: #e74c3c;
            color: white;
        }
        .btn-primary:hover {
            background-color: #c0392b;
        }
        .btn-secondary {
            background-color: #ecf0f1;
            color: #2c3e50;
        }
        .btn-secondary:hover {
            background-color: #bdc3c7;
        }
        .error {
            color: #e74c3c;
            background-color: #fadbd8;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .confetti {
            position: fixed;
            width: 10px;
            height: 10px;
            background-color: #f39c12;
            opacity: 0;
            animation: confetti 5s ease-in-out infinite;
        }
        @keyframes confetti {
            0% {transform: translateY(0) rotate(0deg); opacity: 1;}
            100% {transform: translateY(100vh) rotate(720deg); opacity: 0;}
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
        
        // Get history ID from request or session
        String historyIdParam = request.getParameter("history_id");
        int historyId = 0;
        
        if (historyIdParam != null && !historyIdParam.isEmpty()) {
            try {
                historyId = Integer.parseInt(historyIdParam);
            } catch (Exception e) {
                // Invalid parameter
            }
        }
        
        if (historyId == 0) {
            // Try to get from session
            Object sessionHistoryId = session.getAttribute("history_id");
            if (sessionHistoryId instanceof Integer) {
                historyId = (Integer) sessionHistoryId;
            }
        }
        
        if (historyId == 0) {
            // No valid history ID found
            response.sendRedirect("Dashboard.jsp");
            return;
        }
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            // Database connection
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/quiz_db", "root", "");
            
            // Get quiz score and subject
            pstmt = conn.prepareStatement(
                "SELECT s.total_score, s.date_taken, sub.subject_name, " +
                "(SELECT COUNT(*) FROM quiz_answers WHERE history_id = ?) AS total_questions, " +
                "TIMESTAMPDIFF(MINUTE, h.start_time, h.end_time) AS duration " +
                "FROM scores s " +
                "JOIN subjects sub ON s.subject_id = sub.subject_id " +
                "JOIN quiz_history h ON s.history_id = h.history_id " +
                "WHERE s.history_id = ?");
            pstmt.setInt(1, historyId);
            pstmt.setInt(2, historyId);
            rs = pstmt.executeQuery();
            
            int totalScore = 0;
            int totalQuestions = 0;
            String subjectName = "";
            Timestamp dateTaken = null;
            int duration = 0;
            
            if (rs.next()) {
                totalScore = rs.getInt("total_score");
                totalQuestions = rs.getInt("total_questions");
                subjectName = rs.getString("subject_name");
                dateTaken = rs.getTimestamp("date_taken");
                duration = rs.getInt("duration");
            } else {
                // No score found, redirect to dashboard
                response.sendRedirect("Dashboard.jsp");
                return;
            }
            
            // Calculate the percentage
            int percentage = (totalQuestions > 0) ? (totalScore * 100 / totalQuestions) : 0;
            
            // Format date
            SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMM yyyy, HH:mm");
            String formattedDate = dateTaken != null ? dateFormat.format(dateTaken) : "N/A";
            
            // Determine score class
            String scoreClass = "";
            if (percentage >= 80) {
                scoreClass = "score-high";
            } else if (percentage >= 60) {
                scoreClass = "score-medium";
            } else {
                scoreClass = "score-low";
            }
            
            // Create confetti if score is high
            boolean showConfetti = percentage >= 80;
    %>
    
    <div class="container">
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
        
        <div class="results-container">
            <div class="results-header">
                <h1>Quiz Results</h1>
                <p>Great job completing the <%= subjectName %> quiz!</p>
            </div>
            
            <div class="score-box">
                <div class="score <%= scoreClass %>"><%= percentage %>%</div>
                <div class="score-label">You scored <%= totalScore %> out of <%= totalQuestions %> questions correctly</div>
            </div>
            
            <div class="quiz-details">
                <div class="detail-box">
                    <div class="detail-value"><%= subjectName %></div>
                    <div class="detail-label">Subject</div>
                </div>
                
                <div class="detail-box">
                    <div class="detail-value"><%= duration %> min</div>
                    <div class="detail-label">Duration</div>
                </div>
                
                <div class="detail-box">
                    <div class="detail-value"><%= formattedDate %></div>
                    <div class="detail-label">Date</div>
                </div>
            </div>
            
            <div class="actions">
                <a href="QuestionChart.jsp?history_id=<%= historyId %>" class="btn btn-primary">View Question Analysis</a>
                <a href="Dashboard.jsp" class="btn btn-secondary">Back to Dashboard</a>
            </div>
        </div>
    </div>
    
    <% if (showConfetti) { %>
        <script>
            // Create confetti elements
            function createConfetti() {
                for (let i = 0; i < 100; i++) {
                    const confetti = document.createElement('div');
                    confetti.className = 'confetti';
                    
                    // Random position, color, and delay
                    confetti.style.left = Math.random() * 100 + 'vw';
                    confetti.style.animationDelay = Math.random() * 5 + 's';
                    
                    // Random color
                    const colors = ['#e74c3c', '#f39c12', '#3498db', '#27ae60', '#9b59b6'];
                    confetti.style.backgroundColor = colors[Math.floor(Math.random() * colors.length)];
                    
                    document.body.appendChild(confetti);
                }
            }
            
            // Call the function when the page loads
            window.onload = createConfetti;
        </script>
    <% } %>
    
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