-- Active: 1716975660421@@127.0.0.1@3306@testing_system_db
USE Testing_System_Db;

-- Question 1: Tạo store để người dùng nhập vào tên phòng ban và in ra tất cả các account thuộc phòng ban đó
DELIMITER //
CREATE PROCEDURE sp_get_accounts_by_department(IN p_department_name VARCHAR(50))
BEGIN
    SELECT a.*
    FROM `Account` a
    JOIN Department d ON a.DepartmentID = d.DepartmentID
    WHERE d.DepartmentName = p_department_name;
END //
DELIMITER ;

-- Question 2: Tạo store để in ra số lượng account trong mỗi group
DELIMITER //
CREATE PROCEDURE sp_get_account_count_by_group()
BEGIN
    SELECT g.GroupID, g.GroupName, COUNT(ga.AccountID) AS AccountCount
    FROM `Group` g
    LEFT JOIN GroupAccount ga ON g.GroupID = ga.GroupID
    GROUP BY g.GroupID, g.GroupName;
END //
DELIMITER ;

-- Question 3: Tạo store để thống kê mỗi type question có bao nhiêu question được tạo trong tháng hiện tại
DELIMITER //
CREATE PROCEDURE sp_get_question_count_by_type_current_month()
BEGIN
    SELECT tq.TypeName, COUNT(q.QuestionID) AS QuestionCount
    FROM TypeQuestion tq
    LEFT JOIN Question q ON tq.TypeID = q.TypeID
    WHERE MONTH(q.CreateDate) = MONTH(CURDATE()) AND YEAR(q.CreateDate) = YEAR(CURDATE())
    GROUP BY tq.TypeName;
END //
DELIMITER ;

-- Question 4: Tạo store để trả ra id của type question có nhiều câu hỏi nhất
DELIMITER //
CREATE PROCEDURE sp_get_type_with_most_questions(OUT p_type_id INT)
BEGIN
    SELECT q.TypeID INTO p_type_id
    FROM Question q
    GROUP BY q.TypeID
    ORDER BY COUNT(q.QuestionID) DESC
    LIMIT 1;
END //
DELIMITER ;

-- Question 5: Sử dụng store ở question 4 để tìm ra tên của type question
DELIMITER //
CREATE PROCEDURE sp_get_type_name_with_most_questions(OUT p_type_name VARCHAR(50))
BEGIN
    DECLARE v_type_id INT;
    CALL sp_get_type_with_most_questions(v_type_id);
    
    SELECT TypeName INTO p_type_name
    FROM TypeQuestion
    WHERE TypeID = v_type_id;
END //
DELIMITER ;

-- Question 6: Viết 1 store cho phép người dùng nhập vào 1 chuỗi và trả về group có tên chứa chuỗi của người dùng nhập vào hoặc trả về user có username chứa chuỗi của người dùng nhập vào
DELIMITER //
CREATE PROCEDURE sp_search_group_or_user(IN p_search_string VARCHAR(50))
BEGIN
    SELECT g.GroupName
    FROM `Group` g
    WHERE g.GroupName LIKE CONCAT('%', p_search_string, '%')
    UNION
    SELECT a.Username
    FROM `Account` a
    WHERE a.Username LIKE CONCAT('%', p_search_string, '%');
END //
DELIMITER ;

-- Question 7: Viết 1 store cho phép người dùng nhập vào thông tin fullName, email và trong store sẽ tự động gán:
-- 		username sẽ giống email nhưng bỏ phần @..mail đi
-- 		positionID: sẽ có default là developer
-- 		departmentID: sẽ được cho vào 1 phòng chờ
-- Sau đó in ra kết quả tạo thành công
DELIMITER //
CREATE PROCEDURE sp_create_account(IN p_fullname VARCHAR(50), IN p_email VARCHAR(50))
BEGIN
    DECLARE v_username VARCHAR(50);
    DECLARE v_position_id INT;
    DECLARE v_department_id INT;
    
    SET v_username = SUBSTRING_INDEX(p_email, '@', 1);
    SELECT PositionID INTO v_position_id FROM Position WHERE PositionName = 'Developer';
    SELECT DepartmentID INTO v_department_id FROM Department WHERE DepartmentName = 'Phòng chờ';
    
    INSERT INTO `Account` (Email, Username, FullName, DepartmentID, PositionID, CreateDate)
    VALUES (p_email, v_username, p_fullname, v_department_id, v_position_id, NOW());
    
    SELECT 'Tạo tài khoản thành công' AS Message;
END //
DELIMITER ;

