// ScoreServlet.java
package quiz.servlet;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import quiz.dao.ScoreDAO;
import quiz.model.Score;
import quiz.model.User;

@WebServlet("/scores")
public class ScoreServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        ScoreDAO scoreDAO = new ScoreDAO();
        List<Score> scores = scoreDAO.getScoresByUser(user.getUserId());
        
        request.setAttribute("scores", scores);
        
        // Get chart data
        List<Object[]> chartData = scoreDAO.getChartData(user.getUserId());
        request.setAttribute("chartData", chartData);
        
        request.getRequestDispatcher("score.jsp").forward(request, response);
    }
}