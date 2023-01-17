USE [McArthur_RDBProNet]
GO

/****** Object:  StoredProcedure [NeedleStack].[SP_GetDataApplicants]    Script Date: 1/17/2023 4:04:16 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [NeedleStack].[SP_GetDataApplicants]
AS
SELECT
a.ApplicantId,
a.SourceType,
a.TemplateTypeId,
a.FolderPath,
a.FileId,
a.[FileName],
a.FileExtension
FROM needlestack.V_ApplicantDataSource a

GO


