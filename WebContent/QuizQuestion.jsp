<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, quiz.model.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quiz Question - Online Quiz</title>
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
        
        // Get quiz session data
        List<Question> questions = (List<Question>) session.getAttribute("questions");
        int currentIndex = (int) session.getAttribute("currentQuestionIndex");
        
        if (questions == null || currentIndex >= questions.size()) {
            response.sendRedirect("QuizServlet");
            return;
        }
        
        Question currentQuestion = questions.get(currentIndex);
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
        <div class="question-container">
            <div class="progress-bar">
                Question <%= currentIndex + 1 %> of <%= questions.size() %>
            </div>
            
            <div class="question-text">
                <%= currentQuestion.getQuestionText() %>
            </div>
            
            <form action="QuizServlet" method="post">
                <input type="hidden" name="action" value="submitAnswer">
                
                <div class="options-container">
                    <% for (QuizOption option : currentQuestion.getOptions()) { %>
                        <label class="option">
                            <input type="radio" name="optionId" value="<%= option.getQuizId() %>" required>
                            <%= option.getOptionText() %>
                        </label>
                    <% } %>
                </div>
                
                <button type="submit" class="btn btn-primary">Submit Answer</button>
            </form>
        </div>
    </div>
    
    <footer>
        <div class="container">
            <p>&copy; 2025 Online Quiz. All rights reserved.</p>
        </div>
    </footer>
</body>
</html>