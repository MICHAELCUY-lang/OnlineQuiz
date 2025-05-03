<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, quiz.model.*, quiz.dao.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>User Management - Online Quiz</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
</head>
<body>
    <%
        // Check if user is logged in and is a teacher
        User user = (User) session.getAttribute("user");
        if (user == null || !user.isTeacher()) {
            response.sendRedirect("Login.jsp");
            return;
        }
        
        // Get users
        List<User> users = (List<User>) request.getAttribute("users");
    %>
    
    <header>
        <div class="container">
            <div class="logo">Online Quiz Admin</div>
            <nav>
                <ul>
                    <li><a href="AdminServlet">Dashboard</a></li>
                    <li><a href="AdminServlet?action=listQuestions">Questions</a></li>
                    <li><a href="AdminServlet?action=listSubjects">Subjects</a></li>
                    <li><a href="AdminServlet?action=listUsers">Users</a></li>
                    <li><a href="Login.jsp">Logout</a></li>
                </ul>
            </nav>
        </div>
    </header>
    
    <div class="container">
        <h1>User Management</h1>
        
        <div class="card">
            <div class="card-header">All Users</div>
            <div class="card-body">
                <% if (users.isEmpty()) { %>
                    <p>No users available.</p>
                <% } else { %>
                    <table class="table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Username</th>
                                <th>Role</th>
                                <th>Quiz Count</th>
                                <th>Average Score</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% 
                                ScoreDAO scoreDAO = new ScoreDAO();
                                for (User u : users) {
                                    List<Score> scores = scoreDAO.getScoresByUser(u.getUserId());
                                    double avgScore = 0;
                                    if (!scores.isEmpty()) {
                                        for (Score score : scores) {
                                            avgScore += score.getTotalScore();
                                        }
                                        avgScore /= scores.size();
                                    }
                            %>
                            <tr>
                                <td><%= u.getUserId() %></td>
                                <td><%= u.getUsername() %></td>
                                <td><%= u.isTeacher() ? "Teacher" : "Student" %></td>
                                <td><%= scores.size() %></td>
                                <td><%= scores.isEmpty() ? "N/A" : String.format("%.1f", avgScore) %></td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                <% } %>
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