-----------------------------------------1 �����:
--��������� � (�����������)
SHUTDOWN WITH NOWAIT WorldCups
SELECT * FROM ���_�����
BEGIN TRAN 
	BEGIN TRY
		INSERT INTO ���_����� VALUES ('������')
		UPDATE ���_����� SET [��������_���� _�����]='��������� ��������' WHERE id����_����� =3
		SELECT * FROM ���_�����
	END TRY
	BEGIN CATCH
		DECLARE @errorMessage NVARCHAR(200), @errorSeverity INT
		SELECT @errorMessage = ERROR_MESSAGE(), @errorSeverity = ERROR_SEVERITY()
		RAISERROR (@errorMessage, @errorSeverity, 1)
	END CATCH
ROLLBACK TRAN
SELECT * FROM ���_�����

--��������� � (���������������)
SELECT * FROM ������
BEGIN TRAN
	BEGIN TRY
		INSERT INTO ������(���, ������, [����(���)]) VALUES ('���1', '������', 12)
		SELECT * FROM ������
		UPDATE ������ SET [����(���)] = -1 WHERE [����(���)] = 5
	END TRY
	BEGIN CATCH 
		ROLLBACK TRAN
	END CATCH
SELECT * FROM ������

--��������� I (���������������)
BEGIN TRAN
	INSERT INTO �������(id�������, ��������_�������, ������) VALUES (1000, '���','������')
	SELECT * FROM �������
	WAITFOR DELAY '00:00:08'
	SELECT * FROM �������
	INSERT INTO �������(id�������, ��������_�������, ������) VALUES (3000, '��','���')
COMMIT TRAN
SELECT * FROM �������

--��������� D (������������)
SELECT * FROM ������
BEGIN TRAN
	INSERT INTO ������(���, ������, [����(���)])
			VALUES ('���', '��������', 11)
	UPDATE ������ SET ������ = '������' WHERE id������� = 1
COMMIT TRAN
SHUTDOWN WITH NOWAIT
	--����� ����
SHUTDOWN WITH NOWAIT WorldCups
SELECT * FROM ������

------------------------------------------------- 2 � 3 �����:
--������� ������**
SELECT * FROM �������
BEGIN TRAN
	BEGIN TRY
		UPDATE ������� SET ������ = '��������' WHERE id������� = 1 
		INSERT INTO �������(��������_�������, ������)
					VALUES ('Monr', '���������')
		WAITFOR DELAY '00:00:04'
		ROLLBACK TRAN;
	END TRY
	BEGIN CATCH
		DECLARE @errorMessage1 NVARCHAR(200), @errorSeverity1 INT
		SELECT @errorMessage1 = ERROR_MESSAGE(), @errorSeverity1 = ERROR_SEVERITY()
		RAISERROR (@errorMessage1, @errorSeverity1, 1)
	END CATCH
SELECT * FROM �������

--��������������� ������
SELECT * FROM ������
-- (3�����) SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
-- (2�����) SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
BEGIN TRAN
	SELECT * FROM ������
	WAITFOR DELAY '00:00:04'
	SELECT * FROM  ������
COMMIT TRAN;



--��������� �������
-- (3�����) SET TRANSACTION ISOLATION LEVEL SERIALIZABLE 
-- (2�����) SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT * FROM ������
BEGIN TRAN
SELECT sum(�����_������) FROM ������
WAITFOR DELAY '00:00:04'
SELECT sum(�����_������) FROM ������
COMMIT TRAN;
SELECT sum(�����_������) FROM ������


--���������� ����������
SELECT * FROM ������
-- (3 �����) SET TRANSACTION ISOLATION LEVEL SERIALIZABLE	--REPEATABLE READ
-- (2 �����) SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
BEGIN TRAN
	BEGIN TRY
		DECLARE @Value INT;
		SELECT @Value = [����(���)] FROM ������ WHERE ��� = '���'
		WAITFOR DELAY '00:00:04'
		SELECT * FROM ������
		UPDATE ������ SET [����(���)] = @Value + 20 WHERE ��� = '���'
	--	INSERT INTO ������ (���, ������, [����(���)]) 
				--	VALUES ('ABC', 'USA', 5)
		SELECT * FROM ������
		COMMIT TRAN;
	END TRY
	BEGIN CATCH
		DECLARE @errorMessage4 NVARCHAR(200), @errorSeverity4 INT
		SELECT @errorMessage4 = ERROR_MESSAGE(), @errorSeverity4 = ERROR_SEVERITY()
		RAISERROR (@errorMessage4, @errorSeverity4, 1)
	END CATCH
SELECT * FROM ������
