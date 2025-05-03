CREATE DATABASE quiz_db;
USE quiz_db;

-- Master tables
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    is_teacher BOOLEAN DEFAULT FALSE 
);

CREATE TABLE subjects (
    subject_id INT AUTO_INCREMENT PRIMARY KEY,
    subject_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE questions (
    question_id INT AUTO_INCREMENT PRIMARY KEY,
    subject_id INT NOT NULL,
    question_text TEXT NOT NULL,
    correct_answer VARCHAR(255) NOT NULL,
    created_by INT NOT NULL, 
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id),
    FOREIGN KEY (created_by) REFERENCES users(user_id)
);

-- Transaction tables
CREATE TABLE quiz (
    quiz_id INT AUTO_INCREMENT PRIMARY KEY,
    question_id INT NOT NULL,
    option_text VARCHAR(255) NOT NULL,
    is_correct BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (question_id) REFERENCES questions(question_id) ON DELETE CASCADE
);

CREATE TABLE quiz_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE scores (
    score_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    history_id INT NOT NULL,
    total_score INT DEFAULT 0,
    date_taken TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    subject_id INT,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (history_id) REFERENCES quiz_history(history_id),
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
);

CREATE TABLE quiz_answers (
    answer_id INT AUTO_INCREMENT PRIMARY KEY,
    history_id INT NOT NULL,
    question_id INT NOT NULL,
    selected_option_id INT NOT NULL,
    is_correct BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (history_id) REFERENCES quiz_history(history_id),
    FOREIGN KEY (question_id) REFERENCES questions(question_id),
    FOREIGN KEY (selected_option_id) REFERENCES quiz(quiz_id)
);

-- Chart data table 
CREATE TABLE chart_data (
    chart_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    subject_id INT,
    data_type VARCHAR(50) NOT NULL,
    data_value FLOAT NOT NULL,
    data_label VARCHAR(100),
    data_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
);

-- Data dummy
-- Insert sample users (including a teacher)
INSERT INTO users (username, password, is_teacher) VALUES ('admin', 'admin123', TRUE);
INSERT INTO users (username, password, is_teacher) VALUES ('teacher1', 'teacher123', TRUE);
INSERT INTO users (username, password, is_teacher) VALUES ('student1', 'student123', FALSE);

-- Insert subjects
INSERT INTO subjects (subject_name, description) VALUES ('Mathematics', 'All math related questions');
INSERT INTO subjects (subject_name, description) VALUES ('Science', 'Science-related topics including Physics, Chemistry, and Biology');
INSERT INTO subjects (subject_name, description) VALUES ('History', 'Historical events and figures');

-- Insert questions
INSERT INTO questions (subject_id, question_text, correct_answer, created_by) 
VALUES (1, 'What is 2 + 2?', '4', 1);
INSERT INTO questions (subject_id, question_text, correct_answer, created_by) 
VALUES (1, 'What is the square root of 16?', '4', 1);
INSERT INTO questions (subject_id, question_text, correct_answer, created_by) 
VALUES (2, 'What is the chemical symbol for water?', 'H2O', 2);

-- Insert  quiz options
-- Options for question 1
INSERT INTO quiz (question_id, option_text, is_correct) VALUES (1, '2', FALSE);
INSERT INTO quiz (question_id, option_text, is_correct) VALUES (1, '3', FALSE);
INSERT INTO quiz (question_id, option_text, is_correct) VALUES (1, '4', TRUE);
INSERT INTO quiz (question_id, option_text, is_correct) VALUES (1, '5', FALSE);

-- Options for question 2
INSERT INTO quiz (question_id, option_text, is_correct) VALUES (2, '2', FALSE);
INSERT INTO quiz (question_id, option_text, is_correct) VALUES (2, '4', TRUE);
INSERT INTO quiz (question_id, option_text, is_correct) VALUES (2, '8', FALSE);
INSERT INTO quiz (question_id, option_text, is_correct) VALUES (2, '16', FALSE);

-- Options for question 3
INSERT INTO quiz (question_id, option_text, is_correct) VALUES (3, 'H2O', TRUE);
INSERT INTO quiz (question_id, option_text, is_correct) VALUES (3, 'CO2', FALSE);
INSERT INTO quiz (question_id, option_text, is_correct) VALUES (3, 'NaCl', FALSE);
INSERT INTO quiz (question_id, option_text, is_correct) VALUES (3, 'O2', FALSE);

-- Create quiz history
INSERT INTO quiz_history (user_id) VALUES (3);

-- Create scores
INSERT INTO scores (user_id, history_id, total_score, subject_id) 
VALUES (3, 1, 2, 1);

-- Insert  quiz answers
INSERT INTO quiz_answers (history_id, question_id, selected_option_id, is_correct) 
VALUES (1, 1, 3, TRUE);
INSERT INTO quiz_answers (history_id, question_id, selected_option_id, is_correct) 
VALUES (1, 2, 6, TRUE);

-- Insert  chart data
INSERT INTO chart_data (user_id, subject_id, data_type, data_value, data_label) 
VALUES (3, 1, 'performance', 80.0, 'Mathematics Performance');
INSERT INTO chart_data (user_id, subject_id, data_type, data_value, data_label) 
VALUES (3, 2, 'performance', 70.0, 'Science Performance');