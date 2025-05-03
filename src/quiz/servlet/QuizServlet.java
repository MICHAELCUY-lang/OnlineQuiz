// QuizServlet.java
package quiz.servlet;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import quiz.dao.QuestionDAO;
import quiz.dao.QuizDAO;
import quiz.dao.ScoreDAO;
import quiz.model.Question;
import quiz.model.QuizOption;
import quiz.model.Score;
import quiz.model.User;

@WebServlet("/quiz")
public class QuizServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        // Get subject ID from request
        int subjectId = 0;
        try {
            subjectId = Integer.parseInt(request.getParameter("subjectId"));
        } catch (NumberFormatException e) {
            // If no subject specified, use default (1 - Mathematics)
            subjectId = 1;
        }
        
        // Get questions for the selected subject
        QuestionDAO questionDAO = new QuestionDAO();
        List<Question> questions = questionDAO.getQuestionsBySubject(subjectId);
        
        // Shuffle questions for randomization
        Collections.shuffle(questions);
        
        // Limit to 10 questions or less if not enough available
        int questionsCount = Math.min(10, questions.size());
        List<Question> quizQuestions = questions.subList(0, questionsCount);
        
        // Get options for each question
        QuizDAO quizDAO = new QuizDAO();
        for (Question question : quizQuestions) {
            List<QuizOption> options = quizDAO.getOptionsForQuestion(question.getQuestionId());
            // Store options in session with question ID as key
            session.setAttribute("options_" + question.getQuestionId(), options);
        }
        
        // Create quiz history
        int historyId = quizDAO.createQuizHistory(user.getUserId());
        session.setAttribute("historyId", historyId);
        session.setAttribute("subjectId", subjectId);
        
        // Store questions in session
        session.setAttribute("quizQuestions", quizQuestions);
        session.setAttribute("currentQuestionIndex", 0);
        
        // Forward to quiz page
        response.sendRedirect("quiz.jsp");
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        // Get current question index and history ID
        int currentQuestionIndex = (int) session.getAttribute("currentQuestionIndex");
        int historyId = (int) session.getAttribute("historyId");
        int subjectId = (int) session.getAttribute("subjectId");
        
        // Get quiz questions
        @SuppressWarnings("unchecked")
        List<Question> quizQuestions = (List<Question>) session.getAttribute("quizQuestions");
        
        // Get selected answer
        String selectedOption = request.getParameter("selectedOption");
        int selectedOptionId = Integer.parseInt(selectedOption);
        
        // Get current question
        Question currentQuestion = quizQuestions.get(currentQuestionIndex);
        
        // Check if answer is correct
        QuizDAO quizDAO = new QuizDAO();
        @SuppressWarnings("unchecked")
        List<QuizOption> options = (List<QuizOption>) session.getAttribute("options_" + currentQuestion.getQuestionId());
        
        boolean isCorrect = false;
        for (QuizOption option : options) {
            if (option.getQuizId() == selectedOptionId && option.isCorrect()) {
                isCorrect = true;
                break;
            }
        }
        
        // Record answer
        quizDAO.recordQuizAnswer(historyId, currentQuestion.getQuestionId(), selectedOptionId, isCorrect);
        
        // Update score
        Integer totalScore = (Integer) session.getAttribute("totalScore");
        if (totalScore == null) {
            totalScore = 0;
        }
        
        if (isCorrect) {
            totalScore++;
        }
        session.setAttribute("totalScore", totalScore);
        
        // Move to next question or finish quiz
        currentQuestionIndex++;
        session.setAttribute("currentQuestionIndex", currentQuestionIndex);
        
        if (currentQuestionIndex < quizQuestions.size()) {
            // Continue to next question
            response.sendRedirect("quiz.jsp");
        } else {
            // Finish quiz
            quizDAO.completeQuizHistory(historyId);
            
            // Record final score
            Score score = new Score();
            score.setUserId(user.getUserId());
            score.setHistoryId(historyId);
            score.setTotalScore(totalScore);
            score.setSubjectId(subjectId);
            
            ScoreDAO scoreDAO = new ScoreDAO();
            scoreDAO.recordScore(score);
            
            // Add chart data
            float percentageScore = (float) totalScore / quizQuestions.size() * 100;
            String subjectName = quizQuestions.get(0).getSubjectName();
            scoreDAO.addChartData(user.getUserId(), subjectId, "performance", percentageScore, 
                                  subjectName + " Performance");
            
            // Clear session attributes no longer needed
            session.removeAttribute("quizQuestions");
            session.removeAttribute("currentQuestionIndex");
            session.removeAttribute("totalScore");
            
            // Redirect to result page
            response.sendRedirect("result.jsp?score=" + totalScore + "&total=" + quizQuestions.size());
        }
    }
}