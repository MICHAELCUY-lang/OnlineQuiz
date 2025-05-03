<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, quiz.model.*, quiz.dao.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quiz Results - Online Quiz</title>
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
        
        // Get quiz session data
        QuizHistory history = (QuizHistory) session.getAttribute("quizHistory");
        List<Question> questions = (List<Question>) session.getAttribute("questions");
        List<QuizAnswer> selectedAnswers = (List<QuizAnswer>) session.getAttribute("selectedAnswers");
        
        if (history == null || questions == null || selectedAnswers == null) {
            response.sendRedirect("QuizServlet");
            return;
        }
        
        // Calculate score
        int correctCount = 0;
        for (QuizAnswer answer : selectedAnswers) {
            if (answer.isCorrect()) {
                correctCount++;
            }
        }
        
        // Get subject name
        String subjectName = "N/A";
        if (!questions.isEmpty()) {
            int subjectId = questions.get(0).getSubjectId();
            SubjectDAO subjectDAO = new SubjectDAO();
            Subject subject = subjectDAO.getSubjectById(subjectId);
            if (subject != null) {
                subjectName = subject.getSubjectName();
            }
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
        <h1>Quiz Results</h1>
        
        <div class="card">
            <div class="card-header">Summary</div>
            <div class="card-body">
                <div class="result-summary">
                    <div class="result-item">
                        <div class="result-label">Subject:</div>
                        <div class="result-value"><%= subjectName %></div>
                    </div>
                    
                    <div class="result-item">
                        <div class="result-label">Total Questions:</div>
                        <div class="result-value"><%= questions.size() %></div>
                    </div>
                    
                    <div class="result-item">
                        <div class="result-label">Correct Answers:</div>
                        <div class="result-value"><%= correctCount %></div>
                    </div>
                    
                    <div class="result-item">
                        <div class="result-label">Score:</div>
                        <div class="result-value"><%= correctCount %> / <%= questions.size() %></div>
                    </div>
                    
                    <div class="result-item">
                        <div class="result-label">Percentage:</div>
                        <div class="result-value">
                            <%= String.format("%.1f", (float) correctCount / questions.size() * 100) %>%
                        </div>
                    </div>
                </div>
                
                <div class="chart-container">
                    <canvas id="resultChart"></canvas>
                </div>
                
                <script>
                    document.addEventListener('DOMContentLoaded', function() {
                        const data = [<%= correctCount %>, <%= questions.size() - correctCount %>];
                        const labels = ['Correct', 'Incorrect'];
                        
                        createPieChart('resultChart', data, labels, 'Quiz Results');
                    });
                </script>
            </div>
        </div>
        
        <div class="card">
            <div class="card-header">Question Details</div>
            <div class="card-body">
                <div class="question-list">
                    <% 
                        // Create a map of question ID to answer
                        Map<Integer, QuizAnswer> answerMap = new HashMap<>();
                        for (QuizAnswer answer : selectedAnswers) {
                            answerMap.put(answer.getQuestionId(), answer);
                        }
                        
                        // Map of option ID to option
                        Map<Integer, QuizOption> optionMap = new HashMap<>();
                        for (Question question : questions) {
                            for (QuizOption option : question.getOptions()) {
                                optionMap.put(option.getQuizId(), option);
                            }
                        }
                        
                        for (int i = 0; i < questions.size(); i++) {
                            Question question = questions.get(i);
                            QuizAnswer answer = answerMap.get(question.getQuestionId());
                            QuizOption selectedOption = optionMap.get(answer.getSelectedOptionId());
                    %>
                    <div class="question-item <%= answer.isCorrect() ? "correct" : "incorrect" %>">
                        <div class="question-number">Question <%= i + 1 %></div>
                        <div class="question-text"><%= question.getQuestionText() %></div>
                        
                        <div class="options-list">
                            <% for (QuizOption option : question.getOptions()) { %>
                                <div class="option 
                                    <%= option.getQuizId() == answer.getSelectedOptionId() ? "selected" : "" %> 
                                    <%= option.isCorrect() ? "correct" : "" %>">
                                    <%= option.getOptionText() %>
                                    
                                    <% if (option.getQuizId() == answer.getSelectedOptionId() && !option.isCorrect()) { %>
                                        <span class="icon incorrect">❌</span>
                                    <% } else if (option.getQuizId() == answer.getSelectedOptionId() && option.isCorrect()) { %>
                                        <span class="icon correct">✓</span>
                                    <% } else if (option.isCorrect()) { %>
                                        <span class="icon correct">✓</span>
                                    <% } %>
                                </div>
                            <% } %>
                        </div>
                    </div>
                    <% } %>
                </div>
            </div>
        </div>
        
        <div class="action-buttons">
            <a href="QuizServlet" class="btn btn-primary">Take Another Quiz</a>
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