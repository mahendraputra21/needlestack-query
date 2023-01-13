------------------------------------------------------------------------------------------------------
----	 STORED DOCUMENT
------------------------------------------------------------------------------------------------------
DECLARE @outPutPath varchar(50) = 'D:\ExtractedFiles2'
, @i bigint
, @init int
, @data varbinary(max)
, @fPath varchar(max)
, @folderPath  varchar(max)

--Get Data into temp Table variable so that we can iterate over it
DECLARE @Doctable TABLE (id int identity(1,1), [FileName]  varchar(100), [Doc_Content] varBinary(max) )

INSERT INTO @Doctable([FileName],[Doc_Content])
Select   
FileExtension,
Document
FROM TemplateDocument 
WHERE TemplateId=1160

--SELECT * FROM @table

SELECT @i = COUNT(1) FROM @Doctable

WHILE @i >= 1
BEGIN

       SELECT
        @data = [Doc_Content],
        @fPath = @outPutPath +  '\' +'File2'+[FileName],
        @folderPath = @outPutPath
       FROM @Doctable WHERE id = @i

  --Create folder first

  EXEC sp_OACreate 'ADODB.Stream', @init OUTPUT; -- An instance created
  EXEC sp_OASetProperty @init, 'Type', 1;
  EXEC sp_OAMethod @init, 'Open'; -- Calling a method
  EXEC sp_OAMethod @init, 'Write', NULL, @data; -- Calling a method
  EXEC sp_OAMethod @init, 'SaveToFile', NULL, @fPath, 2; -- Calling a method
  EXEC sp_OAMethod @init, 'Close'; -- Calling a method
  EXEC sp_OADestroy @init; -- Closed the resources

  print 'Document Generated at - '+  @fPath

--Reset the variables for next use
SELECT @data = NULL
, @init = NULL
, @fPath = NULL
, @folderPath = NULL
SET @i -= 1
END