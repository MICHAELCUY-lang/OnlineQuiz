package quiz.servlet;

import quiz.dao.QuestionDAO;
import quiz.dao.SubjectDAO;
import quiz.dao.UserDAO;
import quiz.model.Question;
import quiz.model.QuizOption;
import quiz.model.Subject;
import quiz.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/AdminServlet")
public class AdminServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null || !user.isTeacher()) {
            response.sendRedirect("Login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        
        if (action == null) {
            // Show admin dashboard
            request.getRequestDispatcher("AdminPage.jsp").forward(request, response);
        } else if (action.equals("listQuestions")) {
            // Show all questions
            QuestionDAO questionDAO = new QuestionDAO();
            List<Question> questions = questionDAO.getAllQuestions();
            request.setAttribute("questions", questions);
            
            // Get subject names
            SubjectDAO subjectDAO = new SubjectDAO();
            List<Subject> subjects = subjectDAO.getAllSubjects();
            request.setAttribute("subjects", subjects);
            
            request.getRequestDispatcher("QuestionList.jsp").forward(request, response);
        } else if (action.equals("addQuestion")) {
            // Show add question form
            SubjectDAO subjectDAO = new SubjectDAO();
            List<Subject> subjects = subjectDAO.getAllSubjects();
            request.setAttribute("subjects", subjects);
            
            request.getRequestDispatcher("AddQuestion.jsp").forward(request, response);
        } else if (action.equals("editQuestion")) {
            // Show edit question form
            int questionId = Integer.parseInt(request.getParameter("questionId"));
            
            QuestionDAO questionDAO = new QuestionDAO();
            Question question = questionDAO.getQuestionById(questionId);
            request.setAttribute("question", question);
            
            SubjectDAO subjectDAO = new SubjectDAO();
            List<Subject> subjects = subjectDAO.getAllSubjects();
            request.setAttribute("subjects", subjects);
            
            request.getRequestDispatcher("EditQuestion.jsp").forward(request, response);
        } else if (action.equals("listSubjects")) {
            // Show all subjects
            SubjectDAO subjectDAO = new SubjectDAO();
            List<Subject> subjects = subjectDAO.getAllSubjects();
            request.setAttribute("subjects", subjects);
            
            request.getRequestDispatcher("SubjectList.jsp").forward(request, response);
        } else if (action.equals("addSubject")) {
            // Show add subject form
            request.getRequestDispatcher("AddSubject.jsp").forward(request, response);
        } else if (action.equals("editSubject")) {
            // Show edit subject form
            int subjectId = Integer.parseInt(request.getParameter("subjectId"));
            
            SubjectDAO subjectDAO = new SubjectDAO();
            Subject subject = subjectDAO.getSubjectById(subjectId);
            request.setAttribute("subject", subject);
            
            request.getRequestDispatcher("EditSubject.jsp").forward(request, response);
        } else if (action.equals("listUsers")) {
            // Show all users
            UserDAO userDAO = new UserDAO();
            List<User> users = userDAO.getAllUsers();
            request.setAttribute("users", users);
            
            request.getRequestDispatcher("UserList.jsp").forward(request, response);
        }
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null || !user.isTeacher()) {
            response.sendRedirect("Login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        
        if (action.equals("addQuestion")) {
            // Add new question
            int subjectId = Integer.parseInt(request.getParameter("subjectId"));
            String questionText = request.getParameter("questionText");
            
            // Create question object
            Question question = new Question();
            question.setSubjectId(subjectId);
            question.setQuestionText(questionText);
            question.setCreatedBy(user.getUserId());
            
            // Create options
            List<QuizOption> options = new ArrayList<>();
            String[] optionTexts = request.getParameterValues("optionText");
            String correctOption = request.getParameter("correctOption");
            
            if (optionTexts != null) {
                for (int i = 0; i < optionTexts.length; i++) {
                    QuizOption option = new QuizOption();
                    option.setOptionText(optionTexts[i]);
                    option.setCorrect(String.valueOf(i).equals(correctOption));
                    options.add(option);
                    
                    // Set correct answer in question
                    if (option.isCorrect()) {
                        question.setCorrectAnswer(option.getOptionText());
                    }
                }
            }
            
            // Save question and options
            QuestionDAO questionDAO = new QuestionDAO();
            boolean success = questionDAO.addQuestion(question, options);
            
            if (success) {
                response.sendRedirect("AdminServlet?action=listQuestions");
            } else {
                request.setAttribute("errorMessage", "Failed to add question");
                request.getRequestDispatcher("AddQuestion.jsp").forward(request, response);
            }
        } else if (action.equals("updateQuestion")) {
            // Update existing question
            int questionId = Integer.parseInt(request.getParameter("questionId"));
            int subjectId = Integer.parseInt(request.getParameter("subjectId"));
            String questionText = request.getParameter("questionText");
            
            // Create question object
            Question question = new Question();
            question.setQuestionId(questionId);
            question.setSubjectId(subjectId);
            question.setQuestionText(questionText);
            
            // Create options
            List<QuizOption> options = new ArrayList<>();
            String[] optionTexts = request.getParameterValues("optionText");
            String correctOption = request.getParameter("correctOption");
            
            if (optionTexts != null) {
                for (int i = 0; i < optionTexts.length; i++) {
                    QuizOption option = new QuizOption();
                    option.setQuestionId(questionId);
                    option.setOptionText(optionTexts[i]);
                    option.setCorrect(String.valueOf(i).equals(correctOption));
                    options.add(option);
                    
                    // Set correct answer in question
                    if (option.isCorrect()) {
                        question.setCorrectAnswer(option.getOptionText());
                    }
                }
            }
            
            // Update question and options
            QuestionDAO questionDAO = new QuestionDAO();
            boolean success = questionDAO.updateQuestion(question, options);
            
            if (success) {
                response.sendRedirect("AdminServlet?action=listQuestions");
            } else {
                request.setAttribute("errorMessage", "Failed to update question");
                request.getRequestDispatcher("EditQuestion.jsp").forward(request, response);
            }
        } else if (action.equals("deleteQuestion")) {
            // Delete question
            int questionId = Integer.parseInt(request.getParameter("questionId"));
            
            QuestionDAO questionDAO = new QuestionDAO();
            boolean success = questionDAO.deleteQuestion(questionId);
            
            response.sendRedirect("AdminServlet?action=listQuestions");
        } else if (action.equals("addSubject")) {
            // Add new subject
            String subjectName = request.getParameter("subjectName");
            String description = request.getParameter("description");
            
            Subject subject = new Subject();
            subject.setSubjectName(subjectName);
            subject.setDescription(description);
            
            SubjectDAO subjectDAO = new SubjectDAO();
            boolean success = subjectDAO.addSubject(subject);
            
            if (success) {
                response.sendRedirect("AdminServlet?action=listSubjects");
            } else {
                request.setAttribute("errorMessage", "Failed to add subject");
                request.getRequestDispatcher("AddSubject.jsp").forward(request, response);
            }
        } else if (action.equals("updateSubject")) {
            // Update existing subject
            int subjectId = Integer.parseInt(request.getParameter("subjectId"));
            String subjectName = request.getParameter("subjectName");
            String description = request.getParameter("description");
            
            Subject subject = new Subject();
            subject.setSubjectId(subjectId);
            subject.setSubjectName(subjectName);
            subject.setDescription(description);
            
            SubjectDAO subjectDAO = new SubjectDAO();
            boolean success = subjectDAO.updateSubject(subject);
            
            if (success) {
                response.sendRedirect("AdminServlet?action=listSubjects");
            } else {
                request.setAttribute("errorMessage", "Failed to update subject");
                request.getRequestDispatcher("EditSubject.jsp").forward(request, response);
            }
        } else if (action.equals("deleteSubject")) {
            // Delete subject
            int subjectId = Integer.parseInt(request.getParameter("subjectId"));
            
            SubjectDAO subjectDAO = new SubjectDAO();
            boolean success = subjectDAO.deleteSubject(subjectId);
            
            response.sendRedirect("AdminServlet?action=listSubjects");
        }
    }
}