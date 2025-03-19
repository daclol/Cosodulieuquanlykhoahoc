-- ================================
-- Tạo Database
-- ================================
CREATE DATABASE QuanLyLoli;
GO
USE QuanLyLoli;
GO

-- ================================
-- Bảng Users
-- ================================
CREATE TABLE Users (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    email NVARCHAR(100) UNIQUE NOT NULL,
    password NVARCHAR(255) NOT NULL,
    role NVARCHAR(20) CHECK (role IN ('student', 'instructor', 'admin')) DEFAULT 'student',
    created_at DATETIME DEFAULT GETDATE()
);

-- ================================
-- Bảng Courses
-- ================================
CREATE TABLE Courses (
    course_id INT IDENTITY(1,1) PRIMARY KEY,
    title NVARCHAR(255) NOT NULL,
    description NVARCHAR(MAX),
    instructor_id INT NULL,
    price DECIMAL(10,2) DEFAULT 0.00,
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (instructor_id) REFERENCES Users(user_id) ON DELETE SET NULL
);

-- ================================
-- Bảng Enrollments
-- ================================
CREATE TABLE Enrollments (
    enrollment_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    course_id INT NOT NULL,
    enrolled_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES Courses(course_id) ON DELETE CASCADE
);

-- ================================
-- Tạo View (Báo Cáo)
-- ================================

-- Danh sách sinh viên & khóa học họ đăng ký
CREATE VIEW View_UserCourses AS
SELECT U.user_id, U.name, C.title 
FROM Users U
JOIN Enrollments E ON U.user_id = E.user_id
JOIN Courses C ON E.course_id = C.course_id;

-- Số lượng học viên trên mỗi khóa học
CREATE VIEW View_CourseCount AS
SELECT course_id, COUNT(*) AS student_count 
FROM Enrollments 
GROUP BY course_id;

-- Danh sách giảng viên
CREATE VIEW View_Instructors AS
SELECT user_id, name, email 
FROM Users 
WHERE role = 'instructor';

-- Danh sách sinh viên
CREATE VIEW View_Students AS
SELECT user_id, name, email 
FROM Users 
WHERE role = 'student';

-- Doanh thu mỗi khóa học
CREATE VIEW View_CourseRevenue AS
SELECT 
    C.course_id, 
    C.title, 
    COUNT(E.enrollment_id) * C.price AS revenue 
FROM Courses C
LEFT JOIN Enrollments E ON C.course_id = E.course_id 
GROUP BY C.course_id, C.title, C.price;

-- Lượt đăng ký gần nhất
CREATE VIEW View_LatestEnrollments AS
SELECT * FROM Enrollments;

-- Khóa học phổ biến nhất (có nhiều học viên)
CREATE VIEW View_PopularCourses AS
SELECT course_id, COUNT(*) AS enrollments 
FROM Enrollments 
GROUP BY course_id;

-- Người dùng đăng ký nhiều khóa học nhất
CREATE VIEW View_UsersWithMostCourses AS
SELECT U.user_id, U.name, COUNT(E.course_id) AS course_count 
FROM Users U
JOIN Enrollments E ON U.user_id = E.user_id 
GROUP BY U.user_id, U.name;

-- Người dùng hoạt động (đã đăng ký ít nhất 1 khóa học)
CREATE VIEW View_ActiveUsers AS
SELECT user_id, name 
FROM Users 
WHERE user_id IN (SELECT DISTINCT user_id FROM Enrollments);

-- Các khóa học chưa có học viên nào đăng ký
CREATE VIEW View_CoursesWithNoEnrollments AS
SELECT C.course_id, C.title 
FROM Courses C 
WHERE NOT EXISTS (
    SELECT 1 FROM Enrollments E WHERE C.course_id = E.course_id
);

-- ================================
-- Dữ liệu mẫu
-- ================================
INSERT INTO Users (name, email, password, role) VALUES
(N'Nguyễn Văn A', 'a@gmail.com', 'password1', 'student'),
(N'Trần Thị B', 'b@gmail.com', 'password2', 'student'),
(N'Lê Văn C', 'c@gmail.com', 'password3', 'instructor'),
(N'Phạm Thị D', 'd@gmail.com', 'password4', 'student'),
(N'Hoàng Văn E', 'e@gmail.com', 'password5', 'instructor'),
(N'Võ Thị F', 'f@gmail.com', 'password6', 'admin'),
(N'Đặng Văn G', 'g@gmail.com', 'password7', 'student'),
(N'Bùi Thị H', 'h@gmail.com', 'password8', 'instructor'),
(N'Đỗ Văn I', 'i@gmail.com', 'password9', 'student'),
(N'Phan Thị J', 'j@gmail.com', 'password10', 'student');

