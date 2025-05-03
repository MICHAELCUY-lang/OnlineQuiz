<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, quiz.model.*, quiz.dao.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Add Question - Online Quiz</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
    <script>
        function addOption() {
            const optionsContainer = document.getElementById('optionsContainer');
            const optionCount = optionsContainer.children.length;
            
            const optionDiv = document.createElement('div');
            optionDiv.className = 'form-group';
            
            const radioLabel = document.createElement('label');
            radioLabel.innerHTML = `
                <input type="radio" name="correctOption" value="${optionCount}" ${optionCount === 0 ? 'checked' : ''}>
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
        
        // Get subjects
        List<Subject> subjects = (List<Subject>) request.getAttribute("subjects");
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
        <h1>Add New Question</h1>
        
        <% if(request.getAttribute("errorMessage") != null) { %>
            <div class="alert alert-danger">
                <%= request.getAttribute("errorMessage") %>
            </div>
        <% } %>
        
        <div class="card">
            <div class="card-header">Question Details</div>
            <div class="card-body">
                <form action="AdminServlet" method="post">
                    <input type="hidden" name="action" value="addQuestion">
                    
                    <div class="form-group">
                        <label for="subjectId">Subject:</label>
                        <select id="subjectId" name="subjectId" required>
                            <% for (Subject subject : subjects) { %>
                                <option value="<%= subject.getSubjectId() %>"><%= subject.getSubjectName() %></option>
                            <% } %>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="questionText">Question:</label>
                        <textarea id="questionText" name="questionText" required></textarea>
                    </div>
                    
                    <div class="form-group">
                        <label>Options (Select the correct answer):</label>
                        <div id="optionsContainer">
                            <!-- Initial options will be added by JavaScript -->
                        </div>
                        
                        <button type="button" class="btn" onclick="addOption()">Add Option</button>
                    </div>
                    
                    <div class="form-group">
                        <button type="submit" class="btn btn-primary">Save Question</button>
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
    
    <script>
        // Add initial options when page loads
        document.addEventListener('DOMContentLoaded', function() {
            // Add 4 options by default
            for (let i = 0; i < 4; i++) {
                addOption();
            }
        });
    </script>
</body>
</html> 