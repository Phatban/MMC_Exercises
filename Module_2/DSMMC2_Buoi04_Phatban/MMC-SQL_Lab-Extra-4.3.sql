USE hr;

-- Bài toán 1: Viết truy vấn để lấy tên và ngày bắt đầu công việc của tất cả nhân viên làm việc trong phòng ban số 5

SELECT      E.`F_NAME`, E.`L_NAME`, JH.`START_DATE`
FROM        Employees E
INNER JOIN  Job_History JH
ON          E.`EMP_ID` = JH.`EMPL_ID`
WHERE       E.`DEP_ID` = 5;

-- Bài toán 2: Viết truy vấn để lấy tên, ngày bắt đầu công việc và tên công việc của tất cả nhân viên làm việc trong phòng ban số 5.

SELECT      E.`F_NAME`, E.`L_NAME`, JH.`START_DATE`, J.`JOB_TITLE`
FROM        Employees AS E
INNER JOIN  Job_History AS JH
ON          E.`EMP_ID` = JH.`EMPL_ID`
INNER JOIN  Jobs AS J
ON          E.`JOB_ID` = J.`JOB_IDENT`
WHERE       E.`DEP_ID` = 5;

-- Bài toán 3: Thực hiện Left Outer Join trên các bảng  EMPLOYEES và DEPARTMENT và chọn employee id (id nhân viên), last name (họ), department id (id phòng ban), department name (tên phòng ban) cho tất cả nhân viên.

SELECT              E.`EMP_ID`, E.`L_NAME`, E.`DEP_ID`, D.`DEP_NAME`
FROM                Employees AS E
LEFT OUTER JOIN     Departments AS D
ON                  E.`DEP_ID` = D.`DEPT_ID_DEP`;

-- Bài toán 4: Viết lại truy vấn trước đó nhưng giới hạn tập kết quả chỉ có các hàng dành cho nhân viên sinh trước năm 1980.

SELECT              E.`EMP_ID`, E.`L_NAME`, E.`DEP_ID`, D.`DEP_NAME`
FROM                Employees AS E
LEFT OUTER JOIN     Departments AS D
ON                  E.`DEP_ID` = D.`DEPT_ID_DEP`
WHERE               YEAR(E.`B_DATE`) < 1980;

-- Bài toán 5: Viết lại truy vấn trước đó nhưng sẽ sử dụng INNER JOIN thay vì sử dụng LEFT OUTER JOIN.

SELECT          E.`EMP_ID`, E.`L_NAME`, E.`DEP_ID`, D.`DEP_NAME`
FROM            Employees AS E
INNER JOIN      Departments AS D
ON              E.`DEP_ID` = D.`DEPT_ID_DEP`
WHERE           YEAR(E.`B_DATE`) < 1980;

-- Bài toán 6: Thực hiện một FULL OUTER JOIN trên bảng EMPLOYEES và DEPARTMENT và chọn First name (tên), Last name (họ) và Department name (tên phòng ban) của tất cả nhân viên.

SELECT          E.`F_NAME`, E.`L_NAME`, D.`DEP_NAME`
FROM            Employees AS E
LEFT JOIN       Departments AS D
ON              E.`DEP_ID` = D.`DEPT_ID_DEP` 
UNION ALL
SELECT          E.`F_NAME`, E.`L_NAME`, D.`DEP_NAME`
FROM            Employees AS E
RIGHT JOIN      Departments AS D
ON              E.`DEP_ID` = D.`DEPT_ID_DEP`;

-- Bài toán 7: Viết lại truy vấn trước đó nhưng có tập kết quả bao gồm tất cả employee names (tên nhân viên) nhưng department id (id phòng ban) và department names (tên phòng ban) chỉ dành cho nhân viên nam.

SELECT          E.`F_NAME`, E.`L_NAME`, D.`DEPT_ID_DEP`, D.`DEP_NAME`
FROM            Employees AS E
LEFT JOIN       Departments AS D
ON              E.`DEP_ID` = D.`DEPT_ID_DEP` AND E.`SEX` = 'M'
UNION ALL
SELECT          E.`F_NAME`, E.`L_NAME`, D.`DEPT_ID_DEP`, D.`DEP_NAME`
FROM            Employees AS E
RIGHT JOIN      Departments AS D
ON              E.`DEP_ID` = D.`DEPT_ID_DEP` AND E.`SEX` = 'M';