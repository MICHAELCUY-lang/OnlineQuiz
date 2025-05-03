<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>JDBC Driver Test</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            padding: 0;
        }
        .success {
            color: green;
            background-color: #e8f5e9;
            padding: 10px;
            border-radius: 5px;
            margin: 10px 0;
        }
        .error {
            color: red;
            background-color: #ffebee;
            padding: 10px;
            border-radius: 5px;
            margin: 10px 0;
        }
        .info {
            background-color: #e3f2fd;
            padding: 10px;
            border-radius: 5px;
            margin: 10px 0;
        }
    </style>
</head>
<body>
    <h1>JDBC Driver Test</h1>
    
    <div class="info">
        <h3>System Information:</h3>
        <p>Java Version: <%= System.getProperty("java.version") %></p>
        <p>Java Class Path: <%= System.getProperty("java.class.path") %></p>
        <p>Servlet Container: <%= application.getServerInfo() %></p>
    </div>
    
    <h3>Testing Driver Loading:</h3>
    <%
    try {
        // Try newer driver
        out.println("<p>Attempting to load com.mysql.cj.jdbc.Driver...</p>");
        Class.forName("com.mysql.cj.jdbc.Driver");
        out.println("<div class='success'>Successfully loaded com.mysql.cj.jdbc.Driver!</div>");
    } catch (ClassNotFoundException e) {
        out.println("<div class='error'>Failed to load com.mysql.cj.jdbc.Driver: " + e.getMessage() + "</div>");
        
        try {
            // Try older driver name
            out.println("<p>Attempting to load com.mysql.jdbc.Driver...</p>");
            Class.forName("com.mysql.jdbc.Driver");
            out.println("<div class='success'>Successfully loaded com.mysql.jdbc.Driver!</div>");
        } catch (ClassNotFoundException e2) {
            out.println("<div class='error'>Failed to load com.mysql.jdbc.Driver: " + e2.getMessage() + "</div>");
        }
    }
    %>
    
    <h3>Testing Connection:</h3>
    <%
    Connection conn = null;
    try {
        String url = "jdbc:mysql://localhost:3306/quiz_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
        String user = "root";
        String password = "";
        
        out.println("<p>Attempting to connect to database with URL: " + url + "</p>");
        
        conn = DriverManager.getConnection(url, user, password);
        out.println("<div class='success'>Successfully connected to the database!</div>");
        
        // Try a simple query
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery("SELECT 1");
        if (rs.next()) {
            out.println("<div class='success'>Successfully executed a test query!</div>");
        }
        rs.close();
        stmt.close();
    } catch (Exception e) {
        out.println("<div class='error'>Database connection failed: " + e.getMessage() + "</div>");
        e.printStackTrace(new java.io.PrintWriter(out));
    } finally {
        try { if (conn != null) conn.close(); } catch (Exception e) { }
    }
    %>
    
    <h3>Available Driver Information:</h3>
    <%
    try {
        out.println("<ul>");
        java.util.Enumeration<Driver> drivers = DriverManager.getDrivers();
        boolean hasDrivers = false;
        
        while (drivers.hasMoreElements()) {
            hasDrivers = true;
            Driver driver = drivers.nextElement();
            out.println("<li>Driver: " + driver.getClass().getName() + " (version " + driver.getMajorVersion() + "." + driver.getMinorVersion() + ")</li>");
        }
        
        if (!hasDrivers) {
            out.println("<li>No JDBC drivers found</li>");
        }
        out.println("</ul>");
    } catch (Exception e) {
        out.println("<div class='error'>Error listing drivers: " + e.getMessage() + "</div>");
    }
    %>
</body>
</html> 