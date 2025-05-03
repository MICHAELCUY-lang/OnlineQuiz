<!-- score.jsp -->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="quiz.model.User, quiz.model.Score, java.util.List" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Online Quiz - Scores</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
    <script src="js/chart.js"></script>
</head>
<body>
    <% 
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        @SuppressWarnings("unchecked")
        List<Score> scores = (List<Score>) request.getAttribute("scores");
        
        @SuppressWarnings("unchecked")
        List<Object[]> chartData = (List<Object[]>) request.getAttribute("chartData");
    %>

    <div class="container">
        <div class="header">
            <h1>Online Quiz System</h1>
            <div class="user-info">
                <%= user.getUsername() %> | <a href="login.jsp">Logout</a>
            </div>
        </div>
        
        <div class="content-box">
            <h2>Quiz Scores</h2>
            
            <div class="dashboard-menu">
                <a href="dashboard.jsp" class="btn btn-secondary">Back to Dashboard</a>
            </div>
            
            <% if(scores != null && !scores.isEmpty()) { %>
                <div class="scores-list">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Subject</th>
                                <th>Score</th>
                                <th>Date Taken</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for(Score score : scores) { %>
                                <tr>
                                    <td><%= score.getSubjectName() != null ? score.getSubjectName() : "N/A" %></td>
                                    <td><%= score.getTotalScore() %></td>
                                    <td><%= score.getDateTaken() %></td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } else { %>
                <div class="no-data-message">
                    <p>You haven't taken any quizzes yet.</p>
                </div>
            <% } %>
            
            <!-- Performance Chart Section -->
            <% if(chartData != null && !chartData.isEmpty()) { %>
                <div class="chart-section">
                    <h3>Performance by Subject</h3>
                    <div class="chart-container">
                        <canvas id="performanceChart"></canvas>
                    </div>
                    
                    <script>
                        // Set up chart data
                        var ctx = document.getElementById('performanceChart').getContext('2d');
                        var chartLabels = [
                            <% 
                            for(int i = 0; i < chartData.size(); i++) { 
                                Object[] data = chartData.get(i);
                                String subject = (String) data[0];
                                if(i > 0) out.print(", ");
                                out.print("'" + subject + "'");
                            } 
                            %>
                        ];
                        
                        var chartValues = [
                            <% 
                            for(int i = 0; i < chartData.size(); i++) { 
                                Object[] data = chartData.get(i);
                                Float value = (Float) data[1];
                                if(i > 0) out.print(", ");
                                out.print(value);
                            } 
                            %>
                        ];
                        
                        // Create chart
                        var myChart = new Chart(ctx, {
                            type: 'pie',
                            data: {
                                labels: chartLabels,
                                datasets: [{
                                    data: chartValues,
                                    backgroundColor: [
                                        'rgba(255, 99, 132, 0.7)',
                                        'rgba(54, 162, 235, 0.7)',
                                        'rgba(255, 206, 86, 0.7)',
                                        'rgba(75, 192, 192, 0.7)',
                                        'rgba(153, 102, 255, 0.7)'
                                    ],
                                    borderColor: [
                                        'rgba(255, 99, 132, 1)',
                                        'rgba(54, 162, 235, 1)',
                                        'rgba(255, 206, 86, 1)',
                                        'rgba(75, 192, 192, 1)',
                                        'rgba(153, 102, 255, 1)'
                                    ],
                                    borderWidth: 1
                                }]
                            },
                            options: {
                                responsive: true,
                                title: {
                                    display: true,
                                    text: 'Performance by Subject (%)'
                                }
                            }
                        });
                    </script>
                </div>
            <% } %>
        </div>
    </div>
</body>
</html>