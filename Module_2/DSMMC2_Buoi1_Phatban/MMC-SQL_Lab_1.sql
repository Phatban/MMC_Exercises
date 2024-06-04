CREATE DATABASE IF NOT EXISTS Testing_System_Db;
USE Testing_System_Db;
CREATE TABLE IF NOT EXISTS Department(
    DepartmentID    TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    DepartmentName  VARCHAR(50)
);
CREATE TABLE IF NOT EXISTS `Position`(
    PositionID      TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    PositionName    VARCHAR(50)
);
CREATE TABLE IF NOT EXISTS Account(
    AccountID       TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    Email           VARCHAR(50),
    Username        VARCHAR(50),
    FullName        VARCHAR(50),
    DepartmentID    TINYINT UNSIGNED,
    PositionID      TINYINT UNSIGNED,
    CreateDate      DATE
);
CREATE TABLE IF NOT EXISTS `Group`( 
    GroupID         TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    GroupName       VARCHAR(50),
    CreatorID       TINYINT UNSIGNED,
    CreateDate      DATE
);
CREATE TABLE IF NOT EXISTS GroupAccount( 
    GroupID         TINYINT UNSIGNED,
    AccountID       TINYINT UNSIGNED,
    JoinDate        DATE
);
CREATE TABLE IF NOT EXISTS TypeQuestion( 
    TypeID          TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    TypeName        VARCHAR(50)
);
CREATE TABLE IF NOT EXISTS CategoryQuestion( 
    CategoryID      TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    CategoryName    VARCHAR(50)
);
CREATE TABLE IF NOT EXISTS Question(
    QuestionID      TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    Content         VARCHAR(50),
    CategoryID      TINYINT UNSIGNED,
    TypeID          TINYINT UNSIGNED,
    CreatorID       TINYINT UNSIGNED,
    CreateDate      DATE
);
CREATE TABLE IF NOT EXISTS Answer(
    AnswerID        TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    Content         VARCHAR(50),
    QuestionID      TINYINT UNSIGNED,
    isCorrect       VARCHAR(50)
);
CREATE TABLE IF NOT EXISTS Exam(
    ExamID          TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    Code            TINYINT UNSIGNED,
    Title           VARCHAR(50),
    CategoryID      TINYINT UNSIGNED,
    Duration        TIME,
    CreatorID       TINYINT UNSIGNED,
    CreateDate      DATE
);
CREATE TABLE IF NOT EXISTS ExamQuestion(
    ExamID          TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    QuestionID      TINYINT UNSIGNED
);