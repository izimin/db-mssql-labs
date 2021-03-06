USE [master]
GO

-- Создание БД
CREATE DATABASE Library7
GO
USE Library7
GO
------------------------------------------------------------ТАБЛИЦЫ-------------------------------------------------------------------------------------------
-- Создание таблицы книг 
CREATE TABLE Books
(
	id_book int IDENTITY(1,1) NOT NULL,
	Author	nvarchar(50)	  NOT NULL,
	Name	nvarchar(50)	  NOT NULL, 

	CONSTRAINT PK_Books PRIMARY KEY CLUSTERED 
	(
		id_book ASC
	) 
)

-- Создание таблицы читателей 
CREATE TABLE Readers
(
	id_reader int IDENTITY(1,1) NOT NULL,
	FIO		  nvarchar(50)		NOT NULL,
	[Address] nvarchar(50)		NOT NULL,
	
	CONSTRAINT PK_Readers PRIMARY KEY CLUSTERED 
	(
		id_reader ASC
	) 
) 

-- Создание таблицы выдачи книг
CREATE TABLE Delivery
(
	id_delivery   int IDENTITY(1,1) NOT NULL,
	id_reader	  int				NOT NULL,
	id_book		  int				NOT NULL,
	date_delivery date				NOT NULL,
	date_return	  date				NOT NULL,
 
	CONSTRAINT PK_Delivery PRIMARY KEY CLUSTERED 
	(
		id_delivery ASC
	)
) 

----------------------------------------------------------СВЯЗИ-------------------------------------------------------------------------------------------------------
-- Описание связей 
ALTER TABLE Delivery  WITH CHECK ADD  CONSTRAINT FK_Delivery_Books FOREIGN KEY(id_book)
REFERENCES Books (id_book)
GO
ALTER TABLE Delivery CHECK CONSTRAINT FK_Delivery_Books
GO

ALTER TABLE Delivery  WITH CHECK ADD  CONSTRAINT FK_Delivery_Readers FOREIGN KEY(id_reader)
REFERENCES Readers (id_reader)
GO
ALTER TABLE Delivery CHECK CONSTRAINT FK_Delivery_Readers
GO

------------------------------------------------------ПРЕДСТАВЛЕНИЕ------------------------------------------------------------------------------------------------------
-- Создание предствления
CREATE VIEW ViewDelivery
AS
SELECT Readers.FIO AS FIO_reader, 
	   Readers.Address AS Address_reader, 
	   Books.Name AS Name_book, 
	   Books.Author AS Author_book, 
	   Delivery.date_delivery AS date_delivery, 
	   Delivery.date_return AS date_return
FROM   Books 
		JOIN
       Delivery ON Books.id_book = Delivery.id_book 
		JOIN
       Readers ON Delivery.id_reader = Readers.id_reader
GO

------------------------------------------------------ТРИГГЕРЫ------------------------------------------------------------------------------------------------------------------
-- Триггер вставка/обновление
CREATE TRIGGER UpsertTrigger
   ON  ViewDelivery
   INSTEAD OF INSERT, UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN
		-- Вставка в таблицу читателей
		MERGE INTO Readers AS T
		USING 
		(
			SELECT ins.FIO_reader, ins.Address_reader FROM inserted ins
		) AS S
		ON T.FIO = S.FIO_reader AND T.[Address] = S.Address_reader

		WHEN NOT MATCHED THEN
			INSERT (FIO, [Address]) 
			VALUES (S.FIO_reader, S.Address_reader);
		
		-- Вставка в таблицу книг
		MERGE INTO Books AS T
		USING 
		(
			SELECT ins.Name_book, ins.Author_book FROM inserted ins
		) AS S
		ON T.Name = S.Name_book AND T.Author = S.Author_book

		WHEN NOT MATCHED THEN
			INSERT (Name, Author) 
			VALUES (S.Name_book, S.Author_book);

		-- Вставка в таблицу выдач  или обновление дат
		MERGE INTO Delivery AS T
		USING 
		(
			SELECT Readers.id_reader, Books.id_book, inserted.date_delivery AS dateD, inserted.date_return AS dateR
			FROM inserted
				  JOIN 
				 Books	  ON inserted.Name_book = Books.Name AND inserted.Author_book = Books.Author
				  JOIN 
				 Readers  ON inserted.FIO_reader = Readers.FIO AND inserted.Address_reader = Readers.[Address]
		) AS S
		ON T.id_reader = S.id_reader AND T.id_book = S.id_book

		WHEN NOT MATCHED THEN
			INSERT (id_reader, id_book, date_delivery, date_return) 
			VALUES (S.id_reader, S.id_book, S.dateD, S.dateR)
		
		WHEN MATCHED THEN
			UPDATE SET T.date_delivery = S.dateD, T.date_return = S.dateR;
	END
