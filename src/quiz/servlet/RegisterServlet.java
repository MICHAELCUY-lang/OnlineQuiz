package quiz.servlet;

import quiz.dao.UserDAO;
import quiz.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String role = request.getParameter("role");
        
        UserDAO userDAO = new UserDAO();
        
        // Check if username already exists
        if (userDAO.usernameExists(username)) {
            request.setAttribute("errorMessage", "Username already exists");
            request.getRequestDispatcher("Register.jsp").forward(request, response);
            return;
        }
        
        // Check if passwords match
        if (!password.equals(confirmPassword)) {
            request.setAttribute("errorMessage", "Passwords do not match");
            request.getRequestDispatcher("Register.jsp").forward(request, response);
            return;
        }
        
        // Create new user
        User user = new User();
        user.setUsername(username);
        user.setPassword(password);
        user.setTeacher("teacher".equals(role));
        
        boolean success = userDAO.registerUser(user);
        
        if (success) {
            request.setAttribute("successMessage", "Registration successful. Please login.");
            request.getRequestDispatcher("Login.jsp").forward(request, response);
        } else {
            request.setAttribute("errorMessage", "Registration failed");
            request.getRequestDispatcher("Register.jsp").forward(request, response);
        }
    }
}