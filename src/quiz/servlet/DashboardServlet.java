package quiz.servlet;

import quiz.dao.ChartDataDAO;
import quiz.dao.ScoreDAO;
import quiz.dao.SubjectDAO;
import quiz.model.ChartData;
import quiz.model.Subject;
import quiz.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/DashboardServlet")
public class DashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            response.sendRedirect("Login.jsp");
            return;
        }
        
        // Get subjects for the quiz selector
        SubjectDAO subjectDAO = new SubjectDAO();
        List<Subject> subjects = subjectDAO.getAllSubjects();
        request.setAttribute("subjects", subjects);
        
        // Get performance data for charts
        ChartDataDAO chartDataDAO = new ChartDataDAO();
        List<ChartData> performanceData = chartDataDAO.getChartDataByUser(user.getUserId());
        request.setAttribute("performanceData", performanceData);
        
        // Get average scores by subject for comparison
        ScoreDAO scoreDAO = new ScoreDAO();
        Map<String, Double> subjectScores = scoreDAO.getUserScoresBySubject(user.getUserId());
        request.setAttribute("subjectScores", subjectScores);
        
        // Forward to dashboard page
        request.getRequestDispatcher("Dashboard.jsp").forward(request, response);
    }
}