-- Active: 1714662801252@@127.0.0.1@3306@testing_system_db
USE Testing_System_Db;
--Question 1: Tạo view có chứa danh sách nhân viên thuộc phòng ban sale

DROP VIEW IF EXISTS view_sale_employees;
CREATE VIEW view_sale_employees AS 
    SELECT      A.*
    FROM        `Account` AS A
    INNER JOIN  `Department` AS D
    ON          A.`DepartmentID` = D.`DepartmentID`
    WHERE       D.`DepartmentName` = 'Sale';

--Question 2: Tạo view có chứa thông tin các account tham gia vào nhiều group nhất

DROP VIEW IF EXISTS view_most_account_group;
CREATE VIEW view_most_account_group AS 
    SELECT      *
    FROM        `Account`
    WHERE       `AccountID` = (
                               SELECT       COUNT(`AccountID`)
                               FROM         `GroupAccount`
                               GROUP BY     `AccountID`
                               ORDER BY     COUNT(`AccountID`) DESC
                               LIMIT        1
                              );

--Question 3: Tạo view có chứa câu hỏi có những content quá dài (content quá 300 từ được coi là quá dài) và xóa nó đi

DROP VIEW IF EXISTS view_long_content_questions;
CREATE VIEW view_long_content_questions AS
    SELECT      *
    FROM        `Question`
    WHERE       LENGTH(`Content`) > 300;
DELETE
FROM        `Question`
WHERE       `QuestionID` IN (
                             SELECT     `QuestionID`
                             FROM       view_long_content_questions
                            );

--Question 4: Tạo view có chứa danh sách các phòng ban có nhiều nhân viên nhất

DROP VIEW IF EXISTS view_most_employees_department
CREATE VIEW view_most_employees_department AS
    SELECT      *
    FROM        `Department`
    

--Question 5: Tạo view có chứa tất các các câu hỏi do user họ Nguyễn tạo