<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>QUIZZEAH! - Admin Page</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #1a1a1a;
            color: #333;
        }
        .container {
            width: 100%;
            max-width: 800px;
            margin: 0 auto;
            background-color: #fff;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }
        .header {
            background-color: #e0e0e0;
            padding: 15px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .logo {
            font-size: 24px;
            font-weight: bold;
        }
        .logout {
            font-size: 14px;
        }
        .logout a {
            color: #333;
            text-decoration: none;
        }
        .content {
            padding: 20px;
        }
        .welcome {
            font-size: 20px;
            margin-bottom: 15px;
        }
        .admin-form {
            background-color: #e0e0e0;
            padding: 20px;
            margin-bottom: 20px;
        }
        .form-row {
            margin-bottom: 15px;
        }
        .form-row label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        .form-row input[type="text"],
        .form-row textarea {
            width: 100%;
            padding: 8px;
            box-sizing: border-box;
            border: 1px solid #ccc;
        }
        .question-block {
            background-color: #d0d0d0;
            padding: 15px;
            margin-bottom: 15px;
            position: relative;
        }
        .question-block p {
            margin-top: 0;
            margin-bottom: 10px;
        }
        .option-row {
            margin-bottom: 10px;
        }
        .option-row input[type="text"] {
            width: 70%;
            padding: 8px;
            margin-right: 10px;
            border: 1px solid #ccc;
        }
        .option-row .radio-group {
            display: inline-block;
        }
        .add-btn {
            background: none;
            border: none;
            color: #333;
            cursor: pointer;
            font-weight: bold;
            padding: 5px;
            margin-top: 10px;
        }
        .submit-btn {
            display: inline-block;
            padding: 10px 20px;
            background-color: #d0d0d0;
            color: #333;
            text-decoration: none;
            font-weight: bold;
            border: none;
            cursor: pointer;
        }
    </style>
    <script>
        function addQuestion() {
            var questionsContainer = document.getElementById('questions-container');
            var questionCount = document.querySelectorAll('.question-block').length + 1;
            
            var newQuestion = document.createElement('div');
            newQuestion.className = 'question-block';
            newQuestion.innerHTML = `
                <p>${questionCount}. (btw ini index aj kok, bukan nomor soal nginget ada fitur suffle)</p>
                <div class="form-row">
                    <label for="question-${questionCount}">question :</label>
                    <input type="text" id="question-${questionCount}" name="question-${questionCount}" required>
                </div>
                <div class="options-container-${questionCount}">
                    <div class="option-row">
                        <label>option :</label>
                        <input type="text" name="option-${questionCount}-1" required>
                        <div class="radio-group">
                            <input type="radio" name="correct-${questionCount}" value="1" id="right-${questionCount}-1" checked>
                            <label for="right-${questionCount}-1">right</label>
                            <input type="radio" name="correct-${questionCount}" value="0" id="wrong-${questionCount}-1">
                            <label for="wrong-${questionCount}-1">wrong</label>
                        </div>
                    </div>
                    <div class="option-row">
                        <label>option :</label>
                        <input type="text" name="option-${questionCount}-2" required>
                        <div class="radio-group">
                            <input type="radio" name="correct-${questionCount}" value="2" id="right-${questionCount}-2">
                            <label for="right-${questionCount}-2">right</label>
                            <input type="radio" name="correct-${questionCount}" value="0" id="wrong-${questionCount}-2" checked>
                            <label for="wrong-${questionCount}-2">wrong</label>
                        </div>
                    </div>
                </div>
                <button type="button" class="add-btn" onclick="addOption(${questionCount});">(+)add option</button>
            `;
            
            questionsContainer.appendChild(newQuestion);
        }
        
        function addOption(questionNum) {
            var optionsContainer = document.querySelector('.options-container-' + questionNum);
            var optionCount = optionsContainer.querySelectorAll('.option-row').length + 1;
            
            var newOption = document.createElement('div');
            newOption.className = 'option-row';
            newOption.innerHTML = `
                <label>option :</label>
                <input type="text" name="option-${questionNum}-${optionCount}" required>
                <div class="radio-group">
                    <input type="radio" name="correct-${questionNum}" value="${optionCount}" id="right-${questionNum}-${optionCount}">
                    <label for="right-${questionNum}-${optionCount}">right</label>
                    <input type="radio" name="correct-${questionNum}" value="0" id="wrong-${questionNum}-${optionCount}" checked>
                    <label for="wrong-${questionNum}-${optionCount}">wrong</label>
                </div>
            `;
            
            optionsContainer.appendChild(newOption);
        }
    </script>
</head>
<body>
    <%
        // Check if user is logged in and is an admin
        String username = (String) session.getAttribute("username");
        Boolean isTeacher = (Boolean) session.getAttribute("is_teacher");
        
        if (username == null || isTeacher == null || !isTeacher) {
            response.sendRedirect("Login.jsp");
            return;
        }
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        // Handle form submission
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            try {
                // Database connection
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/quiz_db", "root", "");
                
                // Get form data
                String packageName = request.getParameter("package_name");
                String duration = request.getParameter("duration");
                int subjectId = Integer.parseInt(request.getParameter("subject_id"));
                Integer userId = (Integer) session.getAttribute("user_id");
                
                // Count the number of questions
                int questionCount = 0;
                Enumeration<String> paramNames = request.getParameterNames();
                while (paramNames.hasMoreElements()) {
                    String paramName = paramNames.nextElement();
                    if (paramName.startsWith("question-")) {
                        questionCount++;
                    }
                }
                
                // Begin transaction
                conn.setAutoCommit(false);
                
                // Process each question
                for (int i = 1; i <= questionCount; i++) {
                    String questionText = request.getParameter("question-" + i);
                    String correctAnswerIndex = request.getParameter("correct-" + i);
                    
                    // Skip if question is empty
                    if (questionText == null || questionText.trim().isEmpty()) {
                        continue;
                    }
                    
                    // Insert question
                    pstmt = conn.prepareStatement(
                        "INSERT INTO questions (subject_id, question_text, correct_answer, created_by) VALUES (?, ?, ?, ?)",
                        Statement.RETURN_GENERATED_KEYS
                    );
                    pstmt.setInt(1, subjectId);
                    pstmt.setString(2, questionText);
                    
                    // Find the correct option text
                    String correctOptionText = "";
                    int correctIndex = Integer.parseInt(correctAnswerIndex);
                    correctOptionText = request.getParameter("option-" + i + "-" + correctIndex);
                    
                    pstmt.setString(3, correctOptionText);
                    pstmt.setInt(4, userId);
                    pstmt.executeUpdate();
                    
                    // Get generated question_id
                    rs = pstmt.getGeneratedKeys();
                    int questionId = 0;
                    if (rs.next()) {
                        questionId = rs.getInt(1);
                    }
                    rs.close();
                    pstmt.close();
                    
                    // Count the number of options for this question
                    int optionCount = 0;
                    paramNames = request.getParameterNames();
                    while (paramNames.hasMoreElements()) {
                        String paramName = paramNames.nextElement();
                        if (paramName.startsWith("option-" + i + "-")) {
                            optionCount++;
                        }
                    }
                    
                    // Insert options
                    for (int j = 1; j <= optionCount; j++) {
                        String optionText = request.getParameter("option-" + i + "-" + j);
                        boolean isCorrect = (correctIndex == j);
                        
                        // Skip if option is empty
                        if (optionText == null || optionText.trim().isEmpty()) {
                            continue;
                        }
                        
                        pstmt = conn.prepareStatement(
                            "INSERT INTO quiz (question_id, option_text, is_correct) VALUES (?, ?, ?)"
                        );
                        pstmt.setInt(1, questionId);
                        pstmt.setString(2, optionText);
                        pstmt.setBoolean(3, isCorrect);
                        pstmt.executeUpdate();
                        pstmt.close();
                    }
                }
                
                // Commit transaction
                conn.commit();
                conn.setAutoCommit(true);
                
                // Redirect to success page or show success message
                %><script>alert('Quiz package created successfully!'); window.location='AdminPage.jsp';</script><%
                
            } catch (Exception e) {
                // Rollback in case of error
                if (conn != null) {
                    try {
                        conn.rollback();
                        conn.setAutoCommit(true);
                    } catch (SQLException ex) {
                        ex.printStackTrace();
                    }
                }
                out.println("<div class='error'>Error: " + e.getMessage() + "</div>");
                e.printStackTrace();
            } finally {
                try { if (rs != null) rs.close(); } catch (Exception e) { }
                try { if (pstmt != null) pstmt.close(); } catch (Exception e) { }
                try { if (conn != null) conn.close(); } catch (Exception e) { }
            }
        }
    %>
    
    <div class="container">
        <div class="header">
            <div class="logo">QUIZZEAH!✍(ᴗ‿ᴗ)</div>
            <div class="logout">
                <a href="Logout.jsp">logout</a>
            </div>
        </div>
        
        <div class="content">
            <div class="welcome">hello admin!</div>
            <div>add new question?</div>
            
            <form action="AdminPage.jsp" method="post">
                <div class="admin-form">
                    <div class="form-row">
                        <label for="package_name">name package</label>
                        <input type="text" id="package_name" name="package_name" required>
                    </div>
                    <div class="form-row">
                        <label for="duration">duration</label>
                        <input type="text" id="duration" name="duration" required>
                    </div>
                    <div class="form-row">
                        <label for="subject_id">subject</label>
                        <select id="subject_id" name="subject_id" required>
                            <%
                                try {
                                    // Database connection
                                    Class.forName("com.mysql.jdbc.Driver");
                                    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/quiz_db", "root", "");
                                    
                                    // Get subjects
                                    pstmt = conn.prepareStatement("SELECT subject_id, subject_name FROM subjects ORDER BY subject_name");
                                    rs = pstmt.executeQuery();
                                    
                                    while (rs.next()) {
                                        int subjectId = rs.getInt("subject_id");
                                        String subjectName = rs.getString("subject_name");
                                        %><option value="<%= subjectId %>"><%= subjectName %></option><%
                                    }
                                } catch (Exception e) {
                                    out.println("<option value=''>Error loading subjects</option>");
                                    e.printStackTrace();
                                } finally {
                                    try { if (rs != null) rs.close(); } catch (Exception e) { }
                                    try { if (pstmt != null) pstmt.close(); } catch (Exception e) { }
                                    try { if (conn != null) conn.close(); } catch (Exception e) { }
                                }
                            %>
                        </select>
                    </div>
                    
                    <div id="questions-container">
                        <div class="question-block">
                            <p>Enter Your Question here : </p>
                            <div class="form-row">
                                <label for="question-1">question :</label>
                                <input type="text" id="question-1" name="question-1" required>
                            </div>
                            <div class="options-container-1">
                                <div class="option-row">
                                    <label>option :</label>
                                    <input type="text" name="option-1-1" required>
                                    <div class="radio-group">
                                        <input type="radio" name="correct-1" value="1" id="right-1-1" checked>
                                        <label for="right-1-1">right</label>
                                        <input type="radio" name="correct-1" value="0" id="wrong-1-1">
                                        <label for="wrong-1-1">wrong</label>
                                    </div>
                                </div>
                                <div class="option-row">
                                    <label>option :</label>
                                    <input type="text" name="option-1-2" required>
                                    <div class="radio-group">
                                        <input type="radio" name="correct-1" value="2" id="right-1-2">
                                        <label for="right-1-2">right</label>
                                        <input type="radio" name="correct-1" value="0" id="wrong-1-2" checked>
                                        <label for="wrong-1-2">wrong</label>
                                    </div>
                                </div>
                            </div>
                            <button type="button" class="add-btn" onclick="addOption(1);">(+)add option</button>
                        </div>
                    </div>
                    
                    <button type="button" class="add-btn" onclick="addQuestion();">(+) add question</button>
                </div>
                
                <button type="submit" class="submit-btn">submit</button>
            </form>
        </div>
    </div>
</body>
</html>