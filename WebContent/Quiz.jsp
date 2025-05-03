<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>QUIZZEAH! - Take Quiz</title>
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
        .quiz-container {
            background-color: white;
            border-radius: 10px;
            padding: 30px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }
        .quiz-header {
            margin-bottom: 20px;
        }
        .quiz-header h1 {
            margin: 0;
            font-size: 24px;
            color: #2c3e50;
        }
        .quiz-progress {
            margin: 20px 0;
        }
        .progress-text {
            display: flex;
            justify-content: space-between;
            margin-bottom: 5px;
            font-weight: 500;
        }
        .progress-bar {
            height: 8px;
            background-color: #ecf0f1;
            border-radius: 4px;
            overflow: hidden;
        }
        .progress {
            height: 100%;
            background-color: #e74c3c;
            border-radius: 4px;
        }
        .question {
            margin-bottom: 30px;
        }
        .question-text {
            font-size: 20px;
            font-weight: 500;
            margin-bottom: 20px;
            color: #2c3e50;
        }
        .options-list {
            display: flex;
            flex-direction: column;
            gap: 15px;
        }
        .option {
            display: flex;
            align-items: center;
            padding: 12px 20px;
            background-color: #f8f9fa;
            border-radius: 5px;
            cursor: pointer;
            transition: background-color 0.3s;
        }
        .option:hover {
            background-color: #e9ecef;
        }
        .option input[type="radio"] {
            margin-right: 15px;
        }
        .option label {
            font-size: 16px;
            cursor: pointer;
            width: 100%;
        }
        .quiz-actions {
            display: flex;
            justify-content: space-between;
            margin-top: 30px;
        }
        .btn {
            display: inline-block;
            padding: 10px 25px;
            border-radius: 5px;
            text-decoration: none;
            font-weight: bold;
            cursor: pointer;
            border: none;
            transition: background-color 0.3s;
        }
        .btn-primary {
            background-color: #e74c3c;
            color: white;
        }
        .btn-primary:hover {
            background-color: #c0392b;
        }
        .btn-secondary {
            background-color: #ecf0f1;
            color: #2c3e50;
        }
        .btn-secondary:hover {
            background-color: #bdc3c7;
        }
        .timer {
            font-size: 18px;
            font-weight: bold;
            color: #e74c3c;
            margin-bottom: 20px;
            text-align: right;
        }
        .error {
            color: #e74c3c;
            background-color: #fadbd8;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <%
        // Check if user is logged in
        String username = (String) session.getAttribute("username");
        if (username == null) {
            response.sendRedirect("Login.jsp");
            return;
        }
        
        // Get subject ID from request
        String subjectIdParam = request.getParameter("subject_id");
        int subjectId = 0;
        try {
            subjectId = Integer.parseInt(subjectIdParam);
        } catch (Exception e) {
            response.sendRedirect("Dashboard.jsp");
            return;
        }
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        String subjectName = "";
        List<Map<String, Object>> questions = new ArrayList<>();
        
        try {
            // Database connection
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/quiz_db", "root", "");
            
            // Get subject name
            pstmt = conn.prepareStatement("SELECT subject_name FROM subjects WHERE subject_id = ?");
            pstmt.setInt(1, subjectId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                subjectName = rs.getString("subject_name");
            } else {
                response.sendRedirect("Dashboard.jsp");
                return;
            }
            
            // Get questions for this subject
            pstmt = conn.prepareStatement("SELECT question_id, question_text, correct_answer FROM questions WHERE subject_id = ? ORDER BY RAND() LIMIT 10");
            pstmt.setInt(1, subjectId);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> question = new HashMap<>();
                question.put("id", rs.getInt("question_id"));
                question.put("text", rs.getString("question_text"));
                question.put("correct_answer", rs.getString("correct_answer"));
                
                // Get options for this question - Using "quiz" table
                List<Map<String, Object>> options = new ArrayList<>();
                PreparedStatement optStmt = conn.prepareStatement(
                    "SELECT quiz_id, option_text, is_correct FROM quiz WHERE question_id = ?");
                optStmt.setInt(1, rs.getInt("question_id"));
                ResultSet optRs = optStmt.executeQuery();
                
                while (optRs.next()) {
                    Map<String, Object> option = new HashMap<>();
                    option.put("id", optRs.getInt("quiz_id"));
                    option.put("text", optRs.getString("option_text"));
                    option.put("correct", optRs.getBoolean("is_correct"));
                    options.add(option);
                }
                
                question.put("options", options);
                questions.add(question);
                
                optRs.close();
                optStmt.close();
            }
            
            // If no questions were found
            if (questions.isEmpty()) {
                out.println("<div class='error'>No questions found for this subject. Please go back and try another subject.</div>");
                return;
            }
            
            // Store questions in session
            session.setAttribute("quizQuestions", questions);
            session.setAttribute("currentQuestionIndex", 0);
            session.setAttribute("userAnswers", new HashMap<Integer, Integer>());
            session.setAttribute("quizStartTime", System.currentTimeMillis());
            
            // Create a new quiz history record
            PreparedStatement historyStmt = conn.prepareStatement(
                "INSERT INTO quiz_history (user_id) SELECT user_id FROM users WHERE username = ?", 
                Statement.RETURN_GENERATED_KEYS);
            historyStmt.setString(1, username);
            historyStmt.executeUpdate();
            
            ResultSet generatedKeys = historyStmt.getGeneratedKeys();
            int historyId = -1;
            if (generatedKeys.next()) {
                historyId = generatedKeys.getInt(1);
                session.setAttribute("currentHistoryId", historyId);
            }
            generatedKeys.close();
            historyStmt.close();
            
            // Get the current question
            int currentQuestionIndex = 0;
            Map<String, Object> currentQuestion = questions.get(currentQuestionIndex);
            List<Map<String, Object>> options = (List<Map<String, Object>>) currentQuestion.get("options");
    %>
    
    <div class="container">
        <div class="header">
            <div class="logo">QUIZZEAH! <span>✍(ᴗ‿ᴗ)</span></div>
            <div class="user-nav">
                <a href="Dashboard.jsp">Home</a>
                <a href="ScoreChart.jsp">Score</a>
                <span class="username"><%= username %></span>
                <a href="Logout.jsp">Logout</a>
            </div>
        </div>
        
        <div class="quiz-container">
            <div class="quiz-header">
                <h1><%= subjectName %> Quiz</h1>
                <div class="timer">Time remaining: <span id="timer">30:00</span></div>
            </div>
            
            <div class="quiz-progress">
                <div class="progress-text">
                    <span>Question <%= currentQuestionIndex + 1 %> of <%= questions.size() %></span>
                    <span><%= (currentQuestionIndex + 1) * 100 / questions.size() %>% Complete</span>
                </div>
                <div class="progress-bar">
                    <div class="progress" style="width: <%= (currentQuestionIndex + 1) * 100 / questions.size() %>%"></div>
                </div>
            </div>
            
            <div class="question">
                <div class="question-text"><%= currentQuestion.get("text") %></div>
                
                <form action="SubmitAnswer.jsp" method="post" id="quizForm">
                    <input type="hidden" name="questionId" value="<%= currentQuestion.get("id") %>">
                    <input type="hidden" name="historyId" value="<%= historyId %>">
                    <input type="hidden" name="subjectId" value="<%= subjectId %>">
                    
                    <div class="options-list">
                        <% if (options == null || options.isEmpty()) { %>
                            <div class="error">No options found for this question.</div>
                        <% } else { %>
                            <% for(Map<String, Object> option : options) { %>
                                <div class="option">
                                    <input type="radio" name="selectedOption" id="option<%= option.get("id") %>" 
                                           value="<%= option.get("id") %>" required>
                                    <label for="option<%= option.get("id") %>"><%= option.get("text") %></label>
                                </div>
                            <% } %>
                        <% } %>
                    </div>
                    
                    <div class="quiz-actions">
                        <button type="submit" class="btn btn-secondary" id="btnPrevious" name="action" value="previous"
                                <% if(currentQuestionIndex == 0) { %>disabled<% } %>>Previous</button>
                        <button type="submit" class="btn btn-primary" name="action" value="next">
                            <% if(currentQuestionIndex == questions.size() - 1) { %>Finish<% } else { %>Next<% } %>
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <script>
        // Timer functionality
        function startTimer(duration, display) {
            var timer = duration, minutes, seconds;
            setInterval(function () {
                minutes = parseInt(timer / 60, 10);
                seconds = parseInt(timer % 60, 10);

                minutes = minutes < 10 ? "0" + minutes : minutes;
                seconds = seconds < 10 ? "0" + seconds : seconds;

                display.textContent = minutes + ":" + seconds;

                if (--timer < 0) {
                    // Time's up - submit the quiz
                    document.getElementById('quizForm').submit();
                }
            }, 1000);
        }

        window.onload = function () {
            var thirtyMinutes = 60 * 30,
                display = document.querySelector('#timer');
            startTimer(thirtyMinutes, display);
        };
    </script>
    
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