<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>QUIZZEAH! - Register</title>
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
        .checkbox-group {
            margin-bottom: 15px;
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
        .login-link {
            text-align: center;
            margin-top: 15px;
        }
        .error-message {
            color: red;
            margin-bottom: 15px;
        }
        .success-message {
            color: green;
            margin-bottom: 15px;
        }
    </style>
</head>
<body>
    <%
        // Process registration form
        String errorMessage = "";
        String successMessage = "";
        
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            String confirmPassword = request.getParameter("confirm_password");
            // Users can only register as regular students
            boolean isTeacher = false;
            
            // Validate input
            if (!password.equals(confirmPassword)) {
                errorMessage = "Passwords do not match";
            } else {
                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet rs = null;
                
                try {
                    // Database connection
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/quiz_db", "root", "");
                    
                    // Check if username already exists
                    pstmt = conn.prepareStatement("SELECT user_id FROM users WHERE username = ?");
                    pstmt.setString(1, username);
                    rs = pstmt.executeQuery();
                    
                    if (rs.next()) {
                        errorMessage = "Username already exists";
                    } else {
                        // Register new user
                        pstmt = conn.prepareStatement("INSERT INTO users (username, password, is_teacher) VALUES (?, ?, ?)");
                        pstmt.setString(1, username);
                        pstmt.setString(2, password);
                        pstmt.setBoolean(3, isTeacher);
                        
                        int result = pstmt.executeUpdate();
                        if (result > 0) {
                            successMessage = "Registration successful! You can now login.";
                        } else {
                            errorMessage = "Registration failed";
                        }
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
        }
    %>
    
    <div class="container">
        <div class="header">
            <div class="logo">QUIZZEAH!✍(ᴗ‿ᴗ)</div>
        </div>
        
        <% if (!errorMessage.isEmpty()) { %>
            <div class="error-message"><%= errorMessage %></div>
        <% } %>
        
        <% if (!successMessage.isEmpty()) { %>
            <div class="success-message"><%= successMessage %></div>
        <% } %>
        
        <form action="Register.jsp" method="post">
            <div class="form-group">
                <label for="username">Username:</label>
                <input type="text" id="username" name="username" required>
            </div>
            <div class="form-group">
                <label for="password">Password:</label>
                <input type="password" id="password" name="password" required>
            </div>
            <div class="form-group">
                <label for="confirm_password">Confirm Password:</label>
                <input type="password" id="confirm_password" name="confirm_password" required>
            </div>
            <!-- Admin registration removed - only predefined admins in database can login -->
            <button type="submit" class="btn">Register</button>
        </form>
        
        <div class="login-link">
            Already have an account? <a href="Login.jsp">Login</a>
        </div>
    </div>
</body>
</html>