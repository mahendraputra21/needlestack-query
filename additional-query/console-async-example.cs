using System;
using System.Data.SqlClient;
using System.Threading.Tasks;

class Program
{
    static async Task Main()
    {
        // Connection string
        var connectionString = "Server=yourserver;Database=yourdatabase;User Id=yourusername;Password=yourpassword;";

        // Create a new connection
        using (var connection = new SqlConnection(connectionString))
        {
            // Open the connection
            await connection.OpenAsync();

            // Create a new command
            using (var command = new SqlCommand("needlestack.SP_ExportDataApplicants", connection)
            {
                CommandType = System.Data.CommandType.StoredProcedure
            })
            {
                // Execute the command asynchronously
                await command.ExecuteNonQueryAsync();
            }
        }
    }
}
