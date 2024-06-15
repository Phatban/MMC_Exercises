-- Active: 1716975660421@@127.0.0.1@3306@testing_system_db
USE Testing_System_Db;

-- Question 1: Tạo trigger không cho phép người dùng nhập vào Group có ngày tạo trước 1 năm trước
DROP TRIGGER IF EXISTS trig_check_group_createdate;
DELIMITER $$
CREATE TRIGGER IF NOT EXISTS trig_check_group_createdate
BEFORE INSERT ON `Group`
FOR EACH ROW
BEGIN
    DECLARE v_OneYearAgo DATETIME;
    SET v_OneYearAgo = DATE_SUB(NOW(), INTERVAL 1 YEAR);
    
    IF NEW.CreateDate < v_OneYearAgo THEN
        SIGNAL SQLSTATE '12345'
            SET MESSAGE_TEXT = 'Cannot add Group with CreateDate older than 1 year';
    END IF;    
END$$
DELIMITER ;

-- Question 2: Không cho phép người dùng thêm user vào department "Sale"
DROP TRIGGER IF EXISTS trig_cannot_add_user_to_sale_dept;
DELIMITER $$
CREATE TRIGGER IF NOT EXISTS trig_cannot_add_user_to_sale_dept
BEFORE INSERT ON `Account`
FOR EACH ROW
BEGIN
    DECLARE v_DeptID TINYINT;
    SELECT DepartmentID INTO v_DeptID 
    FROM Department
    WHERE DepartmentName = 'Sale';
    
    IF NEW.DepartmentID = v_DeptID THEN
        SIGNAL SQLSTATE '12345'
            SET MESSAGE_TEXT = 'Department "Sale" cannot add more user';
    END IF;
END$$
DELIMITER ;

-- Question 3: Cấu hình 1 group có nhiều nhất là 5 user
DROP TRIGGER IF EXISTS trig_group_max_5_users;
DELIMITER $$  
CREATE TRIGGER IF NOT EXISTS trig_group_max_5_users
BEFORE INSERT ON `GroupAccount`
FOR EACH ROW
BEGIN
    DECLARE v_UserCount TINYINT;
    SELECT COUNT(*) INTO v_UserCount 
    FROM `GroupAccount`
    WHERE GroupID = NEW.GroupID;
    
    IF v_UserCount >= 5 THEN
        SIGNAL SQLSTATE '12345'
            SET MESSAGE_TEXT = 'A Group cannot have more than 5 users';
    END IF;
END$$
DELIMITER ;

-- Question 4: Cấu hình 1 bài thi có nhiều nhất là 10 Question
DROP TRIGGER IF EXISTS trig_exam_max_10_questions;
DELIMITER $$
CREATE TRIGGER IF NOT EXISTS trig_exam_max_10_questions
BEFORE INSERT ON `ExamQuestion`
FOR EACH ROW
BEGIN
    DECLARE v_QuestionCount TINYINT;
    SELECT COUNT(*) INTO v_QuestionCount
    FROM `ExamQuestion`
    WHERE ExamID = NEW.ExamID;
    
    IF v_QuestionCount >= 10 THEN
        SIGNAL SQLSTATE '12345'
            SET MESSAGE_TEXT = 'An Exam cannot have more than 10 questions';
    END IF;
END$$
DELIMITER ;

-- Question 5: Không cho phép xóa tài khoản admin@gmail.com
DROP TRIGGER IF EXISTS trig_cannot_delete_admin;
DELIMITER $$
CREATE TRIGGER IF NOT EXISTS trig_cannot_delete_admin
BEFORE DELETE ON `Account`
FOR EACH ROW
BEGIN
    DECLARE v_AdminEmail VARCHAR(50);
    SET v_AdminEmail = 'admin@gmail.com';
    
    IF OLD.Email = v_AdminEmail THEN
        SIGNAL SQLSTATE '12345'
            SET MESSAGE_TEXT = 'Cannot delete admin account';
    END IF;
END$$
DELIMITER ;

-- Question 6: Nếu không điền DepartmentID khi tạo Account thì sẽ vào phòng "Waiting Department"  
DROP TRIGGER IF EXISTS trig_default_waiting_dept;
DELIMITER $$
CREATE TRIGGER IF NOT EXISTS trig_default_waiting_dept
BEFORE INSERT ON `Account`
FOR EACH ROW
BEGIN
    DECLARE v_WaitingDeptID TINYINT;
    SELECT DepartmentID INTO v_WaitingDeptID 
    FROM Department
    WHERE DepartmentName = 'Waiting Department';
    
    IF NEW.DepartmentID IS NULL THEN
        SET NEW.DepartmentID = v_WaitingDeptID;
    END IF;
END$$
DELIMITER ;

