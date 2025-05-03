<!-- quiz.jsp -->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="quiz.model.User, quiz.model.Question, quiz.model.QuizOption, java.util.List" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Online Quiz - Take Quiz</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
</head>
<body>
    <% 
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        @SuppressWarnings("unchecked")
        List<Question> quizQuestions = (List<Question>) session.getAttribute("quizQuestions");
        
        if (quizQuestions == null || quizQuestions.isEmpty()) {
            response.sendRedirect("dashboard.jsp");
            return;
        }
        
        int currentQuestionIndex = (int) session.getAttribute("currentQuestionIndex");
        Question currentQuestion = quizQuestions.get(currentQuestionIndex);
        
        @SuppressWarnings("unchecked")
        List<QuizOption> options = (List<QuizOption>) session.getAttribute("options_" + currentQuestion.getQuestionId());
    %>

    <div class="container">
        <div class="header">
            <h1>Online Quiz System</h1>
            <div class="user-info">
                <%= user.getUsername() %> | <a href="login.jsp">Logout</a>
            </div>
        </div>
        
        <div class="content-box">
            <h2><%= currentQuestion.getSubjectName() %> Quiz</h2>
            
            <div class="quiz-progress">
                Question <%= currentQuestionIndex + 1 %> of <%= quizQuestions.size() %>
                <div class="progress-bar">
                    <div class="progress" style="width: <%= (currentQuestionIndex + 1) * 100 / quizQuestions.size() %>%"></div>
                </div>
            </div>
            
            <div class="quiz-question">
                <h3><%= currentQuestion.getQuestionText() %></h3>
                
                <form action="quiz" method="post">
                    <div class="options-list">
                        <% for(QuizOption option : options) { %>
                            <div class="option">
                                <input type="radio" name="selectedOption" id="option<%= option.getQuizId() %>" 
                                       value="<%= option.getQuizId() %>" required>
                                <label for="option<%= option.getQuizId() %>"><%= option.getOptionText() %></label>
                            </div>
                        <% } %>
                    </div>
                    
                    <div class="form-group">
                        <button type="submit" class="btn btn-primary">Next</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</body>
</html>