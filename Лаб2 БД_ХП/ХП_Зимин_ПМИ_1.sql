--№1. Создание спец. таблицы.
CREATE TABLE spec 
(
	id int,
	tableName nvarchar(50),
	columnName nvarchar(50),
	curMax int
);

--№2. Добавление в спец. таблицу записи
 INSERT INTO spec (id, tableName, columnName, curMax)
 VALUES (1, 'spec', 'id', 1)

--№3. Создание хранимой процедуры (ХП)
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE IncValue
	@tableName nvarchar(50),
	@columnName nvarchar(50),
	@nextIntNum int OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @specId int 
	SELECT @specId = id 
	FROM spec 
	WHERE tableName = @tableName and columnName = @columnName

	IF (@specId IS NULL)
		BEGIN
			DECLARE @query nvarchar(max)
			SET @query = 'SELECT @maxValue = ( max (' + QUOTENAME(@columnName) + ') + 1 ) 
						  FROM ' + QUOTENAME(@tableName)
			EXECUTE sp_executesql @query, N'@maxValue INT OUTPUT', @maxValue = @nextIntNum OUTPUT
		
			IF (@nextIntNum IS NULL)
				SET @nextIntNum = 1

			DECLARE @nextId int
			EXECUTE IncValue 'spec', 'id', @nextId OUT

			INSERT INTO spec (id, tableName, columnName, curMax) 
			VALUES (@nextId, @tableName, @columnName, @nextIntNum)
		END
	ELSE
		BEGIN
			UPDATE spec SET curMax += 1, @nextIntNum = (curMax + 1) WHERE id = @specId
		END
END
GO

--№4. Вызов ХП с параметрами 'spec', 'id'. Функция должна вернуть `2`.
DECLARE @nextId int
EXECUTE IncValue 'spec', 'id', @nextId OUTPUT
SELECT @nextId AS 'nextID'

--№5. Распечатка содержимого спец. таблицы. Должна быть 1 строка "(1, spec, id, 2)".
SELECT * 
FROM spec

--№6. Вызов ХП с параметрами 'spec', 'id'. Функция должна вернуть `3`
DECLARE @nextId_2 int
EXECUTE IncValue 'spec', 'id', @nextId_2 OUTPUT
SELECT @nextId_2 AS 'nextID'

--№7. Распечатка содержимого спец. таблицы. Должна быть 1 строка "(1, spec, id, 3)".
SELECT * 
FROM spec

--№8. Создание новой таблицы с одним столбцом 'id'. Назовём её test.
CREATE TABLE test
(
	id int
);

--№9.-Добавление в таблицу test записи (10).
INSERT INTO test (id) 
VALUES (10)

--№10. Вызов вашей ХП с параметрами 'test', 'id'. Функция должна вернуть `11`. // место для рекурсии
DECLARE @nextId_3 int
EXECUTE IncValue 'test', 'id', @nextId_3 OUTPUT
SELECT @nextId_3 AS 'nextID'

--№11. Распечатка содержимого спец. таблицы. Должно быть 2 строки "(1, spec, id, 4)" "(4, test, id, 11)".
SELECT * 
FROM spec

--№12. Вызов вашей ХП с параметрами 'test', 'id'. Функция должна вернуть `12`.
DECLARE @nextId_4 int
EXECUTE IncValue 'test', 'id', @nextId_4 OUTPUT
SELECT @nextId_4 AS 'nextID'

--№13. Распечатка содержимого спец. таблицы. Должно быть 2 строки "(1, spec, id, 4)" "(4, test, id, 12)".
SELECT * 
FROM spec

--14. Создание таблицы 'test2' с столбцами 'numValue1', 'numValue2'.
CREATE TABLE test2
(
	numValue1 int,
	numValue2 int
)

--№15. Вызов ХП с параметрами 'test2', 'numValue1'. Функция должна вернуть `1`.
DECLARE @nextId_5 int
EXECUTE IncValue 'test2', 'numValue1', @nextId_5 OUTPUT
SELECT @nextId_5 AS 'nextID'

--№16. Распечатка содержимого спец. таблицы. Должно быть 3 строки "(1, spec, id, 5)" "(4, test, id, 12), (5, test2, numValue1, 1)".
SELECT * 
FROM spec

--№17. Вызов  ХП с параметрами 'test2', 'numValue1'. Функция должна вернуть `2`.
DECLARE @nextId_6 int
EXECUTE IncValue 'test2', 'numValue1', @nextId_6 OUTPUT
SELECT @nextId_6 AS 'nextID'

--№18. Распечатка содержимого спец. таблицы. Должно быть 3 строки "(1, spec, id, 5)" "(4, test, id, 12), (5, test2, numValue1, 2)".
SELECT * 
FROM spec

--№19. Добавление в таблицу 'test2'(numValue1, numValue2) записи (2, 13).
INSERT INTO test2(numValue1, numValue2)
	VALUES (2,13)

--№20. Вызов  ХП с параметрами 'test2', 'numValue2'. Функция должна вернуть `14`.
DECLARE @nextId_7 int
EXECUTE IncValue 'test2', 'numValue2', @nextId_7 OUTPUT
SELECT @nextId_7 AS 'nextID'

--№21. Распечатка содержимого спец. таблицы. Должно быть 4 строки "(1, spec, id, 6)" "(4, test, id, 12), (5, test2, numValue1, 2), (6, test2, numValue2, 14)".
SELECT * 
FROM spec

--№22. Удаление ХП
DROP PROCEDURE IncValue
GO

--№23. Удаление таблиц
DROP TABLE spec
GO

DROP TABLE test
GO

DROP TABLE test2
GO