-- Question 7: 1 Question chỉ có tối đa 4 Answers, trong đó có tối đa 2 đáp án đúng
DROP TRIGGER IF EXISTS trig_question_max_4_answers;
DELIMITER $$
CREATE TRIGGER IF NOT EXISTS trig_question_max_4_answers
BEFORE INSERT ON `Answer`
FOR EACH ROW
BEGIN
    DECLARE v_AnswerCount TINYINT;
    DECLARE v_CorrectAnswerCount TINYINT;
    
    SELECT COUNT(*) INTO v_AnswerCount 
    FROM `Answer`
    WHERE QuestionID = NEW.QuestionID;
    
    SELECT COUNT(*) INTO v_CorrectAnswerCount
    FROM `Answer` 
    WHERE QuestionID = NEW.QuestionID AND isCorrect = 1;
    
    IF v_AnswerCount >= 4 OR (NEW.isCorrect = 1 AND v_CorrectAnswerCount >= 2) THEN
        SIGNAL SQLSTATE '12345'
            SET MESSAGE_TEXT = 'A question cannot have more than 4 answers or 2 correct answers';
    END IF;
END$$
DELIMITER ;

-- Question 8: Chuẩn hóa lại Gender khi nhập vào Account
DROP TRIGGER IF EXISTS trig_format_user_gender;
DELIMITER $$
CREATE TRIGGER IF NOT EXISTS trig_format_user_gender
BEFORE INSERT ON `Account`
FOR EACH ROW
BEGIN
    IF NEW.Gender = 'Nam' THEN
        SET NEW.Gender = 'M';
    ELSEIF NEW.Gender = 'Nữ' THEN
        SET NEW.Gender = 'F';
    ELSE 
        SET NEW.Gender = 'U';
    END IF;
END$$
DELIMITER ;

-- Question 9: Không cho phép xóa Exam được tạo trong vòng 2 ngày
DROP TRIGGER IF EXISTS trig_cannot_delete_new_exam;  
DELIMITER $$
CREATE TRIGGER IF NOT EXISTS trig_cannot_delete_new_exam
BEFORE DELETE ON `Exam`
FOR EACH ROW
BEGIN
    DECLARE v_CreateDate DATETIME;
    SET v_CreateDate = DATE_SUB(NOW(), INTERVAL 2 DAY);
    
    IF OLD.CreateDate > v_CreateDate THEN
        SIGNAL SQLSTATE '12345' 
            SET MESSAGE_TEXT = 'Cannot delete exams created in the last 2 days';
    END IF; 
END$$
DELIMITER ;

-- Question 10: Question chỉ được update/delete khi chưa nằm trong Exam 
DROP TRIGGER IF EXISTS trig_update_question_not_in_exam;
DELIMITER $$
CREATE TRIGGER IF NOT EXISTS trig_update_question_not_in_exam
BEFORE UPDATE ON `Question` 
FOR EACH ROW
BEGIN
    DECLARE v_ExamQuestionCount TINYINT;
    
    SELECT COUNT(*) INTO v_ExamQuestionCount
    FROM `ExamQuestion`
    WHERE QuestionID = NEW.QuestionID;
    
    IF v_ExamQuestionCount > 0 THEN
        SIGNAL SQLSTATE '12345'
            SET MESSAGE_TEXT = 'Cannot update a question that is in an exam';
    END IF;
END$$
DELIMITER ;

-- Question 12: Lấy ra các Exam và Format lại Duration
SELECT 
    ExamID,
    `Code`,
    Title,
    CategoryID,
    CASE
        WHEN Duration <= 30 THEN 'Short time'
        WHEN Duration <= 60 THEN 'Medium time' 
        ELSE 'Long time'
    END AS Duration,
    CreatorID,
    CreateDate
FROM `Exam`;

-- Question 13: Thống kê số lượng Account trong mỗi Group
SELECT 
    g.GroupID,
    g.GroupName,
    COUNT(ga.AccountID) AS SL_User,
    CASE
        WHEN COUNT(ga.AccountID) <= 5 THEN 'few'
        WHEN COUNT(ga.AccountID) <= 20 THEN 'normal'
        ELSE 'higher'
    END AS the_number_user_amount   
FROM `Group` g 
LEFT JOIN `GroupAccount` ga ON g.GroupID = ga.GroupID
GROUP BY g.GroupID, g.GroupName;

-- Question 14: Thống kê số Account trong mỗi Department
SELECT 
    d.DepartmentID,
    d.DepartmentName,
    CASE
        WHEN COUNT(a.AccountID) = 0 THEN 'Không có User'
        ELSE COUNT(a.AccountID)
    END AS SL_User
FROM Department d
LEFT JOIN `Account` a ON d.DepartmentID = a.DepartmentID  
GROUP BY d.DepartmentID, d.DepartmentName;