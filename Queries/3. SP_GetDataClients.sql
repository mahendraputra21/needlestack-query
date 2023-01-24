CREATE OR ALTER PROCEDURE [Needlestack].[SP_GetDataClients]
AS
SELECT
a.ClientId,
a.TemplateTypeId,
a.FolderPath,
a.FileId,
a.[FileName],
a.FileExtension
FROM needlestack.V_ClientDataSource a