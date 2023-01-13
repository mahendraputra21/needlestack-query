@echo off

set "path=D:\NeedleStack-ExportCSV\"

if not exist %path% (
  mkdir %path%
) else (
  echo %path% already exists.
)

cd /d "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn"
sqlcmd -S . -d McArthur_RDBProNet -Q "SELECT * FROM dbo.Objects" -o "D:\NeedleStack-ExportCSV\TableObjects.csv" -h-1 -s","
sqlcmd -S . -d McArthur_RDBProNet -Q "SELECT * FROM dbo.Person" -o "D:\NeedleStack-ExportCSV\TablePerson.csv" -h-1 -s","
sqlcmd -S . -d McArthur_RDBProNet -Q "SELECT * FROM dbo.Clients" -o "D:\NeedleStack-ExportCSV\TableClients.csv" -h-1 -s","
sqlcmd -S . -d McArthur_RDBProNet -Q "SELECT * FROM dbo.ClientContacts" -o "D:\NeedleStack-ExportCSV\TableClientContacts.csv" -h-1 -s","
sqlcmd -S . -d McArthur_RDBProNet -Q "SELECT * FROM dbo.NotebookItems" -o "D:\NeedleStack-ExportCSV\TableNotebookItems.csv" -h-1 -s","
sqlcmd -S . -d McArthur_RDBProNet -Q "SELECT * FROM dbo.NotebookItems" -o "D:\NeedleStack-ExportCSV\TableNotebookItems.csv" -h-1 -s","
sqlcmd -S . -d McArthur_RDBProNet -Q "SELECT * FROM dbo.NotebookItemContent" -o "D:\NeedleStack-ExportCSV\TableNotebookItemContent.csv" -h-1 -s","
sqlcmd -S . -d McArthur_RDBProNet -Q "SELECT * FROM dbo.NotebookLinks" -o "D:\NeedleStack-ExportCSV\TableNotebookLinks.csv" -h-1 -s","
sqlcmd -S . -d McArthur_RDBProNet -Q "SELECT * FROM dbo.NotebookTypes" -o "D:\NeedleStack-ExportCSV\TableNotebookTypes.csv" -h-1 -s","
sqlcmd -S . -d McArthur_RDBProNet -Q "SELECT * FROM dbo.NotebookLinkTypes" -o "D:\NeedleStack-ExportCSV\TableNotebookLinkTypes.csv" -h-1 -s","
sqlcmd -S . -d McArthur_RDBProNet -Q "SELECT * FROM dbo.Users" -o "D:\NeedleStack-ExportCSV\TableUsers.csv" -h-1 -s","
echo Done!
pause
