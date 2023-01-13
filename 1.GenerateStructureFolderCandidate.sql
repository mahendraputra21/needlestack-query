-------------------------------------------------------------------------
---- QUERY FOR GENERATE CANDIDATE STRUCTURE FOLDER
---- BASED ON CV AND TEMPLATES
 -------------------------------------------------------------------------
DECLARE @folder_path_candidate VARCHAR(100) = 'D:\ExportFiles\Candidate\'
DECLARE @folder_path_candidate_list VARCHAR(100)
DECLARE @i BIGINT

IF OBJECT_ID('tempdb..#TEMP_LIST_APPLICANT', 'U') IS NOT NULL
    DROP TABLE #TEMP_LIST_APPLICANT

BEGIN TRY
    BEGIN TRAN
		  --GET LIST APPLICANTID FROM TABLE CV AND Templates
		  SELECT 
		  DISTINCT
		  Row_number()
		  OVER(
		  ORDER BY APPLICANTID) AS Id,
		  APPLICANTID
		  INTO #temp_list_applicant
		  FROM (
				SELECT DISTINCT 
					   a.applicantid AS APPLICANTID
				FROM   dbo.cv (nolock) a
					   INNER JOIN dbo.cvcontents (nolock) b
							 ON a.cvid = b.cvid

				UNION ALL

				SELECT DISTINCT 
					   a.ObjectId AS APPLICANTID
				FROM Templates(nolock) a
					   INNER JOIN TemplateDocument (nolock) b
							 ON a.TemplateId = B.TemplateId
					   WHERE a.OBJECTID IS NOT NULL
		  ) X


		  SELECT @i = Count(1)
		  FROM   #temp_list_applicant

		  WHILE @i >= 1
			 BEGIN
				SET @folder_path_candidate_list = (SELECT
				@folder_path_candidate
				+ Cast(applicantid AS NVARCHAR(5))
											 FROM   #temp_list_applicant
											 WHERE  id = @i)

				--CREATE candidate folder structure
				EXEC master..Xp_create_subdir
				@folder_path_candidate_list

				PRINT 'Folder Generated at - '
				    + @folder_path_candidate_list

				SET @folder_path_candidate_list = ''
				SET @i -= 1
			 END 	    
    COMMIT TRAN
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE()
    DECLARE @DateTime DATETIME = GETDATE()
    DECLARE @LogType NVARCHAR(15) = 'Candidate'
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN
    --INSERT INTO NeedleStack_Migration_Log(LogDateTime, LogType, ErrorMessage) VALUES (@LogType, @DateTime, @ErrorMessage)
    RAISERROR('Error occurred during transaction', 16, 1)
END CATCH

