-- Active: 1716975660421@@127.0.0.1@3306@testing_system_db
USE Testing_System_Db;
--Exercise 1: Join
--Question 1: Viết lệnh để lấy ra danh sách nhân viên và thông tin phòng ban của họ

SELECT      A.`Email`, A.`Username`, A.`FullName`, D.`DepartmentName`
FROM        `Account` AS A
INNER JOIN  `Department` AS D
ON          A.`DepartmentID` = D.`DepartmentID`;

--Question 2: Viết lệnh để lấy ra thông tin các account được tạo sau ngày 20/12/2010

SELECT      *
FROM        `Account` 
WHERE       `CreateDate` > '2010-12-20';

--Question 3: Viết lệnh để lấy ra tất cả các developer

SELECT      A.`FullName`, A.`Email`, P.`PositionName`
FROM        `Account` AS A
INNER JOIN  `Position` AS P
ON          A.`PositionID` = P.`PositionID`
WHERE       P.`PositionName` = 'Dev';

--Question 4: Viết lệnh để lấy ra danh sách các phòng ban có > 3 nhân viên

SELECT      D.`DepartmentName`, COUNT(A.`DepartmentID`) AS NUM_OF_EMPLOYEES
FROM        `Account` AS A
INNER JOIN  `Department` AS D
ON          A.`DepartmentID` = D.`DepartmentID`
GROUP BY    A.`DepartmentID`
HAVING      COUNT(A.`DepartmentID`) > 3;

--Question 5: Viết lệnh để lấy ra danh sách câu hỏi được sử dụng trong đề thi nhiều nhất

SELECT      EQ.`QuestionID`, Q.`Content`, COUNT(EQ.`QuestionID`) AS NUM_TIMES_USED
FROM        `ExamQuestion` AS EQ
INNER JOIN  `Question` AS Q
ON          EQ.`QuestionID` = Q.`QuestionID`
GROUP BY    EQ.`QuestionID`
HAVING      COUNT(EQ.`QuestionID`) = (
                                     SELECT     COUNT(`QuestionID`)
                                     FROM       `ExamQuestion`
                                     GROUP BY   `QuestionID`
                                     ORDER BY   COUNT(`QuestionID`) DESC
                                     LIMIT      1
                                    );

--Question 6: Thống kê mỗi category Question được sử dụng trong bao nhiêu Question

SELECT      CQ.`CategoryID`, CQ.`CategoryName`, COUNT(Q.`CategoryID`) AS NUM_TIMES_USED
FROM        `CategoryQuestion` AS CQ
INNER JOIN  `Question` AS Q
ON          CQ.`CategoryID` = Q.`CategoryID`
GROUP BY    Q.`CategoryID`;

--Question 7: Thông kê mỗi Question được sử dụng trong bao nhiêu Exam

SELECT      Q.`QuestionID`, Q.`Content`, COUNT(Q.`QuestionID`) AS NUM_TIMES_USED
FROM        `Question` AS Q
LEFT JOIN   `ExamQuestion` AS EQ
ON          Q.`QuestionID` = EQ.`QuestionID`
GROUP BY    Q.`QuestionID`;

--Question 8: Lấy ra Question có nhiều câu trả lời nhất

SELECT      Q.`QuestionID`, Q.`Content`, COUNT(Q.`QuestionID`) AS NUM_OF_ANSWERS
FROM        `Question` AS Q
INNER JOIN  `Answer` AS A
ON          A.`QuestionID` = Q.`QuestionID`
GROUP BY    Q.`QuestionID`
ORDER BY    COUNT(Q.`QuestionID`) DESC
LIMIT       1;          

--Question 9: Thống kê số lượng account trong mỗi group

SELECT      G.`GroupID`, COUNT(GA.`AccountID`) AS NUM_OF_ACCOUNTS
FROM        `Group` AS G
LEFT JOIN   `GroupAccount` AS GA
ON          G.`GroupID` = GA.`GroupID`
GROUP BY    G.`GroupID`;

