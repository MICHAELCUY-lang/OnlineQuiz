<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, quiz.model.*, quiz.dao.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Performance Charts - Online Quiz</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@2.9.4/dist/Chart.min.js"></script>
    <script src="js/chart.js"></script>
</head>
<body>
    <%
        // Check if user is logged in
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect("Login.jsp");
            return;
        }
        
        // Get subject scores
        Map<String, Double> subjectScores = (Map<String, Double>) request.getAttribute("subjectScores");
        if (subjectScores == null) {
            ScoreDAO scoreDAO = new ScoreDAO();
            subjectScores = scoreDAO.getUserScoresBySubject(user.getUserId());
        }
        
        // Get performance data
        ChartDataDAO chartDataDAO = new ChartDataDAO();
        List<ChartData> performanceData = chartDataDAO.getChartDataByUser(user.getUserId());
        
        // Get scores by date for trend chart
        ScoreDAO scoreDAO = new ScoreDAO();
        List<Score> scores = scoreDAO.getScoresByUser(user.getUserId());
    %>
    
    <header>
        <div class="container">
            <div class="logo">Online Quiz</div>
            <nav>
                <ul>
                    <li><a href="DashboardServlet">Dashboard</a></li>
                    <li><a href="QuizServlet">Take Quiz</a></li>
                    <li><a href="ScoreServlet">View Scores</a></li>
                    <li><a href="ScoreServlet?action=chart">Performance Charts</a></li>
                    <li><a href="Login.jsp">Logout</a></li>
                </ul>
            </nav>
        </div>
    </header>
    
    <div class="container">
        <h1>Performance Charts</h1>
        
        <div class="card">
            <div class="card-header">Performance by Subject</div>
            <div class="card-body">
                <% if (subjectScores.isEmpty()) { %>
                    <p>No data available. Take some quizzes to see your performance.</p>
                <% } else { %>
                    <div class="chart-container">
                        <canvas id="subjectChart"></canvas>
                    </div>
                    
                    <script>
                        document.addEventListener('DOMContentLoaded', function() {
                            const data = [];
                            const labels = [];
                            
                            <% for (Map.Entry<String, Double> entry : subjectScores.entrySet()) { %>
                                data.push(<%= entry.getValue() %>);
                                labels.push('<%= entry.getKey() %>');
                            <% } %>
                            
                            createBarChart('subjectChart', data, labels, 'Average Score by Subject', 'Score');
                        });
                    </script>
                <% } %>
            </div>
        </div>
        
        <div class="card">
            <div class="card-header">Performance Distribution</div>
            <div class="card-body">
                <% if (subjectScores.isEmpty()) { %>
                    <p>No data available. Take some quizzes to see your performance.</p>
                <% } else { %>
                    <div class="chart-container">
                        <canvas id="pieChart"></canvas>
                    </div>
                    
                    <script>
                        document.addEventListener('DOMContentLoaded', function() {
                            const data = [];
                            const labels = [];
                            
                            <% for (Map.Entry<String, Double> entry : subjectScores.entrySet()) { %>
                                data.push(<%= entry.getValue() %>);
                                labels.push('<%= entry.getKey() %>');
                            <% } %>
                            
                            createPieChart('pieChart', data, labels, 'Score Distribution by Subject');
                        });
                    </script>
                <% } %>
            </div>
        </div>
        
        <div class="card">
            <div class="card-header">Performance Trend</div>
            <div class="card-body">
                <% if (scores.isEmpty()) { %>
                    <p>No data available. Take some quizzes to see your performance trend.</p>
                <% } else { %>
                    <div class="chart-container">
                        <canvas id="trendChart"></canvas>
                    </div>
                    
                    <script>
                        document.addEventListener('DOMContentLoaded', function() {
                            // Group scores by subject
                            const scoresBySubject = {};
                            
                            <% 
                                SubjectDAO subjectDAO = new SubjectDAO();
                                Map<Integer, List<Score>> scoresBySubjectId = new HashMap<>();
                                
                                for (Score score : scores) {
                                    if (score.getSubjectId() != null) {
                                        List<Score> subjectScores = scoresBySubjectId.getOrDefault(score.getSubjectId(), new ArrayList<>());
                                        subjectScores.add(score);
                                        scoresBySubjectId.put(score.getSubjectId(), subjectScores);
                                    }
                                }
                                
                                for (Map.Entry<Integer, List<Score>> entry : scoresBySubjectId.entrySet()) {
                                    Subject subject = subjectDAO.getSubjectById(entry.getKey());
                                    if (subject != null) {
                                        String subjectName = subject.getSubjectName();
                            %>
                                scoresBySubject['<%= subjectName %>'] = [
                                    <% for (Score score : entry.getValue()) { %>
                                        <%= score.getTotalScore() %>,
                                    <% } %>
                                ];
                            <% 
                                    }
                                }
                            %>
                            
                            const datasets = [];
                            const colors = [
                                '#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0', '#9966FF',
                                '#FF9F40', '#C9CBCF', '#7CFC00', '#00CED1', '#FF7F50'
                            ];
                            
                            let colorIndex = 0;
                            for (const subject in scoresBySubject) {
                                datasets.push({
                                    label: subject,
                                    data: scoresBySubject[subject],
                                    borderColor: colors[colorIndex % colors.length],
                                    backgroundColor: 'transparent',
                                    pointBackgroundColor: colors[colorIndex % colors.length],
                                    pointRadius: 5
                                });
                                colorIndex++;
                            }
                            
                            const ctx = document.getElementById('trendChart').getContext('2d');
                            new Chart(ctx, {
                                type: 'line',
                                data: {
                                    labels: Array.from({ length: Math.max(...Object.values(scoresBySubject).map(arr => arr.length)) }, (_, i) => i + 1),
                                    datasets: datasets
                                },
                                options: {
                                    responsive: true,
                                    maintainAspectRatio: false,
                                    title: {
                                        display: true,
                                        text: 'Score Trend by Subject',
                                        fontSize: 16
                                    },
                                    scales: {
                                        yAxes: [{
                                            ticks: {
                                                beginAtZero: true
                                            },
                                            scaleLabel: {
                                                display: true,
                                                labelString: 'Score'
                                            }
                                        }],
                                        xAxes: [{
                                            scaleLabel: {
                                                display: true,
                                                labelString: 'Quiz Number'
                                            }
                                        }]
                                    },
                                    legend: {
                                        position: 'bottom'
                                    }
                                }
                            });
                        });
                    </script>
                <% } %>
            </div>
        </div>
        
        <div class="action-buttons">
            <a href="ScoreServlet" class="btn">View Score History</a>
            <a href="DashboardServlet" class="btn">Back to Dashboard</a>
        </div>
    </div>
    
    <footer>
        <div class="container">
            <p>&copy; 2025 Online Quiz. All rights reserved.</p>
        </div>
    </footer>
</body>
</html>