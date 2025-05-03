package quiz.servlet;

import quiz.dao.*;
import quiz.model.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/QuizServlet")
public class QuizServlet extends HttpServlet {
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
        
        if (action == null) {
            // Show subject selection
            SubjectDAO subjectDAO = new SubjectDAO();
            List<Subject> subjects = subjectDAO.getAllSubjects();
            request.setAttribute("subjects", subjects);
            request.getRequestDispatcher("Quiz.jsp").forward(request, response);
        } else if (action.equals("start")) {
            // Start a new quiz
            int subjectId = Integer.parseInt(request.getParameter("subjectId"));
            int numQuestions = Integer.parseInt(request.getParameter("numQuestions"));
            
            QuestionDAO questionDAO = new QuestionDAO();
            List<Question> questions = questionDAO.getRandomQuestions(subjectId, numQuestions);
            
            if (questions.isEmpty()) {
                request.setAttribute("errorMessage", "No questions available for this subject");
                response.sendRedirect("Quiz.jsp");
                return;
            }
            
            // Create a new quiz history
            QuizHistory history = new QuizHistory();
            history.setUserId(user.getUserId());
            
            QuizHistoryDAO historyDAO = new QuizHistoryDAO();
            boolean success = historyDAO.createQuizHistory(history);
            
            if (success) {
                session.setAttribute("quizHistory", history);
                session.setAttribute("questions", questions);
                session.setAttribute("currentQuestionIndex", 0);
                session.setAttribute("selectedAnswers", new ArrayList<QuizAnswer>());
                
                response.sendRedirect("QuizQuestion.jsp");
            } else {
                request.setAttribute("errorMessage", "Failed to start quiz");
                response.sendRedirect("Quiz.jsp");
            }
        }
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            response.sendRedirect("Login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        
        if (action != null && action.equals("submitAnswer")) {
            // Get quiz session data
            QuizHistory history = (QuizHistory) session.getAttribute("quizHistory");
            List<Question> questions = (List<Question>) session.getAttribute("questions");
            int currentIndex = (int) session.getAttribute("currentQuestionIndex");
            List<QuizAnswer> selectedAnswers = (List<QuizAnswer>) session.getAttribute("selectedAnswers");
            
            // Get current question and selected answer
            Question currentQuestion = questions.get(currentIndex);
            int selectedOptionId = Integer.parseInt(request.getParameter("optionId"));
            
            // Check if answer is correct
            boolean isCorrect = false;
            for (QuizOption option : currentQuestion.getOptions()) {
                if (option.getQuizId() == selectedOptionId && option.isCorrect()) {
                    isCorrect = true;
                    break;
                }
            }
            
            // Create and save answer
            QuizAnswer answer = new QuizAnswer();
            answer.setHistoryId(history.getHistoryId());
            answer.setQuestionId(currentQuestion.getQuestionId());
            answer.setSelectedOptionId(selectedOptionId);
            answer.setCorrect(isCorrect);
            
            QuizHistoryDAO historyDAO = new QuizHistoryDAO();
            historyDAO.addQuizAnswer(answer);
            
            // Add to session
            selectedAnswers.add(answer);
            session.setAttribute("selectedAnswers", selectedAnswers);
            
            // Move to next question or end quiz
            currentIndex++;
            session.setAttribute("currentQuestionIndex", currentIndex);
            
            if (currentIndex < questions.size()) {
                response.sendRedirect("QuizQuestion.jsp");
            } else {
                // End quiz
                historyDAO.endQuizHistory(history.getHistoryId());
                
                // Calculate score
                int correctCount = 0;
                for (QuizAnswer ans : selectedAnswers) {
                    if (ans.isCorrect()) {
                        correctCount++;
                    }
                }
                
                // Save score
                Score score = new Score();
                score.setUserId(user.getUserId());
                score.setHistoryId(history.getHistoryId());
                score.setTotalScore(correctCount);
                if (!questions.isEmpty()) {
                    score.setSubjectId(questions.get(0).getSubjectId());
                }
                
                ScoreDAO scoreDAO = new ScoreDAO();
                scoreDAO.createScore(score);
                
                // Update chart data
                ChartDataDAO chartDataDAO = new ChartDataDAO();
                chartDataDAO.generatePerformanceData(user.getUserId());
                
                // Redirect to result page
                response.sendRedirect("QuizResult.jsp");
            }
        }
    }
}