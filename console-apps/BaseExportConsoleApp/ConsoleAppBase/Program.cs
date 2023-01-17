using System.Diagnostics;

class Program
{
    static void Main(string[] args)
    {
        Console.WriteLine("Welcome to Needlestack Data CV/Stored Document Extraction...");

        while (true)
        {
            Console.WriteLine("1. Export File Applicants");
            Console.WriteLine("2. Export File Clients");
            Console.WriteLine("3. Exit");

            Console.Write("choose your choice: ");
            var input = Console.ReadLine();

            if (input == "1")
            {
                // Run the Applicant Console App
                Console.WriteLine("Run Export File Applicants...");
                Process.Start("E:\\project\\needlestack\\needlestack-query\\console-apps\\ApplicantExportConsoleApp\\bin\\Debug\\net7.0\\ApplicantExportConsoleApp.exe");
            }
            else if (input == "2")
            {
                // Code to run the Client Console App
                Console.WriteLine("Run Export File Clients...");
                Process.Start("E:\\project\\needlestack\\needlestack-query\\console-apps\\ClientExportConsoleApp\\ClientExportConsoleApp\\bin\\Debug\\net7.0\\ClientExportConsoleApp.exe");
            }
            else if (input == "3")
            {
                // Exit the program
                break;
            }
            else
            {
                Console.WriteLine("Invalid input. Please enter a valid option.");
            }
        }
    }
}