INSERT INTO Courses (title, description, instructor_id, price) VALUES
(N'SQL Cơ Bản', N'Học SQL từ cơ bản đến nâng cao', 3, 1000000),
(N'Python Cho Người Mới Bắt Đầu', N'Khóa học lập trình Python', 5, 1500000),
(N'Lập Trình C++', N'Học C++ từ cơ bản đến nâng cao', 3, 1200000),
(N'Kỹ Thuật Machine Learning', N'Giới thiệu về Machine Learning', 8, 2000000),
(N'Phân Tích Dữ Liệu Với Python', N'Sử dụng pandas, numpy, matplotlib', 5, 1800000);

INSERT INTO Enrollments (user_id, course_id) VALUES
(1, 1), (1, 2), (2, 3), (2, 4), (3, 5),
(3, 6), (7, 7), (8, 8), (9, 9), (10, 10);

-- ================================
-- Truy vấn kiểm tra dữ liệu
-- ================================
SELECT * FROM Users;
SELECT * FROM Courses;
SELECT * FROM Enrollments;

-- In dữ liệu từ các VIEW đã tạo
SELECT * FROM View_UserCourses;
SELECT * FROM View_CourseCount;
SELECT * FROM View_Instructors;
SELECT * FROM View_Students;
SELECT * FROM View_CourseRevenue;
SELECT * FROM View_LatestEnrollments ORDER BY enrolled_at DESC;
SELECT * FROM View_PopularCourses ORDER BY enrollments DESC;
SELECT * FROM View_UsersWithMostCourses ORDER BY course_count DESC;
SELECT * FROM View_ActiveUsers;
SELECT * FROM View_CoursesWithNoEnrollments;



--thêm dữ liêu j
INSERT INTO Courses (title, description, instructor_id, price, created_at) 
VALUES ('SQL Basics', 'Learn SQL from scratch', 1, 200.00, GETDATE());

INSERT INTO Enrollments (user_id, course_id, enrolled_at) VALUES (1, 1, GETDATE());
INSERT INTO Enrollments (user_id, course_id, enrolled_at) VALUES (2, 1, GETDATE());
INSERT INTO Enrollments (user_id, course_id, enrolled_at) VALUES (3, 1, GETDATE());
INSERT INTO Enrollments (user_id, course_id, enrolled_at) VALUES (4, 1, GETDATE());
INSERT INTO Enrollments (user_id, course_id, enrolled_at) VALUES (5, 1, GETDATE());
INSERT INTO Enrollments (user_id, course_id, enrolled_at) VALUES (6, 1, GETDATE());
INSERT INTO Enrollments (user_id, course_id, enrolled_at) VALUES (7, 1, GETDATE());
INSERT INTO Enrollments (user_id, course_id, enrolled_at) VALUES (8, 1, GETDATE());
INSERT INTO Enrollments (user_id, course_id, enrolled_at) VALUES (9, 1, GETDATE());
INSERT INTO Enrollments (user_id, course_id, enrolled_at) VALUES (10, 1, GETDATE());


SET IDENTITY_INSERT Courses ON;
INSERT INTO Courses (course_id, title, description, instructor_id, price, created_at) 
VALUES (1, 'SQL Basics', 'Learn SQL from scratch', 1, 200.00, GETDATE());
SET IDENTITY_INSERT Courses OFF;

--procedure 

CREATE PROCEDURE Insert_Multiple_Enrollments
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @i INT = 1;

    WHILE @i <= 10
    BEGIN
        INSERT INTO Enrollments (user_id, course_id, enrolled_at) 
        VALUES (@i, 1, GETDATE());
        
        SET @i = @i + 1;
    END
END;
EXEC Insert_Multiple_Enrollments;
SELECT * FROM Enrollments;

--
CREATE PROCEDURE AddUser
    @name NVARCHAR(100),
    @email NVARCHAR(100),
    @password NVARCHAR(255),
    @role NVARCHAR(20) = 'student'
AS
BEGIN
    INSERT INTO Users (name, email, password, role)
    VALUES (@name, @email, HASHBYTES('SHA2_256', @password), @role);
    SELECT SCOPE_IDENTITY() AS NewUserID;
END;
GO

CREATE PROCEDURE AddCourse
    @title NVARCHAR(255),
    @description NVARCHAR(MAX),
    @instructor_id INT,
    @price DECIMAL(10,2)
AS
BEGIN
    INSERT INTO Courses (title, description, instructor_id, price)
    VALUES (@title, @description, @instructor_id, @price);
END;
GO

CREATE PROCEDURE EnrollStudent
    @user_id INT,
    @course_id INT
AS
BEGIN
    INSERT INTO Enrollments (user_id, course_id)
    VALUES (@user_id, @course_id);
