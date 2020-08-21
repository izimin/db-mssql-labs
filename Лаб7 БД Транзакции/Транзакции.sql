-----------------------------------------1 часть:
--категория А (атомарность)
SHUTDOWN WITH NOWAIT WorldCups
SELECT * FROM Тип_гонки
BEGIN TRAN 
	BEGIN TRY
		INSERT INTO Тип_гонки VALUES ('Спринт')
		UPDATE Тип_гонки SET [Название_типа _гонки]='Смешанная эстафета' WHERE idТипа_гонки =3
		SELECT * FROM Тип_гонки
	END TRY
	BEGIN CATCH
		DECLARE @errorMessage NVARCHAR(200), @errorSeverity INT
		SELECT @errorMessage = ERROR_MESSAGE(), @errorSeverity = ERROR_SEVERITY()
		RAISERROR (@errorMessage, @errorSeverity, 1)
	END CATCH
ROLLBACK TRAN
SELECT * FROM Тип_гонки

--категория С (согласованность)
SELECT * FROM Тренер
BEGIN TRAN
	BEGIN TRY
		INSERT INTO Тренер(ФИО, Страна, [Стаж(лет)]) VALUES ('ФИО1', 'Россия', 12)
		SELECT * FROM Тренер
		UPDATE Тренер SET [Стаж(лет)] = -1 WHERE [Стаж(лет)] = 5
	END TRY
	BEGIN CATCH 
		ROLLBACK TRAN
	END CATCH
SELECT * FROM Тренер

--категория I (изолированность)
BEGIN TRAN
	INSERT INTO Команда(idКоманды, Название_команды, Страна) VALUES (1000, 'Йоу','Россия')
	SELECT * FROM Команда
	WAITFOR DELAY '00:00:08'
	SELECT * FROM Команда
	INSERT INTO Команда(idКоманды, Название_команды, Страна) VALUES (3000, 'Го','США')
COMMIT TRAN
SELECT * FROM Команда

--категория D (устойчивость)
SELECT * FROM Тренер
BEGIN TRAN
	INSERT INTO Тренер(ФИО, Страна, [Стаж(лет)])
			VALUES ('ФиО', 'Норвегия', 11)
	UPDATE Тренер SET Страна = 'Швеция' WHERE idТренера = 1
COMMIT TRAN
SHUTDOWN WITH NOWAIT
	--после сбоя
SHUTDOWN WITH NOWAIT WorldCups
SELECT * FROM Тренер

------------------------------------------------- 2 и 3 части:
--Грязное чтение**
SELECT * FROM Команда
BEGIN TRAN
	BEGIN TRY
		UPDATE Команда SET Страна = 'Белорусь' WHERE idКоманды = 1 
		INSERT INTO Команда(Название_команды, Страна)
					VALUES ('Monr', 'Финляндия')
		WAITFOR DELAY '00:00:04'
		ROLLBACK TRAN;
	END TRY
	BEGIN CATCH
		DECLARE @errorMessage1 NVARCHAR(200), @errorSeverity1 INT
		SELECT @errorMessage1 = ERROR_MESSAGE(), @errorSeverity1 = ERROR_SEVERITY()
		RAISERROR (@errorMessage1, @errorSeverity1, 1)
	END CATCH
SELECT * FROM Команда

--Неповторяющееся чтение
SELECT * FROM Тренер
-- (3часть) SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
-- (2часть) SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
BEGIN TRAN
	SELECT * FROM Тренер
	WAITFOR DELAY '00:00:04'
	SELECT * FROM  Тренер
COMMIT TRAN;



--Фантомная вставка
-- (3часть) SET TRANSACTION ISOLATION LEVEL SERIALIZABLE 
-- (2часть) SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT * FROM Трасса
BEGIN TRAN
SELECT sum(Длина_трассы) FROM Трасса
WAITFOR DELAY '00:00:04'
SELECT sum(Длина_трассы) FROM Трасса
COMMIT TRAN;
SELECT sum(Длина_трассы) FROM Трасса


--Потерянное обновление
SELECT * FROM Тренер
-- (3 часть) SET TRANSACTION ISOLATION LEVEL SERIALIZABLE	--REPEATABLE READ
-- (2 часть) SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
BEGIN TRAN
	BEGIN TRY
		DECLARE @Value INT;
		SELECT @Value = [Стаж(лет)] FROM Тренер WHERE ФИО = 'МИВ'
		WAITFOR DELAY '00:00:04'
		SELECT * FROM Тренер
		UPDATE Тренер SET [Стаж(лет)] = @Value + 20 WHERE ФИО = 'МИВ'
	--	INSERT INTO Тренер (ФИО, Страна, [стаж(лет)]) 
				--	VALUES ('ABC', 'USA', 5)
		SELECT * FROM Тренер
		COMMIT TRAN;
	END TRY
	BEGIN CATCH
		DECLARE @errorMessage4 NVARCHAR(200), @errorSeverity4 INT
		SELECT @errorMessage4 = ERROR_MESSAGE(), @errorSeverity4 = ERROR_SEVERITY()
		RAISERROR (@errorMessage4, @errorSeverity4, 1)
	END CATCH
SELECT * FROM Тренер
