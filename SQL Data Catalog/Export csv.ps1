$authToken = "NjcyMDAzMjY4MDIwMjczMTUyOjBhNWI0YzI3LWEzOGEtNDhmMC05ZTUwLTQ2YzgwMTI4OTViNg=="

Invoke-WebRequest -Uri 'http://rm-win10-sql201.testnet.red-gate.com:15156/powershell' -OutFile 'data-catalog.psm1' -Headers @{"Authorization"="Bearer $authToken"}
 
Import-Module .\data-catalog.psm1 -Force

# connect to your SQL Data Catalog instance - you'll need to generate an auth token in the UI
Connect-SqlDataCatalog -ServerUrl 'http://rm-win10-sql201.testnet.red-gate.com:15156' -AuthToken $authToken 


$instanceName = 'rm-iclone1.testnet.red-gate.com'
$databaseName = 'StackOverflow2010'

# the native Catalog version is too verbose, use custom
# Export-Classification -InstanceName $instanceName -DatabaseName $databaseName -ExportFile '~\Dev\Temp\myfile.csv' -Format 'csv'

Get-ClassificationColumn -InstanceName $instanceName -DatabaseName $databaseName  | `
Select-Object schemaName, tableName, columnName, sensitivityLabel | `
Export-Csv -Path '~\Dev\Temp\myfile2.csv'