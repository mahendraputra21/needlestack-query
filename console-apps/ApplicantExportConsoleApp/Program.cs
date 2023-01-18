using ApplicantExportConsoleApp.Class;
using ApplicantExportConsoleApp.Constants;
using ApplicantExportConsoleApp.Helpers;
using Newtonsoft.Json;
using System.Data.SqlClient;

public class Program
{
    public static void Main()
    {

        var appSettings = JsonConvert.DeserializeObject<AppSettings>(File.ReadAllText(Constants.APP_SETTINGS));
        var connectionString = appSettings?.ConnectionString;

        using (var connection = new SqlConnection(connectionString))
        {
            connection.Open();
            using (var transaction = connection.BeginTransaction())
            {
                try
                {
                    Console.WriteLine("Starting Export Data Applicants....");

                    Console.WriteLine("Processing Please wait....");

                    using (var command = new SqlCommand(Constants.SP_GET_DATA_APPLICANTS, connection, transaction))
                    {
                        command.CommandType = System.Data.CommandType.StoredProcedure;
                        ExportHelper.ProcessExtractingDataApplicants(connection, transaction, command);
                    }

                    transaction.Commit();

                    Console.WriteLine("Done Export Data Applicants....!");

                    Console.ReadKey();
                }
                catch (Exception ex)
                {
                    //SET Log Error Export
                    ExportHelper.SetExportErrorLog(connection, transaction, "EXPORT-APP", DateTime.Now, ex.Message);
                    Console.WriteLine("An error occurred: " + ex.Message);
                    transaction.Rollback();
                    throw;
                }
            }
        }

    }

    

}
