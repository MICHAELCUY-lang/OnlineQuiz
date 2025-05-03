<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, quiz.model.*, quiz.dao.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Your Scores - Online Quiz</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
</head>
<body>
    <%
        // Check if user is logged in
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect("Login.jsp");
            return;
        }
        
        // Get scores
        List<Score> scores = (List<Score>) request.getAttribute("scores");
        if (scores == null) {
            ScoreDAO scoreDAO = new ScoreDAO();
            scores = scoreDAO.getScoresByUser(user.getUserId());
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
        <h1>Your Scores</h1>
        
        <div class="card">
            <div class="card-header">Score History</div>
            <div class="card-body">
                <% if (scores.isEmpty()) { %>
                    <p>No quizzes taken yet.</p>
                <% } else { %>
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Date</th>
                                <th>Subject</th>
                                <th>Score</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% 
                                SubjectDAO subjectDAO = new SubjectDAO();
                                for (Score score : scores) {
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
                                <td>
                                    <a href="ScoreServlet?action=detail&scoreId=<%= score.getScoreId() %>" class="btn btn-primary">View Details</a>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                <% } %>
                
                <div class="action-buttons">
                    <a href="QuizServlet" class="btn btn-primary">Take New Quiz</a>
                    <a href="ScoreServlet?action=chart" class="btn">View Performance Charts</a>
                </div>
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