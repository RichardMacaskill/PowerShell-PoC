. "/Users/cas/Dev/PowerShell-PoC/PowerShell-PoC/SQL Data Catalog/ClassifyColumn.ps1"


Use-Classification -ClassificationServer "rm-win10-sql201.testnet.red-gate.com" -ClassificationAuthToken "NTM2OTUxMTYyNzA4OTUxMDQwOmRiNjIyYWMxLWI1NDYtNDQzNi04OTE2LWQ1MzkxNGIzYzI5MQ=="

$allColumns = Get-Columns -instanceName "rm-iclone1.testnet.red-gate.com" -databaseName "AdventureWorks2012"

$emailColumns  = $allColumns | Where-Object {$_.ColumnName -like "*email*" } `
| Where-Object {$_.ColumnName -notlike "*id*" }
$emailColumns | Update-ColumnTag -category "Sensitivity" -tags @("Confidential - GDPR")
$emailColumns | Update-ColumnTag -category "Information Type" -tags @("Contact Info")

# Set columns ending in Id to be Sensitivity = 'System'
$idColumns =  $allColumns | Where-Object {$_.ColumnName -like "*id" }

$idColumns | Update-ColumnTag -category "Sensitivity" -tags @("System")