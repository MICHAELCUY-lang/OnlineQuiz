<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, quiz.model.*, quiz.dao.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Dashboard - Online Quiz</title>
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
        
        // Get performance data
        List<ChartData> performanceData = (List<ChartData>) request.getAttribute("performanceData");
        Map<String, Double> subjectScores = (Map<String, Double>) request.getAttribute("subjectScores");
        
        // Get subjects for the quiz selector
        List<Subject> subjects = (List<Subject>) request.getAttribute("subjects");
        
        // Get recent scores
        ScoreDAO scoreDAO = new ScoreDAO();
        List<Score> recentScores = scoreDAO.getScoresByUser(user.getUserId());
        if (recentScores.size() > 5) {
            recentScores = recentScores.subList(0, 5);
        }
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
        <h1>Welcome, <%= user.getUsername() %>!</h1>
        
        <div class="dashboard-stats">
            <div class="stat-card">
                <div class="stat-value">
                    <%= recentScores.size() %>
                </div>
                <div class="stat-label">Quizzes Taken</div>
            </div>
            
            <%
                double avgScore = 0;
                int totalScores = 0;
                
                for (Score score : recentScores) {
                    avgScore += score.getTotalScore();
                    totalScores++;
                }
                
                if (totalScores > 0) {
                    avgScore = avgScore / totalScores;
                }
            %>
            
            <div class="stat-card">
                <div class="stat-value">
                    <%= String.format("%.1f", avgScore) %>
                </div>
                <div class="stat-label">Average Score</div>
            </div>
            
            <%
                int bestScore = 0;
                String bestSubject = "N/A";
                
                for (Map.Entry<String, Double> entry : subjectScores.entrySet()) {
                    if (entry.getValue() > bestScore) {
                        bestScore = entry.getValue().intValue();
                        bestSubject = entry.getKey();
                    }
                }
            %>
            
            <div class="stat-card">
                <div class="stat-value">
                    <%= bestSubject %>
                </div>
                <div class="stat-label">Best Subject</div>
            </div>
        </div>
        
        <div class="row">
            <div class="card">
                <div class="card-header">Start a New Quiz</div>
                <div class="card-body">
                    <form action="QuizServlet" method="get">
                        <input type="hidden" name="action" value="start">
                        
                        <div class="form-group">
                            <label for="subjectId">Select Subject:</label>
                            <select id="subjectId" name="subjectId" required>
                                <% for (Subject subject : subjects) { %>
                                    <option value="<%= subject.getSubjectId() %>"><%= subject.getSubjectName() %></option>
                                <% } %>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label for="numQuestions">Number of Questions:</label>
                            <select id="numQuestions" name="numQuestions">
                                <option value="5">5</option>
                                <option value="10">10</option>
                                <option value="15">15</option>
                                <option value="20">20</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <button type="submit" class="btn btn-primary">Start Quiz</button>
                        </div>
                    </form>
                </div>
            </div>
            
            <div class="card">
                <div class="card-header">Recent Scores</div>
                <div class="card-body">
                    <% if (recentScores.isEmpty()) { %>
                        <p>No quizzes taken yet.</p>
                    <% } else { %>
                        <table class="table">
                            <thead>
                                <tr>
                                    <th>Date</th>
                                    <th>Subject</th>
                                    <th>Score</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% 
                                    SubjectDAO subjectDAO = new SubjectDAO();
                                    for (Score score : recentScores) {
                                        String subjectName = "N/A";
                                        if (score.getSubjectId() != null) {
                                            Subject subject = subjectDAO.getSubjectById(score.getSubjectId());
                                            if (subject != null) {
                                                subjectName = subject.getSubjectName();
                                            }
                                        }
                                %>
                                <tr>
                                    <td><%= score.getDateTaken() %></td>
                                    <td><%= subjectName %></td>
                                    <td><%= score.getTotalScore() %></td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                        <a href="ScoreServlet" class="btn">View All Scores</a>
                    <% } %>
                </div>
            </div>
        </div>
        
        <div class="card">
            <div class="card-header">Performance by Subject</div>
            <div class="card-body">
                <div class="chart-container">
                    <canvas id="performanceChart"></canvas>
                </div>
                
                <script>
                    document.addEventListener('DOMContentLoaded', function() {
                        const data = [];
                        const labels = [];
                        
                        <% for (Map.Entry<String, Double> entry : subjectScores.entrySet()) { %>
                            data.push(<%= entry.getValue() %>);
                            labels.push('<%= entry.getKey() %>');
                        <% } %>
                        
                        createBarChart('performanceChart', data, labels, 'Average Score by Subject', 'Score');
                    });
                </script>
            </div>
        </div>
    </div>
    
    <footer>
        <div class="container">
            <p>&copy; 2025 Online Quiz. All rights reserved.</p>
        </div>
    </footer>
</body>
</html>