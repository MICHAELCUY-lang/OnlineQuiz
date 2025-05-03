package quiz.servlet;

import quiz.dao.ScoreDAO;
import quiz.dao.SubjectDAO;
import quiz.model.Score;
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

@WebServlet("/ScoreServlet")
public class ScoreServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            response.sendRedirect("Login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        
        if (action == null || action.equals("list")) {
            // Show all scores for user
            ScoreDAO scoreDAO = new ScoreDAO();
            List<Score> scores = scoreDAO.getScoresByUser(user.getUserId());
            
            // Get subject names
            SubjectDAO subjectDAO = new SubjectDAO();
            for (Score score : scores) {
                if (score.getSubjectId() != null) {
                    Subject subject = subjectDAO.getSubjectById(score.getSubjectId());
                    if (subject != null) {
                        request.setAttribute("subject_" + score.getScoreId(), subject.getSubjectName());
                    }
                }
            }
            
            request.setAttribute("scores", scores);
            request.getRequestDispatcher("Score.jsp").forward(request, response);
        } else if (action.equals("chart")) {
            // Get chart data
            ScoreDAO scoreDAO = new ScoreDAO();
            Map<String, Double> subjectScores = scoreDAO.getUserScoresBySubject(user.getUserId());
            
            request.setAttribute("subjectScores", subjectScores);
            request.getRequestDispatcher("ScoreChart.jsp").forward(request, response);
        } else if (action.equals("detail")) {
            // Show score details
            int scoreId = Integer.parseInt(request.getParameter("scoreId"));
            
            ScoreDAO scoreDAO = new ScoreDAO();
            Score score = scoreDAO.getScoreById(scoreId);
            
            if (score != null && score.getUserId() == user.getUserId()) {
                request.setAttribute("score", score);
                
                // Get subject name
                if (score.getSubjectId() != null) {
                    SubjectDAO subjectDAO = new SubjectDAO();
                    Subject subject = subjectDAO.getSubjectById(score.getSubjectId());
                    if (subject != null) {
                        request.setAttribute("subjectName", subject.getSubjectName());
                    }
                }
                
                request.getRequestDispatcher("ScoreDetail.jsp").forward(request, response);
            } else {
                response.sendRedirect("ScoreServlet");
            }
        }
    }
}