END
GO

-- Триггер удаления
CREATE TRIGGER DeleteTrigger
   ON  ViewDelivery
   INSTEAD OF DELETE
AS 
BEGIN
	SET NOCOUNT ON;
	DELETE FROM Delivery 
	WHERE EXISTS 
		  (
			  SELECT *
			  FROM  deleted  
				     JOIN 
				    Books ON deleted.Name_book = Books.Name AND deleted.Author_book = Books.Author
				     JOIN 
			  	    Readers ON deleted.FIO_reader = Readers.FIO AND deleted.Address_reader = Readers.[Address]
			  WHERE  Delivery.id_reader = Readers.id_reader AND Delivery.id_book = Books.id_book
		  )
END
GO

-------------------------------------------------ТЕСТЫ----------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE SHOW 
AS
BEGIN
    SELECT * FROM Books
	SELECT * FROM Readers
	SELECT * FROM Delivery
	SELECT * FROM ViewDelivery
END
GO

-- Вставка одной строки в представление
INSERT INTO ViewDelivery (FIO_reader, Address_reader, Name_book, Author_book, date_delivery, date_return)
VALUES ('Fedya','a1','Tango','Moiseev','12.12.2015','12.12.2016')

-- Вставка нескольких в представление
INSERT INTO ViewDelivery (FIO_reader, Address_reader, Name_book, Author_book, date_delivery, date_return)
VALUES ('Kolya','a2','Mango','Petrov','05.10.2015','25.10.2015'), 
	   ('Petya','a3','Kukushka','Lobnin','05.09.2017','15.11.2017')

--	Вставка уже сушествующей строки
--INSERT INTO ViewDelivery (FIO_reader, Address_reader, Name_book, Author_book, date_delivery, date_return)
--VALUES ('Fedya','a1','Tango','Moiseev','12.12.2015','12.12.2016')

EXECUTE ('SHOW')

SELECT 1

-- Обновление одного поля (Петя продлил книгу)
UPDATE ViewDelivery set date_return = '15.09.2018'
WHERE FIO_reader = 'Petya' AND Address_reader = 'a1'

EXECUTE ('SHOW')

-- Обновление нескольких полей (Коля решил взять книгу снова)
UPDATE ViewDelivery set date_delivery = '15.09.2018',  date_return = '15.09.2019'
WHERE FIO_reader = 'Kolya' AND Address_reader = 'a2'

EXECUTE ('SHOW')

-- Тест на удаление (Удалить записи, где книги были возвращены до текущей даты)
DELETE FROM ViewDelivery WHERE date_return < GETDATE()

EXECUTE ('SHOW')

-- Обновление нескольких строк (Библиотека закрывается! всем кто еще не сдал книги, 4 дня чтобы это сделать)
UPDATE ViewDelivery set date_return = '20.03.2018'

EXECUTE ('SHOW')

-- Тест на удаление одной записи 
DELETE FROM ViewDelivery WHERE FIO_reader = 'Kolya' AND Address_reader = 'a2'

EXECUTE ('SHOW')