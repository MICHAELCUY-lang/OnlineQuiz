// DashboardServlet.java
package quiz.servlet;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import quiz.dao.QuestionDAO;
import quiz.dao.ScoreDAO;
import quiz.model.Question;
import quiz.model.Score;
import quiz.model.User;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        // Get recent scores for the user
        ScoreDAO scoreDAO = new ScoreDAO();
        List<Score> recentScores = scoreDAO.getScoresByUser(user.getUserId());
        request.setAttribute("recentScores", recentScores);
        
        // If teacher, get all questions
        if (user.isTeacher()) {
            QuestionDAO questionDAO = new QuestionDAO();
            List<Question> allQuestions = questionDAO.getAllQuestions();
            request.setAttribute("allQuestions", allQuestions);
        }
        
        // Get chart data
        List<Object[]> chartData = scoreDAO.getChartData(user.getUserId());
        request.setAttribute("chartData", chartData);
        
        // Forward to dashboard
        request.getRequestDispatcher("dashboard.jsp").forward(request, response);
    }
}