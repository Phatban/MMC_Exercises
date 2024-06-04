USE Sale_Car;
DROP TABLE IF EXISTS Customer;
CREATE TABLE Customer(
    CustomerID          TINYINT PRIMARY KEY AUTO_INCREMENT,
    `Name`              NVARCHAR(50),
    Phone               CHAR(10),
    Email               VARCHAR(50),
    `Address`           NVARCHAR(100),
    Note                NVARCHAR(200)
);
DROP TABLE IF EXISTS Car;
CREATE TABLE Car(
    CarID               TINYINT PRIMARY KEY AUTO_INCREMENT,
    Maker               ENUM('HONDA','TOYOTA','NISSAN'),
    Model               VARCHAR(50),
    `Year`              TINYINT,
    Color               VARCHAR(20),
    Note                NVARCHAR(200)
);
DROP TABLE IF EXISTS Car_Order;
CREATE TABLE Car_Order(
    OrderID             TINYINT PRIMARY KEY AUTO_INCREMENT,
    CustomerID          foreign key.
    CarID               foreign key.
    Amount              default value = 1.
    SalePrice           
    OrderDate           
    DeliveryDate        
    DeliveryAddress     
    `Status`            (0: đã đặt hàng, 1: đã giao, 2: đã hủy), mặc định trạng thái là đã đặt hàng.
    Note                
);