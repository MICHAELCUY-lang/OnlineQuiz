<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>QUIZZEAH! - Login</title>
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
            max-width: 400px;
            margin: 100px auto;
            background-color: #fff;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            padding: 20px;
        }
        .header {
            background-color: #e0e0e0;
            padding: 15px 20px;
            text-align: center;
            margin: -20px -20px 20px;
        }
        .logo {
            font-size: 24px;
            font-weight: bold;
        }
        .form-group {
            margin-bottom: 15px;
        }
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        .form-group input {
            width: 100%;
            padding: 8px;
            box-sizing: border-box;
            border: 1px solid #ccc;
        }
        .btn {
            display: inline-block;
            padding: 10px 20px;
            background-color: #e0e0e0;
            color: #333;
            text-decoration: none;
            font-weight: bold;
            border: none;
            cursor: pointer;
            width: 100%;
            box-sizing: border-box;
            margin-top: 10px;
        }
        .register-link {
            text-align: center;
            margin-top: 15px;
        }
        .error-message {
            color: red;
            margin-bottom: 15px;
        }
    </style>
</head>
<body>
    <%
        // Process login form
        String errorMessage = "";
        
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            
            // Define hardcoded admin credentials
            final String ADMIN_USERNAME = "admin";
            final String ADMIN_PASSWORD = "admin123";
            final String TEACHER_USERNAME = "teacher1";
            final String TEACHER_PASSWORD = "teacher123";
            
            // Check if admin login
            if ((ADMIN_USERNAME.equals(username) && ADMIN_PASSWORD.equals(password)) || 
                (TEACHER_USERNAME.equals(username) && TEACHER_PASSWORD.equals(password))) {
                // Admin login successful
                session.setAttribute("user_id", 1); // Set a default admin ID
                session.setAttribute("username", username);
                session.setAttribute("is_teacher", true);
                
                // Redirect to admin page
                response.sendRedirect("AdminPage.jsp");
                return;
            }
            
            // If not admin, check regular user credentials in database
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            
            try {
                // Database connection
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/quiz_db", "root", "");
                
                // Validate login
                pstmt = conn.prepareStatement("SELECT user_id, is_teacher FROM users WHERE username = ? AND password = ?");
                pstmt.setString(1, username);
                pstmt.setString(2, password);
                rs = pstmt.executeQuery();
                
                if (rs.next()) {
                    // Regular user login successful
                    int userId = rs.getInt("user_id");
                    boolean isTeacher = rs.getBoolean("is_teacher");
                    
                    // Set session attributes
                    session.setAttribute("user_id", userId);
                    session.setAttribute("username", username);
                    session.setAttribute("is_teacher", isTeacher);
                    
                    // Redirect regular users to Dashboard
                    response.sendRedirect("Dashboard.jsp");
                } else {
                    // Login failed
                    errorMessage = "Invalid username or password";
                }
            } catch (Exception e) {
                errorMessage = "Error: " + e.getMessage();
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
        </div>
        
        <% if (!errorMessage.isEmpty()) { %>
            <div class="error-message"><%= errorMessage %></div>
        <% } %>
        
        <form action="Login.jsp" method="post">
            <div class="form-group">
                <label for="username">Username:</label>
                <input type="text" id="username" name="username" required>
            </div>
            <div class="form-group">
                <label for="password">Password:</label>
                <input type="password" id="password" name="password" required>
            </div>
            <button type="submit" class="btn">Login</button>
        </form>
        
        <div class="register-link">
            Don't have an account? <a href="Register.jsp">Register</a>
        </div>
    </div>
</body>
</html>