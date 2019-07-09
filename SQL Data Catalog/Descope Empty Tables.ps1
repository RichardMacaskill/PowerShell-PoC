$authToken = "NTM2OTUxMTYyNzA4OTUxMDQwOmRiNjIyYWMxLWI1NDYtNDQzNi04OTE2LWQ1MzkxNGIzYzI5MQ=="
$instanceName = 'rm-iclone3.testnet.red-gate.com'
$databaseName = 'AW Clone 2'

Invoke-WebRequest -Uri 'https://rm-win10-sql201.testnet.red-gate.com:15156/powershell' -OutFile 'data-catalog.psm1' -Headers @{"Authorization"="Bearer $authToken"}
 
Import-Module .\data-catalog.psm1 -Force

# connect to your SQL Data Catalog instance - you'll need to generate an auth token in the UI
Use-Classification -ClassificationAuthToken $authToken 

# get all columns into a collection
$allColumns = Get-Columns -instanceName $instanceName -databaseName $databaseName 


"Columns returned: "+  $allColumns.Count 

$emptyTableColumns = $allColumns | Where-Object {$_.tableRowCount -eq 0 } 
 
$emptyTableColumns | Update-ColumnTags -category "Sensitivity" -tags "Public"
$emptyTableColumns | Update-ColumnTags -category "Information Type" -tags "Other"
$emptyTableColumns | Update-ColumnTags -category "Classification Scope" -tags "Out of Scope - Unused"
