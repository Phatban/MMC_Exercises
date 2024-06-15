DROP DATABASE IF EXISTS Sale_Car;
CREATE DATABASE Sale_Car;
USE Sale_Car;
-- Tạo bảng CUSTOMER
DROP TABLE IF EXISTS CUSTOMER;
CREATE TABLE CUSTOMER (
    CustomerID  MEDIUMINT PRIMARY KEY AUTO_INCREMENT,
    `Name`      NVARCHAR(50),
    Phone       CHAR(10),
    Email       VARCHAR(50),
    `Address`   NVARCHAR(100),
    Note        TEXT
);

-- Tạo bảng CAR 
DROP TABLE IF EXISTS CAR;
CREATE TABLE CAR (
    CarID       MEDIUMINT PRIMARY KEY,
    Maker       ENUM('HONDA', 'TOYOTA', 'NISSAN'),  
    Model       VARCHAR(50),
    `Year`      SMALLINT,
    Color       VARCHAR(20),
    Note        TEXT
);

-- Tạo bảng CAR_ORDER
DROP TABLE IF EXISTS CAR_ORDER;
CREATE TABLE CAR_ORDER (
    OrderID             MEDIUMINT PRIMARY KEY AUTO_INCREMENT,
    CustomerID          MEDIUMINT,
    CarID               MEDIUMINT,
    Amount              TINYINT DEFAULT 1,
    SalePrice           DECIMAL(10, 2),
    OrderDate           DATE,
    DeliveryDate        DATE,
    DeliveryAddress     VARCHAR(100),
    `Status`            TINYINT DEFAULT 0,
    Note                TEXT,
    FOREIGN KEY (CustomerID)    REFERENCES CUSTOMER(CustomerID),
    FOREIGN KEY (CarID)         REFERENCES CAR(CarID)
);
--1. Tạo bảng với ràng buộc và kiểu dữ liệu. Sau đó, thêm ít nhất 5 bản ghi vào bảng.
--  + Thêm dữ liệu mẫu cho bảng CUSTOMER
INSERT INTO CUSTOMER 
    (`Name`         , Phone         , Email                 , `Address` ) 
VALUES
    ('John Smith'   , '0987654321'  , 'john@example.com'    , 'New York'),
    ('Sarah Johnson', '0912345678'  , 'sarah@example.com'   , 'London'  ),
    ('David Lee'    , '0977889900'  , 'david@example.com'   , 'Tokyo'   ),
    ('Lisa Nguyen'  , '0988776655'  , 'lisa@example.com'    , 'Hanoi'   ),    
    ('Tom Wilson'   , '0955443322'  , 'tom@example.com'     , 'Sydney'  );

--  + Thêm dữ liệu mẫu cho bảng CAR  
INSERT INTO CAR 
    (CarID  , Maker     , Model     , `Year`, Color   )
VALUES
    (1      , 'HONDA'   , 'Civic'   , 2022  , 'White' ), 
    (2      , 'TOYOTA'  , 'Camry'   , 2021  , 'Black' ),
    (3      , 'NISSAN'  , 'Altima'  , 2023  , 'Red'   ),
    (4      , 'HONDA'   , 'Accord'  , 2022  , 'Gray'  ),
    (5      , 'TOYOTA'  , 'Corolla' , 2023  , 'Blue'  );

--  + Thêm dữ liệu mẫu cho bảng ORDER
INSERT INTO CAR_ORDER 
    (CustomerID , CarID , Amount, SalePrice , OrderDate     , DeliveryDate  , DeliveryAddress   )
VALUES
    (1          , 1     , 1     , 30000     , '2023-02-15'  , '2023-03-03'  , 'New York'        ),  
    (1          , 3     , 1     , 28000     , '2023-06-01'  , NULL          , 'New York'        ),
    (2          , 2     , 2     , 54000     , '2022-12-01'  , '2022-12-17'  , 'London'          ),
    (3          , 4     , 1     , 32000     , '2023-05-15'  , '2023-06-01'  , 'Tokyo'           ),
    (4          , 5     , 3     , 72000     , '2023-04-20'  , '2023-05-08'  , 'Hanoi'           );

--2. Viết lệnh lấy ra thông tin của khách hàng: tên, số lượng oto khách hàng đã mua và sắp sếp tăng dần theo số lượng oto đã mua.

SELECT 
    C.CustomerID,
    C.`Name`, 
    COALESCE(SUM(CO.Amount), 0) AS TotalCars 
FROM 
    CUSTOMER AS C
    LEFT JOIN CAR_ORDER AS CO ON C.CustomerID = CO.CustomerID
GROUP BY C.CustomerID
ORDER BY TotalCars;

--3. Viết hàm (không có parameter) trả về tên hãng sản xuất đã bán được nhiều oto nhất trong năm nay.

SET GLOBAL log_bin_trust_function_creators = 1;
DELIMITER //
CREATE FUNCTION GetTopCarMaker() RETURNS VARCHAR(20)
BEGIN
    DECLARE topMaker VARCHAR(20);
    
    SELECT 
        Maker INTO topMaker
    FROM 
        CAR_ORDER CO
        JOIN CAR C ON CO.CarID = C.CarID
    WHERE YEAR(CO.OrderDate) = YEAR(CURDATE())  
    GROUP BY C.Maker
    ORDER BY SUM(CO.Amount) DESC
    LIMIT 1;
    
    RETURN topMaker;
END //

DELIMITER ;

--4. Viết 1 thủ tục (không có parameter) để xóa các đơn hàng đã bị hủy của những năm trước. In ra số lượng bản ghi đã bị xóa.

DELIMITER //

CREATE PROCEDURE DeleteCanceledOrders()
BEGIN
    DECLARE rowsDeleted INT;
    
    DELETE FROM CAR_ORDER 
    WHERE `Status` = 2 AND YEAR(OrderDate) < YEAR(CURDATE());
    
    SET rowsDeleted = ROW_COUNT();
    
    SELECT CONCAT(rowsDeleted, ' orders have been deleted.') AS Message;
END //

DELIMITER ;

--5. Viết 1 thủ tục (có CustomerID parameter) để in ra thông tin của các đơn hàng đã đặt hàng bao gồm: tên của khách hàng, mã đơn hàng, số lượng oto và tên hãng sản xuất.

DELIMITER //

CREATE PROCEDURE GetCustomerOrders(IN cusID INT)
BEGIN
    SELECT 
        C.Name AS CustomerName,
        O.OrderID,
        O.Amount,
        R.Maker AS CarMaker
    FROM CAR_ORDER AS O
    JOIN CUSTOMER AS C ON O.CustomerID = C.CustomerID
    JOIN CAR AS R ON O.CarID = R.CarID
    WHERE O.CustomerID = cusID AND O.Status = 0;
END //

DELIMITER ;

--6. Viết trigger để tránh trường hợp người dụng nhập thông tin không hợp lệ vào database (DeliveryDate < OrderDate + 15).

DELIMITER //

CREATE TRIGGER CheckDeliveryDate
BEFORE INSERT ON CAR_ORDER
FOR EACH ROW
BEGIN
    IF NEW.DeliveryDate < DATE_ADD(NEW.OrderDate, INTERVAL 15 DAY) THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Delivery date must be at least 15 days after order date.';
    END IF;
END //

DELIMITER ;