<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, quiz.model.*, quiz.dao.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Edit Question - Online Quiz</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
    <script>
        function addOption() {
            const optionsContainer = document.getElementById('optionsContainer');
            const optionCount = optionsContainer.children.length;
            
            const optionDiv = document.createElement('div');
            optionDiv.className = 'form-group';
            
            const radioLabel = document.createElement('label');
            radioLabel.innerHTML = `
                <input type="radio" name="correctOption" value="${optionCount}">
                Option ${optionCount + 1}:
            `;
            
            const input = document.createElement('input');
            input.type = 'text';
            input.name = 'optionText';
            input.required = true;
            
            optionDiv.appendChild(radioLabel);
            optionDiv.appendChild(input);
            
            optionsContainer.appendChild(optionDiv);
        }
    </script>
</head>
<body>
    <%
        // Check if user is logged in and is a teacher
        User user = (User) session.getAttribute("user");
        if (user == null || !user.isTeacher()) {
            response.sendRedirect("Login.jsp");
            return;
        }
        
        // Get question and subjects
        Question question = (Question) request.getAttribute("question");
        List<Subject> subjects = (List<Subject>) request.getAttribute("subjects");
        
        if (question == null) {
            response.sendRedirect("AdminServlet?action=listQuestions");
            return;
        }
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
        <h1>Edit Question</h1>
        
        <% if(request.getAttribute("errorMessage") != null) { %>
            <div class="alert alert-danger">
                <%= request.getAttribute("errorMessage") %>
            </div>
        <% } %>
        
        <div class="card">
            <div class="card-header">Question Details</div>
            <div class="card-body">
                <form action="AdminServlet" method="post">
                    <input type="hidden" name="action" value="updateQuestion">
                    <input type="hidden" name="questionId" value="<%= question.getQuestionId() %>">
                    
                    <div class="form-group">
                        <label for="subjectId">Subject:</label>
                        <select id="subjectId" name="subjectId" required>
                            <% for (Subject subject : subjects) { %>
                                <option value="<%= subject.getSubjectId() %>" <%= subject.getSubjectId() == question.getSubjectId() ? "selected" : "" %>>
                                    <%= subject.getSubjectName() %>
                                </option>
                            <% } %>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="questionText">Question:</label>
                        <textarea id="questionText" name="questionText" required><%= question.getQuestionText() %></textarea>
                    </div>
                    
                    <div class="form-group">
                        <label>Options (Select the correct answer):</label>
                        <div id="optionsContainer">
                            <% 
                                List<QuizOption> options = question.getOptions();
                                for (int i = 0; i < options.size(); i++) {
                                    QuizOption option = options.get(i);
                            %>
                            <div class="form-group">
                                <label>
                                    <input type="radio" name="correctOption" value="<%= i %>" <%= option.isCorrect() ? "checked" : "" %>>
                                    Option <%= i + 1 %>:
                                </label>
                                <input type="text" name="optionText" value="<%= option.getOptionText() %>" required>
                            </div>
                            <% } %>
                        </div>
                        
                        <button type="button" class="btn" onclick="addOption()">Add Option</button>
                    </div>
                    
                    <div class="form-group">
                        <button type="submit" class="btn btn-primary">Update Question</button>
                        <a href="AdminServlet?action=listQuestions" class="btn">Cancel</a>
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