CREATE FUNCTION dbo.DecryptSagePW(
    @password VARCHAR(150)
)
RETURNS VARCHAR(150)
AS 
BEGIN
DECLARE @cnt INT = 0;
DECLARE @result AS VARCHAR(150);
SET @result = '';
SET @cnt = LEN(@password);
WHILE @cnt > 0
BEGIN
	SET @result = CONCAT(@result, CHAR(ASCII(SUBSTRING(@password, @cnt, 1))  ^ 75 ^ 23));
	SET @cnt = @cnt -1;
END;
RETURN @result;
END;
GO
CREATE TABLE #Results (UserLogin nvarchar(150), UserPassword nvarchar(150));

DECLARE @Login AS NVARCHAR(150);
DECLARE @Password AS NVARCHAR(150);

DECLARE CUR CURSOR FAST_FORWARD FOR
	SELECT [Login], [Password] FROM SEC_Login_DT
	WHERE IsNTUser = 0 AND [Password] IS NOT NULL 

OPEN CUR
FETCH NEXT FROM CUR INTO @Login, @Password
 
WHILE @@FETCH_STATUS = 0
BEGIN

	SET @Password = dbo.DecryptSagePW(@Password);
	INSERT INTO #Results  (UserLogin, UserPassword) VALUES (@Login, @Password)
	FETCH NEXT FROM CUR INTO @Login, @Password
END
CLOSE CUR
DEALLOCATE CUR
GO


DROP FUNCTION dbo.DecryptSagePW;
SELECT * FROM #Results;
DROP TABLE #Results;