--Question 10: Tìm chức vụ có ít người nhất

SELECT      P.`PositionID`, P.`PositionName`, COUNT(A.`PositionID`) AS NUM_OF_ACCOUNTS
FROM        `Position` AS P
INNER JOIN  `Account` AS A
ON          P.`PositionID` = A.`PositionID`
GROUP BY    A.`PositionID`
HAVING      COUNT(A.`PositionID`) = (
                                    SELECT      COUNT(`PositionID`)
                                    FROM        `Account`
                                    GROUP BY    `PositionID`
                                    ORDER BY    COUNT(`PositionID`)
                                    LIMIT       1
                                    );

--Question 11: Thống kê mỗi phòng ban có bao nhiêu dev, test, scrum master, PM

SELECT      D.`DepartmentID`, D.`DepartmentName`, P.`PositionName`, COUNT(P.`PositionName`) AS NUM_OF_ACCOUNTS
FROM        `Account` AS A
INNER JOIN  `Department` AS D
ON          A.`DepartmentID` = D.`DepartmentID`
INNER JOIN  `Position` P 
ON          A.`PositionID` = P.`PositionID`
GROUP BY    D.`DepartmentID`, P.`PositionID`;

--Question 12: Lấy thông tin chi tiết của câu hỏi bao gồm: thông tin cơ bản của question, loại câu hỏi, ai là người tạo ra câu hỏi, câu trả lời là gì, …

SELECT      Q.`QuestionID`, Q.`Content`, CQ.`CategoryName`, TQ.`TypeName`, A.`FullName` AS Responder, ANS.`Content` AS Respond_Content
FROM        `Question` AS Q 
INNER JOIN  `CategoryQuestion` AS CQ 
ON          Q.`CategoryID` = CQ.`CategoryID`
INNER JOIN  `TypeQuestion` AS TQ 
ON          Q.`TypeID` = TQ.`TypeID` 
INNER JOIN  `Account` AS A 
ON          Q.`CreatorID` = A.`AccountID`
INNER JOIN	`Answer` AS ANS
ON          Q.`QuestionID` = ANS.`QuestionID` 
ORDER BY    Q.`QuestionID`;

--Question 13: Lấy ra số lượng câu hỏi của mỗi loại tự luận hay trắc nghiệm

SELECT      TQ.TypeID, TQ.TypeName, COUNT(Q.TypeID) AS NUM_OF_QUESTIONS
FROM        Question AS Q 
INNER JOIN  TypeQuestion AS TQ 
ON          Q.TypeID = TQ.TypeID
GROUP BY    Q.TypeID;

--Question 14: Lấy ra group không có account nào

SELECT      G.* 
FROM        `Group` AS G
LEFT JOIN   `GroupAccount` AS GA
ON          G.GroupID = GA.GroupID
WHERE       GA.AccountID IS NULL;

--Question 15: Lấy ra group không có account nào (cách 2)

SELECT      * 
FROM        `Group`
WHERE       GroupID NOT IN (
                            SELECT  GroupID
                            FROM    GroupAccount
                            );

--Question 16: Lấy ra question không có answer nào

SELECT      *
FROM        Question
WHERE       QuestionID NOT IN (
                                SELECT QuestionID
                                FROM   Answer
                                );


--Exercise 2: Union
--Question 17:
    --a) Lấy các account thuộc nhóm thứ 1
    SELECT      A.* 
    FROM        `Account` A
    INNER JOIN  GroupAccount GA 
    ON          A.AccountID = GA.AccountID 
    WHERE       GA.GroupID = 1;

    --b) Lấy các account thuộc nhóm thứ 2
    --c) Ghép 2 kết quả từ câu a) và câu b) sao cho không có record nào trùng nhau
--Question 18:
    --a) Lấy các group có lớn hơn 5 thành viên
    --b) Lấy các group có nhỏ hơn 7 thành viên
    --c) Ghép 2 kết quả từ câu a) và câu b)