END;
GO

CREATE PROCEDURE GetAllUsers
AS
BEGIN
    SELECT * FROM Users;
END;
GO

CREATE PROCEDURE GetUserById
    @user_id INT
AS
BEGIN
    SELECT * FROM Users WHERE user_id = @user_id;
END;
GO

CREATE PROCEDURE GetCoursesByInstructor
    @instructor_id INT
AS
BEGIN
    SELECT * FROM Courses WHERE instructor_id = @instructor_id;
END;
GO

CREATE PROCEDURE UpdateUserRole
    @user_id INT,
    @new_role NVARCHAR(20)
AS
BEGIN
    UPDATE Users SET role = @new_role WHERE user_id = @user_id;
END;
GO

CREATE PROCEDURE DeleteUser
    @user_id INT
AS
BEGIN
    DELETE FROM Users WHERE user_id = @user_id;
END;
GO

CREATE PROCEDURE DeleteCourse
    @course_id INT
AS
BEGIN
    DELETE FROM Courses WHERE course_id = @course_id;
END;
GO


SELECT SCOPE_IDENTITY() AS NewUserID;
SELECT SCOPE_IDENTITY() AS NewCourseID;
SELECT 'Student enrolled successfully' AS Message;
SELECT 'User role updated successfully' AS Message;
SELECT 'User deleted successfully' AS Message;

--Trigger 
CREATE TRIGGER trg_Insert_Enrollments
ON Users
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @user_id INT;

--
CREATE TRIGGER trg_AfterInsertUser
ON Users
AFTER INSERT
AS
BEGIN
    PRINT 'A new user has been added';
END;
GO

CREATE TRIGGER trg_AfterDeleteUser
ON Users
AFTER DELETE
AS
BEGIN
    PRINT 'A user has been deleted';
END;
GO

CREATE TRIGGER trg_AfterUpdateUserRole
ON Users
AFTER UPDATE
AS
BEGIN
    IF UPDATE(role)
    PRINT 'User role has been updated';
END;
GO

CREATE TRIGGER trg_AfterInsertCourse
ON Courses
AFTER INSERT
AS
BEGIN
    PRINT 'A new course has been added';
END;
GO

CREATE TRIGGER trg_AfterDeleteCourse
ON Courses
AFTER DELETE
AS
BEGIN
    PRINT 'A course has been deleted';
END;
GO

CREATE TRIGGER trg_AfterEnrollStudent
ON Enrollments
AFTER INSERT
AS
BEGIN
    PRINT 'A student has been enrolled in a course';
END;
GO

CREATE TRIGGER trg_AfterDeleteEnrollment
ON Enrollments
AFTER DELETE
AS
BEGIN
    PRINT 'A student has been unenrolled from a course';
END;
GO

CREATE TRIGGER trg_BeforeInsertUser
ON Users
INSTEAD OF INSERT
AS
BEGIN
    PRINT 'Before inserting a user';
END;
GO

CREATE TRIGGER trg_BeforeDeleteCourse
ON Courses
INSTEAD OF DELETE
AS
BEGIN
    PRINT 'Before deleting a course';
END;
GO


    
    -- Lấy user_id của user vừa được thêm vào
    SELECT @user_id = user_id FROM inserted;

    DECLARE @i INT = 1;

    WHILE @i <= 10
    BEGIN
        INSERT INTO Enrollments (user_id, course_id, enrolled_at)
        VALUES (@user_id, @i, GETDATE());

        SET @i = @i + 1;
    END
END;


INSERT INTO Users (name, email, password, role, created_at)
VALUES 
    ('John Doe', 'john@example.com', 'securepassword', 'student', GETDATE()),
    ('Alice Smith', 'alice@example.com', 'password123', 'student', GETDATE()),
    ('Bob Johnson', 'bob@example.com', 'mypassword', 'teacher', GETDATE()),
    ('Charlie Brown', 'charlie@example.com', 'charliepass', 'admin', GETDATE()),
    ('David Wilson', 'david@example.com', 'davidpass', 'student', GETDATE()),
    ('Emma Davis', 'emma@example.com', 'emmapass', 'teacher', GETDATE());
--
CREATE TABLE Enrollments (
    enrollment_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT,
    course_id INT,
    enrolled_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);
INSERT INTO Enrollments (user_id, course_id)
SELECT user_id, course_id
FROM Users, Courses
WHERE user_id <= 5 AND course_id <= 5; -- Chỉ lấy 5 bản ghi mẫu

-- Kiểm tra lại dữ liệu
SELECT * FROM Enrollments;



INSERT INTO Enrollments (user_id, course_id)
VALUES 
( (SELECT TOP 1 user_id FROM Users ORDER BY NEWID()), 
  (SELECT TOP 1 course_id FROM Courses ORDER BY NEWID()) );

  SELECT * FROM Enrollments;

