// RegisterServlet.java
package quiz.servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import quiz.dao.UserDAO;
import quiz.model.User;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String role = request.getParameter("role");
        
        // Validate inputs
        if (username == null || username.trim().isEmpty() || 
            password == null || password.trim().isEmpty() ||
            confirmPassword == null || !password.equals(confirmPassword)) {
            
            request.setAttribute("errorMessage", "Invalid registration data");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }
        
        User user = new User();
        user.setUsername(username);
        user.setPassword(password);
        user.setTeacher("teacher".equals(role));
        
        UserDAO userDAO = new UserDAO();
        boolean success = userDAO.registerUser(user);
        
        if (success) {
            request.setAttribute("successMessage", "Registration successful. Please login.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        } else {
            request.setAttribute("errorMessage", "Registration failed. Username may already exist.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
        }
    }
}
