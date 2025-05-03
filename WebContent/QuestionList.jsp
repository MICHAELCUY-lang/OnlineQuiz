<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, quiz.model.*, quiz.dao.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Question Management - Online Quiz</title>
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
        
        // Get questions
        List<Question> questions = (List<Question>) request.getAttribute("questions");
        List<Subject> subjects = (List<Subject>) request.getAttribute("subjects");
        
        // Create a map of subject IDs to subject names
        Map<Integer, String> subjectMap = new HashMap<>();
        for (Subject subject : subjects) {
            subjectMap.put(subject.getSubjectId(), subject.getSubjectName());
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
        <h1>Question Management</h1>
        
        <div class="action-buttons">
            <a href="AdminServlet?action=addQuestion" class="btn btn-primary">Add New Question</a>
        </div>
        
        <div class="card">
            <div class="card-header">All Questions</div>
            <div class="card-body">
                <% if (questions.isEmpty()) { %>
                    <p>No questions available.</p>
                <% } else { %>
                    <table class="table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Subject</th>
                                <th>Question</th>
                                <th>Correct Answer</th>
                                <th>Created By</th>
                                <th>Created Date</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Question question : questions) { %>
                            <tr>
                                <td><%= question.getQuestionId() %></td>
                                <td><%= subjectMap.getOrDefault(question.getSubjectId(), "N/A") %></td>
                                <td><%= question.getQuestionText() %></td>
                                <td><%= question.getCorrectAnswer() %></td>
                                <td>
                                    <% 
                                        UserDAO userDAO = new UserDAO();
                                        User creator = userDAO.getUserById(question.getCreatedBy());
                                        if (creator != null) {
                                            out.print(creator.getUsername());
                                        } else {
                                            out.print("Unknown");
                                        }
                                    %>
                                </td>
                                <td><%= question.getCreatedDate() %></td>
                                <td>
                                    <a href="AdminServlet?action=editQuestion&questionId=<%= question.getQuestionId() %>" class="btn">Edit</a>
                                    <a href="#" onclick="if(confirm('Are you sure you want to delete this question?')) { window.location='AdminServlet?action=deleteQuestion&questionId=<%= question.getQuestionId() %>'; }" class="btn btn-danger">Delete</a>
                                </td>
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