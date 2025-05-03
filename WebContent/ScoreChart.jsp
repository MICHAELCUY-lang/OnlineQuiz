<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>QUIZZEAH! - Score Chart</title>
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
        .scores-container {
            background-color: white;
            border-radius: 10px;
            padding: 30px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }
        .page-title {
            font-size: 24px;
            color: #2c3e50;
            margin-bottom: 20px;
        }
        .chart-container {
            width: 100%;
            height: 400px;
            margin-bottom: 30px;
        }
        .scores-table {
            width: 100%;
            border-collapse: collapse;
        }
        .scores-table th, .scores-table td {
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid #ecf0f1;
        }
        .scores-table th {
            background-color: #f8f9fa;
            color: #2c3e50;
            font-weight: bold;
        }
        .scores-table tr:hover {
            background-color: #f8f9fa;
        }
        .score-value {
            font-weight: bold;
        }
        .high-score {
            color: #27ae60;
        }
        .medium-score {
            color: #f39c12;
        }
        .low-score {
            color: #e74c3c;
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
        .error {
            color: #e74c3c;
            background-color: #fadbd8;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .no-data {
            text-align: center;
            padding: 30px;
            color: #7f8c8d;
            font-style: italic;
        }
    </style>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            // Database connection
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/quiz_db", "root", "");
            
            // Get all scores for this user
            pstmt = conn.prepareStatement(
                "SELECT s.score_id, s.total_score, s.date_taken, " +
                "sub.subject_name, " +
                "(SELECT COUNT(*) FROM quiz_answers WHERE history_id = s.history_id) AS total_questions " +
                "FROM scores s " +
                "JOIN subjects sub ON s.subject_id = sub.subject_id " +
                "WHERE s.user_id = ? " +
                "ORDER BY s.date_taken DESC"
            );
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();
            
            List<Map<String, Object>> scores = new ArrayList<>();
            while (rs.next()) {
                Map<String, Object> score = new HashMap<>();
                score.put("id", rs.getInt("score_id"));
                score.put("totalScore", rs.getInt("total_score"));
                score.put("dateTaken", rs.getTimestamp("date_taken"));
                score.put("subjectName", rs.getString("subject_name"));
                score.put("totalQuestions", rs.getInt("total_questions"));
                
                // Calculate percentage
                int totalScore = rs.getInt("total_score");
                int totalQuestions = rs.getInt("total_questions");
                int percentage = (totalQuestions > 0) ? (totalScore * 100 / totalQuestions) : 0;
                score.put("percentage", percentage);
                
                scores.add(score);
            }
            
            // Format date for display
            SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMM yyyy, HH:mm");
            
            // Prepare chart data
            List<String> labels = new ArrayList<>();
            List<Integer> data = new ArrayList<>();
            
            for (int i = Math.min(scores.size() - 1, 9); i >= 0; i--) {
                Map<String, Object> score = scores.get(i);
                labels.add("'" + score.get("subjectName") + "'");
                data.add((Integer) score.get("percentage"));
            }
    %>
    
    <div class="container">
        <div class="header">
            <div class="logo">QUIZZEAH! <span>✍(ᴗ‿ᴗ)</span></div>
            <div class="user-nav">
                <a href="Dashboard.jsp">Home</a>
                <a href="ScoreChart.jsp">Score</a>
                <a href="QuestionChart.jsp">Question Chart</a>
                <span class="username"><%= username %></span>
                <a href="Logout.jsp">Logout</a>
            </div>
        </div>
        
        <div class="scores-container">
            <h2 class="page-title">Your Quiz Performance</h2>
            
            <% if (scores.isEmpty()) { %>
                <div class="no-data">You haven't taken any quizzes yet. Go to the dashboard to start!</div>
            <% } else { %>
                <div class="chart-container">
                    <canvas id="scoresChart"></canvas>
                </div>
                
                <table class="scores-table">
                    <thead>
                        <tr>
                            <th>Subject</th>
                            <th>Score</th>
                            <th>Percentage</th>
                            <th>Date</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Map<String, Object> score : scores) { 
                            int percentage = (Integer) score.get("percentage");
                            String scoreClass = "";
                            if (percentage >= 80) {
                                scoreClass = "high-score";
                            } else if (percentage >= 60) {
                                scoreClass = "medium-score";
                            } else {
                                scoreClass = "low-score";
                            }
                        %>
                            <tr>
                                <td><%= score.get("subjectName") %></td>
                                <td><%= score.get("totalScore") %>/<%= score.get("totalQuestions") %></td>
                                <td class="score-value <%= scoreClass %>"><%= percentage %>%</td>
                                <td><%= dateFormat.format((Timestamp) score.get("dateTaken")) %></td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } %>
        </div>
    </div>
    
    <% if (!scores.isEmpty()) { %>
    <script>
        // Create chart
        var ctx = document.getElementById('scoresChart').getContext('2d');
        var myChart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: [<%= String.join(", ", labels) %>],
                datasets: [{
                    label: 'Score Percentage',
                    data: [<%= data.stream().map(Object::toString).reduce((a, b) -> a + ", " + b).orElse("") %>],
                    backgroundColor: '#e74c3c',
                    borderColor: '#c0392b',
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    y: {
                        beginAtZero: true,
                        max: 100,
                        title: {
                            display: true,
                            text: 'Percentage'
                        }
                    },
                    x: {
                        title: {
                            display: true,
                            text: 'Subject'
                        }
                    }
                },
                plugins: {
                    title: {
                        display: true,
                        text: 'Your Recent Quiz Scores',
                        font: {
                            size: 18
                        }
                    }
                }
            }
        });
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