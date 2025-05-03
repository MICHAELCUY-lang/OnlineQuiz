<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, quiz.model.*, quiz.dao.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Subject Management - Online Quiz</title>
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
        <h1>Subject Management</h1>
        
        <div class="action-buttons">
            <a href="AdminServlet?action=addSubject" class="btn btn-primary">Add New Subject</a>
        </div>
        
        <div class="card">
            <div class="card-header">All Subjects</div>
            <div class="card-body">
                <% if (subjects.isEmpty()) { %>
                    <p>No subjects available.</p>
                <% } else { %>
                    <table class="table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Subject Name</th>
                                <th>Description</th>
                                <th>Question Count</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% 
                                QuestionDAO questionDAO = new QuestionDAO();
                                for (Subject subject : subjects) {
                                    List<Question> questions = questionDAO.getQuestionsBySubject(subject.getSubjectId());
                            %>
                            <tr>
                                <td><%= subject.getSubjectId() %></td>
                                <td><%= subject.getSubjectName() %></td>
                                <td><%= subject.getDescription() %></td>
                                <td><%= questions.size() %></td>
                                <td>
                                    <a href="AdminServlet?action=editSubject&subjectId=<%= subject.getSubjectId() %>" class="btn">Edit</a>
                                    <a href="#" onclick="if(confirm('Are you sure you want to delete this subject? All related questions will also be deleted.')) { window.location='AdminServlet?action=deleteSubject&subjectId=<%= subject.getSubjectId() %>'; }" class="btn btn-danger">Delete</a>
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