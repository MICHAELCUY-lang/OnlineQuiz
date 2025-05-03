<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, quiz.model.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Take Quiz - Online Quiz</title>
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
        
        // Get subjects
        List<Subject> subjects = (List<Subject>) request.getAttribute("subjects");
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
        <h1>Take Quiz</h1>
        
        <% if(request.getAttribute("errorMessage") != null) { %>
            <div class="alert alert-danger">
                <%= request.getAttribute("errorMessage") %>
            </div>
        <% } %>
        
        <div class="card">
            <div class="card-header">Select Quiz Options</div>
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
    </div>
    
    <footer>
        <div class="container">
            <p>&copy; 2025 Online Quiz. All rights reserved.</p>
        </div>
    </footer>
</body>
</html>