-- Question 8: Viết 1 store cho phép người dùng nhập vào Essay hoặc Multiple-Choice để thống kê câu hỏi essay hoặc
-- multiple-choice nào có content dài nhất
DELIMITER //
CREATE PROCEDURE sp_get_longest_content_question(IN p_question_type VARCHAR(20))
BEGIN
    IF p_question_type = 'Essay' THEN
        SELECT *
        FROM Question
        WHERE TypeID = (SELECT TypeID FROM TypeQuestion WHERE TypeName = 'Essay')
        ORDER BY LENGTH(Content) DESC
        LIMIT 1;
    ELSEIF p_question_type = 'Multiple-Choice' THEN
        SELECT *
        FROM Question
        WHERE TypeID = (SELECT TypeID FROM TypeQuestion WHERE TypeName = 'Multiple-Choice')
        ORDER BY LENGTH(Content) DESC
        LIMIT 1;
    ELSE
        SELECT 'Loại câu hỏi không hợp lệ' AS Message;
    END IF;
END //
DELIMITER ;

-- Question 9: Viết 1 store cho phép người dùng xóa exam dựa vào ID
DELIMITER //
CREATE PROCEDURE sp_delete_exam_by_id(IN p_exam_id INT)
BEGIN
    DELETE FROM ExamQuestion WHERE ExamID = p_exam_id;
    DELETE FROM Exam WHERE ExamID = p_exam_id;
END //
DELIMITER ;

-- Question 10: Tìm ra các exam được tạo từ 3 năm trước và xóa các exam đó đi (sử dụng store ở câu 9 để xóa). Sau đó in số lượng record đã remove từ các table liên quan trong khi removing
DELIMITER //
CREATE PROCEDURE sp_delete_exams_older_than_3_years()
BEGIN
    DECLARE v_exam_count INT;
    DECLARE v_exam_question_count INT;
    
    SELECT COUNT(*) INTO v_exam_count
    FROM Exam
    WHERE CreateDate < DATE_SUB(CURDATE(), INTERVAL 3 YEAR);
    
    SELECT COUNT(*) INTO v_exam_question_count
    FROM ExamQuestion
    WHERE ExamID IN (
        SELECT ExamID
        FROM Exam
        WHERE CreateDate < DATE_SUB(CURDATE(), INTERVAL 3 YEAR)
    );
    
    SET SQL_SAFE_UPDATES = 0;
    
    CALL sp_delete_exam_by_id(
        (SELECT ExamID
        FROM Exam
        WHERE CreateDate < DATE_SUB(CURDATE(), INTERVAL 3 YEAR))
    );
    
    SET SQL_SAFE_UPDATES = 1;
    
    SELECT CONCAT('Đã xóa ', v_exam_count, ' bản ghi từ bảng Exam và ', v_exam_question_count, ' bản ghi từ bảng ExamQuestion') AS Message;
END //
DELIMITER ;

-- Question 11: Viết store cho phép người dùng xóa phòng ban bằng cách người dùng nhập vào tên phòng ban và các account thuộc phòng ban đó sẽ được chuyển về phòng ban default là phòng ban chờ việc
DELIMITER //
CREATE PROCEDURE sp_delete_department_by_name(IN p_department_name VARCHAR(50))
BEGIN
    DECLARE v_default_department_id INT;
    
    SELECT DepartmentID INTO v_default_department_id
    FROM Department
    WHERE DepartmentName = 'Phòng chờ việc';
    
    UPDATE `Account`
    SET DepartmentID = v_default_department_id
    WHERE DepartmentID = (
        SELECT DepartmentID
        FROM Department
        WHERE DepartmentName = p_department_name
    );
    
    DELETE FROM Department
    WHERE DepartmentName = p_department_name;
END //
DELIMITER ;

-- Question 12: Viết store để in ra mỗi tháng có bao nhiêu câu hỏi được tạo trong năm nay
DELIMITER //
CREATE PROCEDURE sp_get_question_count_by_month_current_year()
BEGIN
    SELECT 
        MONTH(CreateDate) AS Month,
        COUNT(*) AS QuestionCount
    FROM Question
    WHERE YEAR(CreateDate) = YEAR(CURDATE())
    GROUP BY MONTH(CreateDate);
END //
DELIMITER ;

-- Question 13: Viết store để in ra mỗi tháng có bao nhiêu câu hỏi được tạo trong 6 tháng gần đây nhất (Nếu tháng nào không có thì sẽ in ra là "không có câu hỏi nào trong tháng")
DELIMITER //
CREATE PROCEDURE sp_get_question_count_last_6_months()
BEGIN
    DECLARE v_month INT;
    DECLARE v_year INT;
    DECLARE v_count INT;
    
    SET v_month = MONTH(CURDATE());
    SET v_year = YEAR(CURDATE());
    
    WHILE v_month > 0 DO
        SELECT COUNT(*) INTO v_count
        FROM Question
        WHERE MONTH(CreateDate) = v_month AND YEAR(CreateDate) = v_year;
        
        IF v_count > 0 THEN
            SELECT CONCAT('Tháng ', v_month, '/', v_year, ' có ', v_count, ' câu hỏi') AS Message;
        ELSE
            SELECT CONCAT('Tháng ', v_month, '/', v_year, ' không có câu hỏi nào') AS Message;
        END IF;
        
        SET v_month = v_month - 1;
        
        IF v_month = 0 THEN
            SET v_month = 12;
            SET v_year = v_year - 1;
        END IF;
    END WHILE;
END //
DELIMITER ;