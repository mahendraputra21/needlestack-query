--USING BATCHING
CREATE OR ALTER PROCEDURE needlestack.SP_ExportDataApplicants
    @startId INT,
    @endId INT
AS
BEGIN
    DECLARE @i INT
    DECLARE @ApplicantId INT
    DECLARE @SourceType NVARCHAR(2)
    DECLARE @TemplateTypeId INT
    DECLARE @FileId INT
    DECLARE @folder_path VARCHAR(100)
    DECLARE @FileName NVARCHAR(200)
    DECLARE @FileExtension NVARCHAR(10)
    DECLARE @fPath NVARCHAR(MAX)
    DECLARE @init INT
    DECLARE @FileContent VARBINARY(MAX)
  
    BEGIN TRY
        BEGIN TRAN
            -- SELECT the rows based on the range defined by the @startId and @endId parameters
            SELECT 
                @i = ROW_NUMBER() OVER (ORDER BY Id),
                @ApplicantId = ApplicantId,
                @SourceType = SourceType,
                @TemplateTypeId = TemplateTypeId,
                @folder_path = FolderPath,
                @FileId = FileId,
                @FileName = [FileName],
                @FileExtension = FileExtension,
                @fPath = FolderPath + '\' + [FileName] + FileExtension,
                @FileContent = FileContent
            FROM needlestack.V_ApplicantDataSource
            WHERE Id BETWEEN @startId AND @endId

            -- Iterate through the selected rows
            WHILE @i <= @endId - @startId + 1
            BEGIN
                --CREATE Applicant folder structure
                EXEC master..Xp_create_subdir @folder_path
                PRINT 'Folder Generated at - '+ @folder_path

                --Extracting CV and templates Applicants
                EXEC sp_OACreate 'ADODB.Stream', @init OUTPUT; -- An instance created
                EXEC sp_OASetProperty @init, 'Type', 1;
                EXEC sp_OAMethod @init, 'Open'; -- Calling a method
                EXEC sp_OAMethod @init, 'Write', NULL, @FileContent; -- Calling a method
                EXEC sp_OAMethod @init, 'SaveToFile', NULL, @fPath, 2; -- Calling a method
                EXEC sp_OAMethod @init, 'Close'; -- Calling a method
                EXEC sp_OADestroy @init; -- Closed the resources

                print 'Document Generated at - '+  @fPath

            --INSERT to Table Export Applicant Log
            INSERT INTO needlestack.Export_Applicant_Data_Logs (LogDate, TemplateTypeId ,ApplicantId, SourceType, FileId, FolderPath, [FileName], FileExtension)
            VALUES (GETDATE(), @TemplateTypeId ,@ApplicantId, @SourceType ,@FileId, @folder_path, @FileName, @FileExtension)

            SET @i += 1
        END 
    COMMIT TRAN
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE()
    DECLARE @LogDateTime DATETIME = GETDATE()
    DECLARE @LogType NVARCHAR(15) = 'SP_ExportDataApplicants'

    IF @@TRANCOUNT > 0
        ROLLBACK TRAN

    --INSERT to Table Export Error Log
    INSERT INTO Needlestack.Export_Error_Logs (LogType, LogDate, ErrorMessage) 
    VALUES (@LogType, @LogDateTime, @ErrorMessage)

    RAISERROR('Error occurred during transaction', 16, 1)
END CATCH



