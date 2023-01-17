-------------------------------------------------------------------------
---- QUERY VIEW DATA SOURCE 
---- APPLICANT AND CLIENT
-------------------------------------------------------------------------
CREATE 
OR ALTER VIEW needlestack.V_ApplicantDataSource AS

	   SELECT  
		ApplicantId, 
		SourceType, 
		FileId, 
		FolderPath, 
		TemplateTypeId, 
		[FileName], 
		FileExtension 
	   FROM 
		(
		  -- GET CV APPLICANTS
		  SELECT 
		    ApplicantId = a.ApplicantId, 
		    SourceType = 'CV', 
		    FileId = a.CVId, 
		    FolderPath = 'D:\ExportFiles\Candidate\' + Cast(a.ApplicantId AS NVARCHAR(10)),
			 TemplateTypeId = NULL,
			 [FileName] = CASE WHEN a.Publish='Y' THEN 'CV' +' '+ p.PersonName + ' ' + p.Surname + ' (Formated)'
				  ELSE 
				    'CV' +' '+ 
				    Cast(a.CVId AS NVARCHAR(10)) +' '+  -- to prevent same file name 
				    + p.PersonName + ' ' + p.Surname   
				  END,
			 b.FileExtension
		  FROM   dbo.cv a
			 LEFT OUTER JOIN dbo.cvcontents b
				ON a.cvid = b.cvid
			 LEFT OUTER JOIN dbo.Person p
				ON p.PersonID = a.ApplicantId
            
		UNION ALL

		   -- GET TEMPLATE APPLICANTS
		   SELECT  
		    ApplicantId = a.ObjectId,
		    SourceType = 'T',
		    FileId = a.TemplateID,
		    FolderPath = 'D:\ExportFiles\Candidate\' + CAST(a.ObjectId AS NVARCHAR(10)),
		    TemplateTypeId = a.TemplateTypeId,
		    [FileName] =   CASE WHEN tt.AbbreviatedText IS NOT NULL THEN  
				  tt.AbbreviatedText + ' ' +
				  CAST(a.TemplateID AS NVARCHAR(10)) +' '+  -- to prevent same file name
				  LEFT(a.TemplateName, LEN(a.TemplateName) - LEN(REVERSE(LEFT(REVERSE(a.TemplateName), CHARINDEX('.', REVERSE(a.TemplateName))))))
				 ELSE
				  CAST(a.TemplateID AS NVARCHAR(10)) +' '+  -- to prevent same file name
				  LEFT(a.TemplateName, LEN(a.TemplateName) - LEN(REVERSE(LEFT(REVERSE(a.TemplateName), CHARINDEX('.', REVERSE(a.TemplateName))))))
				 END,
		    FileExtension = b.FileExtension
		  FROM dbo.Templates a
		    LEFT OUTER JOIN dbo.TemplateDocument b
				ON a.TemplateId = B.TemplateId
		    LEFT OUTER JOIN Needlestack.TemplateTypes tt
				ON tt.TemplateTypeId = a.TemplateTypeId
		    LEFT OUTER JOIN dbo.Objects o
				ON o.ObjectID = a.ObjectId
		    WHERE a.OBJECTID IS NOT NULL
			AND o.ObjectTypeId= (SELECT ObjectTypeId FROM ObjectTypes WHERE SystemCode='APP')
        
		) X
GO

CREATE 
OR ALTER VIEW needlestack.V_ClientDataSource AS

-- GET TEMPLATE ClientId
     SELECT  
      ClientId = a.ObjectId,
      --SourceType = 'T',
      FileId = a.TemplateID,
      FolderPath = 'D:\ExportFiles\Client\' + CAST(a.ObjectId AS NVARCHAR(10)),
      TemplateTypeId = a.TemplateTypeId,
      [FileName] =   CASE WHEN tt.AbbreviatedText IS NOT NULL THEN  
              tt.AbbreviatedText + ' ' +
              CAST(a.TemplateID AS NVARCHAR(10)) +' '+  -- to prevent same file name
              LEFT(a.TemplateName, LEN(a.TemplateName) - LEN(REVERSE(LEFT(REVERSE(a.TemplateName), CHARINDEX('.', REVERSE(a.TemplateName))))))
             ELSE
              CAST(a.TemplateID AS NVARCHAR(10)) +' '+  -- to prevent same file name
              LEFT(a.TemplateName, LEN(a.TemplateName) - LEN(REVERSE(LEFT(REVERSE(a.TemplateName), CHARINDEX('.', REVERSE(a.TemplateName))))))
             END,
      FileExtension = b.FileExtension
    FROM dbo.Templates a
      LEFT OUTER JOIN dbo.TemplateDocument b
            ON a.TemplateId = B.TemplateId
      LEFT OUTER JOIN Needlestack.TemplateTypes tt
            ON tt.TemplateTypeId = a.TemplateTypeId
      LEFT OUTER JOIN dbo.Objects o
            ON o.ObjectID = a.ObjectId
      WHERE a.OBJECTID IS NOT NULL
       AND o.ObjectTypeId= (SELECT ObjectTypeId FROM ObjectTypes WHERE SystemCode='CCT')