--
SELECT MAX(user_id) FROM Users;
SELECT * FROM Enrollments;
SELECT * FROM Users;
SELECT * FROM Users WHERE email = 'alice@example.com';



-- VAI TRÒ VÀ QUYỀN CỦA NGƯỜI DÙNG
CREATE ROLE StudentRole;
CREATE ROLE InstructorRole;
CREATE ROLE AdminRole;

GRANT SELECT ON Users TO StudentRole;
GRANT SELECT, INSERT, UPDATE ON Enrollments TO StudentRole;

GRANT SELECT, INSERT, UPDATE, DELETE ON Courses TO InstructorRole;
GRANT SELECT, INSERT, UPDATE ON Enrollments TO InstructorRole;

GRANT CONTROL ON Users TO AdminRole;
GRANT CONTROL ON Courses TO AdminRole;
GRANT CONTROL ON Enrollments TO AdminRole;

-- THÊM NGƯỜI DÙNG VÀO VAI TRÒ
EXEC sp_addrolemember 'StudentRole', 'student_user';
EXEC sp_addrolemember 'InstructorRole', 'instructor_user';
EXEC sp_addrolemember 'AdminRole', 'admin_user';

--
SELECT dp.name AS RoleName, 
       o.name AS ObjectName, 
       p.permission_name AS PermissionType
FROM sys.database_permissions p
JOIN sys.database_principals dp ON p.grantee_principal_id = dp.principal_id
LEFT JOIN sys.objects o ON p.major_id = o.object_id
WHERE dp.type IN ('R', 'S')
ORDER BY dp.name, o.name;

SELECT r.name AS RoleName, 
       m.name AS UserName
FROM sys.database_role_members rm
JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
JOIN sys.database_principals m ON rm.member_principal_id = m.principal_id
ORDER BY r.name, m.name;



EXEC sp_helprotect NULL, 'student_user';


-- Dữ liêụ amin 
INSERT INTO Users (name, email, password, role) VALUES
('Alice Johnson', 'alice@example.com', HASHBYTES('SHA2_256', 'password123'), 'student'),
('Bob Smith', 'bob@example.com', HASHBYTES('SHA2_256', 'password123'), 'instructor'),
('Charlie Adams', 'charlie@example.com', HASHBYTES('SHA2_256', 'password123'), 'admin');

INSERT INTO Courses (title, description, instructor_id, price) VALUES
('SQL for Beginners', 'Learn SQL from scratch', 2, 49.99),
('Advanced Database Design', 'Deep dive into database architecture', 2, 99.99);

INSERT INTO Enrollments (user_id, course_id) VALUES
(1, 1),
(1, 2);


DELETE FROM Enrollments WHERE user_id = 3 AND course_id = 2;
EXEC UpdateUserRole @user_id = 1, @new_role = 'admin';

SELECT SCOPE_IDENTITY() AS NewCourseID;
 

-- thêm dữ liệu Pro 

-- Chèn dữ liệu mẫu vào bảng Users
INSERT INTO Users (name, email, password, role) 
VALUES ('John Doe', 'john.doe@example.com', 'password123', 'student');

-- Chèn dữ liệu mẫu vào bảng Courses
INSERT INTO Courses (title, description, instructor_id, price) 
VALUES ('SQL Basics', 'Introduction to SQL', 1, 99.99);

-- Kiểm tra ID mới được tạo
SELECT SCOPE_IDENTITY() AS NewID;
INSERT INTO Users (name, email, password, role) VALUES
('Alice Johnson', 'alice.johnson@example.com', 'pass123', 'student'),
('Bob Smith', 'bob.smith@example.com', 'pass123', 'student'),
('Charlie Brown', 'charlie.brown@example.com', 'pass123', 'instructor'),
('David Wilson', 'david.wilson@example.com', 'pass123', 'admin'),
('Emma Davis', 'emma.davis@example.com', 'pass123', 'student'),
('Frank Thomas', 'frank.thomas@example.com', 'pass123', 'student'),
('Grace Lee', 'grace.lee@example.com', 'pass123', 'instructor'),
('Henry Martin', 'henry.martin@example.com', 'pass123', 'student'),
('Isabella White', 'isabella.white@example.com', 'pass123', 'student'),
('Jack Harris', 'jack.harris@example.com', 'pass123', 'admin'),
('Karen Clark', 'karen.clark@example.com', 'pass123', 'instructor'),
('Leo Young', 'leo.young@example.com', 'pass123', 'student'),
('Mia Scott', 'mia.scott@example.com', 'pass123', 'student'),
('Noah Walker', 'noah.walker@example.com', 'pass123', 'instructor');
