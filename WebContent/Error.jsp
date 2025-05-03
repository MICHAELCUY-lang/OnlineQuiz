<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>QUIZZEAH! - Error</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f5f5f5;
            color: #333;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }
        .error-container {
            background-color: white;
            border-radius: 10px;
            padding: 30px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            text-align: center;
            max-width: 500px;
        }
        .logo {
            font-size: 28px;
            font-weight: bold;
            color: #2c3e50;
            margin-bottom: 20px;
        }
        .logo span {
            color: #e74c3c;
        }
        .error-title {
            font-size: 24px;
            color: #e74c3c;
            margin-bottom: 15px;
        }
        .error-message {
            color: #7f8c8d;
            margin-bottom: 30px;
            line-height: 1.5;
        }
        .btn {
            display: inline-block;
            padding: 10px 25px;
            border-radius: 5px;
            text-decoration: none;
            font-weight: bold;