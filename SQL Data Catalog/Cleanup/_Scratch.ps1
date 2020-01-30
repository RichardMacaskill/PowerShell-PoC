. "/Users/cas/Dev/PowerShell-PoC/PowerShell-PoC/SQL Data Catalog/ClassifyColumn.ps1"

Use-Classification -ClassificationServer "rm-win10-sql201.testnet.red-gate.com" -ClassificationAuthToken "NTM2OTUxMTYyNzA4OTUxMDQwOmRiNjIyYWMxLWI1NDYtNDQzNi04OTE2LWQ1MzkxNGIzYzI5MQ=="
$allColumns = Get-Columns -instanceName "rm-win10-sql201.testnet.red-gate.com" -databaseName "Redgate_Classification"

$allColumns | Update-ColumnTag -category "Sensitivity" -tags @("System")



$peopleColumns = $allColumns | Where-Object {$_.SchemaName -eq "Application" -and $_.TableName -eq "People" }
$peopleColumns | Update-ColumnTag -category "Sensitivity" -tags @("Confidential - GDPR")
$peopleColumns | Update-ColumnTag -category "Information Type" -tags @("Contact Info")

# initialise
Use-Classification -ClassificationServer "localhost" -ClassificationAuthToken "NTM1MDcwMTc3MjQzNDMwOTEyOjQ0ZjU5MjYyLTUyOTUtNDRhOS1hOWFjLTdhMWJjMWI0NThjNg=="

$allColumns = Get-Columns -instanceName "(local)\MSSQL2017" -databaseName "TestDB_10_01_2019_16_25_41"

$emailColumns  = $allColumns | Where-Object {$_.ColumnName -like "email"}
$emailColumns | Update-ColumnTag -category "Sensitivity" -tags @("Confidential - GDPR")

$allColumns.Count