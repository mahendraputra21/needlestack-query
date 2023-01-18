using System.Data.SqlClient;

class Program
{

    //private static byte[] GetFileContentCV(int fileId, SqlConnection connection, SqlTransaction transaction)
    //{
    //    byte[]? fileContent = null;
    //    using (var command = new SqlCommand("SELECT CV FROM dbo.CVContents WHERE CVId = @fileId", connection, transaction))
    //    {
    //        command.Parameters.AddWithValue("@fileId", fileId);
    //        using (var reader = command.ExecuteReader())
    //        {
    //            if (reader.Read())
    //            {
    //                if (!reader.IsDBNull(0))
    //                {
    //                    fileContent = (byte[])reader.GetValue(0);
    //                }
    //                else
    //                {
    //                    fileContent = null;
    //                }
    //            }
    //            else
    //            {
    //                fileContent = null;
    //            }
    //        }
    //    }
    //    return fileContent;
    //}
    private static byte[] GetFileContentTemplates(int fileId, SqlConnection connection, SqlTransaction transaction)
    {
        byte[] fileContent;
        using (var command = new SqlCommand("SELECT Document FROM dbo.TemplateDocument WHERE TemplateId = @fileId AND Document IS NOT NULL", connection, transaction))
        {
            command.Parameters.AddWithValue("@fileId", fileId);
            using (var reader = command.ExecuteReader())
            {
                if (reader.Read())
                {
                    if (!reader.IsDBNull(0))
                    {
                        fileContent = (byte[])reader.GetValue(0);
                    }
                    else
                    {
                        fileContent = null;
                    }
                }
                else
                {
                    fileContent = null;
                }
            }
        }

        return fileContent;
    }

    static void Main(string[] args)
    {
        //var connectionString = "Server=.;Database=McArthur_RDBProNet;User Id=sa;Password=geekseat!;MultipleActiveResultSets=true;";
        var connectionString = "Server=.;Database=RecruitmentInvestmentsLimitedDemo_IPR;User Id=sa;Password=geekseat!;MultipleActiveResultSets=true;";
        using (var connection = new SqlConnection(connectionString))
        {
            connection.Open();
            using (var transaction = connection.BeginTransaction())
            {
                try
                {
                    Console.WriteLine("Starting Export Data Clients....");

                    Console.WriteLine("Processing Please wait....");

                    using (var command = new SqlCommand("Needlestack.SP_GetDataClients", connection, transaction))
                    {
                        command.CommandType = System.Data.CommandType.StoredProcedure;

                        using (var reader = command.ExecuteReader())
                        {

                            while (reader.Read())
                            {
                                var applicantId = reader.GetInt32(0);
                                var templateTypeId = reader.IsDBNull(1) ? 0 : reader.GetInt32(1);
                                var folderPath = reader?.GetString(2);
                                var fileId = reader?.GetInt32(3);
                                var fileName = reader?.GetString(4);
                                var fileExtension = reader?.GetString(5);
                                var fileContent = GetFileContentTemplates((int)fileId, connection, transaction);

                                // Create folder if it does not exist
                                Directory.CreateDirectory(folderPath);

                                Console.WriteLine("File ID - " + fileId.ToString());
                                Console.WriteLine("Folder Generated at - " + folderPath);

                                // Construct file path
                                var filePath = Path.Combine(folderPath + "\\", fileName.Replace("/", " ") + fileExtension);

                                // Write file to disk
                                using (var fileStream = new FileStream(filePath, FileMode.Create))

                                    if (fileContent != null)
                                    {
                                        using (var memoryStream = new MemoryStream(fileContent))
                                        {
                                            memoryStream.CopyTo(fileStream);
                                        }
                                    }

                                Console.WriteLine("Document Generated at - " + filePath);

                                //reader.Close();

                                // Log export in the database
                                using (var logCommand = new SqlCommand("INSERT INTO needlestack.Export_Client_Data_Logs (LogDate, TemplateTypeId, ClientId, FileId, FolderPath, [FileName], FileExtension) " +
                                    "VALUES (GETDATE(), @templateTypeId, @applicantId, @fileId, @folderPath, @fileName, @fileExtension)", connection, transaction))
                                {
                                    logCommand.Parameters.AddWithValue("@templateTypeId", templateTypeId);
                                    logCommand.Parameters.AddWithValue("@applicantId", applicantId);
                                    logCommand.Parameters.AddWithValue("@fileId", fileId);
                                    logCommand.Parameters.AddWithValue("@folderPath", folderPath);
                                    logCommand.Parameters.AddWithValue("@fileName", fileName);
                                    logCommand.Parameters.AddWithValue("@fileExtension", fileExtension);
                                    logCommand.ExecuteNonQuery();
                                }

                            }
                        }
                    }
                    transaction.Commit();

                    Console.WriteLine("Done Export Data Clients....!");
                }
                catch (Exception ex)
                {
                    Console.WriteLine("An error occurred: " + ex.Message);
                    transaction.Rollback();
                    throw;
                }
            }
        }

    }
}
