-- Active: 1716975660421@@127.0.0.1@3306@testing_system_db
USE Testing_System_Db;

-- Question 1: Thêm ít nhất 10 record vào mỗi table (Done)
-- Question 2: Lấy ra tất cả các phòng ban Department

SELECT      *
FROM        Department;

-- Question 3: Lấy ra id của phòng ban "Sale"

SELECT      DepartmentID
FROM        Department
WHERE       DepartmentName = 'Sale';

-- Question 4: lấy ra thông tin account có full name dài nhất

SELECT      *
FROM        `Account`
WHERE       LENGTH(FullName) = (
                                SELECT      MAX(LENGTH(FullName))
                                FROM        `Account`   
                                ); 

-- Question 5: Lấy ra thông tin account có full name dài nhất và thuộc phòng ban có id = 3

SELECT      *
FROM        `Account`
WHERE       LENGTH(FullName) = (
                                SELECT      MAX(LENGTH(FullName))
                                FROM        `Account`   
                                ) AND DepartmentID = 3; 

-- Question 6: Lấy ra tên group đã tham gia trước ngày 20/12/2019

SELECT      GroupName, `CreateDate`
FROM        `Group`
WHERE       CreateDate < '2019-12-20';

-- Question 7: Lấy ra ID của question có >= 4 câu trả lời

SELECT      QuestionID
FROM        Answer
GROUP BY    QuestionID
HAVING      COUNT(QuestionID) >= 4;

-- Question 8: Lấy ra các mã đề thi có thời gian thi >= 60 phút và được tạo trước ngày 20/12/2019

SELECT      ExamID
FROM        Exam
WHERE       Duration >= 60 AND CreateDate < '2019-12-20';

-- Question 9: Lấy ra 5 group được tạo gần đây nhất

SELECT      *
FROM        `Group`
ORDER BY    CreateDate DESC
LIMIT       5;

-- Question 10: Đếm số nhân viên thuộc department có id = 2

SELECT      COUNT(*) AS NUM_OF_EMPLOYEES
FROM        `Account`
WHERE       DepartmentID = 2;

-- Question 11: Lấy ra nhân viên có tên bắt đầu bằng chữ "D" và kết thúc bằng chữ "o"
-- Question 12: Xóa tất cả các exam được tạo trước ngày 20/12/2019
-- Question 13: Xóa tất cả các question có nội dung bắt đầu bằng từ "câu hỏi"
-- Question 14: Update thông tin của account có id = 5 thành tên "Lô Văn Đề" và email thành lo.vande@mmc.edu.vn
-- Question 15: Update account có id = 5 sẽ thuộc group có id = 4