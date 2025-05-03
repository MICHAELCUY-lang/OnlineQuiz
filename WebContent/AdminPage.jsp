<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, quiz.model.*, quiz.dao.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Admin Dashboard - Online Quiz</title>
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
        
        // Get stats
        QuestionDAO questionDAO = new QuestionDAO();
        List<Question> questions = questionDAO.getAllQuestions();
        
        SubjectDAO subjectDAO = new SubjectDAO();
        List<Subject> subjects = subjectDAO.getAllSubjects();
        
        UserDAO userDAO = new UserDAO();
        List<User> users = userDAO.getAllUsers();
        int studentCount = 0;
        for (User u : users) {
            if (!u.isTeacher()) {
                studentCount++;
            }
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
        <h1>Admin Dashboard</h1>
        
        <div class="dashboard-stats">
            <div class="stat-card">
                <div class="stat-value"><%= questions.size() %></div>
                <div class="stat-label">Total Questions</div>
                <a href="AdminServlet?action=listQuestions" class="btn btn-primary">Manage Questions</a>
            </div>
            
            <div class="stat-card">
                <div class="stat-value"><%= subjects.size() %></div>
                <div class="stat-label">Total Subjects</div>
                <a href="AdminServlet?action=listSubjects" class="btn btn-primary">Manage Subjects</a>
            </div>
            
            <div class="stat-card">
                <div class="stat-value"><%= studentCount %></div>
                <div class="stat-label">Total Students</div>
                <a href="AdminServlet?action=listUsers" class="btn btn-primary">Manage Users</a>
            </div>
        </div>
        
        <div class="card">
            <div class="card-header">Quick Actions</div>
            <div class="card-body">
                <div class="action-buttons">
                    <a href="AdminServlet?action=addQuestion" class="btn btn-primary">Add New Question</a>
                    <a href="AdminServlet?action=addSubject" class="btn btn-primary">Add New Subject</a>
                </div>
            </div>
        </div>
        
        <div class="card">
            <div class="card-header">Recent Questions</div>
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
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% 
                                // Show only the 5 most recent questions
                                int count = 0;
                                for (int i = questions.size() - 1; i >= 0 && count < 5; i--) {
                                    Question question = questions.get(i);
                                    Subject subject = subjectDAO.getSubjectById(question.getSubjectId());
                                    count++;
                            %>
                            <tr>
                                <td><%= question.getQuestionId() %></td>
                                <td><%= subject != null ? subject.getSubjectName() : "N/A" %></td>
                                <td><%= question.getQuestionText() %></td>
                                <td>
                                    <a href="AdminServlet?action=editQuestion&questionId=<%= question.getQuestionId() %>" class="btn">Edit</a>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                    <a href="AdminServlet?action=listQuestions" class="btn">View All Questions</a>
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