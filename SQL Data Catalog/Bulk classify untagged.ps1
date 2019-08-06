$authToken = "NTM2OTUxMTYyNzA4OTUxMDQwOmRiNjIyYWMxLWI1NDYtNDQzNi04OTE2LWQ1MzkxNGIzYzI5MQ=="
$instanceName = "rm-iclone1.testnet.red-gate.com"
$databaseName = "StackOverflow2010"

# Get the modules. Extra cost, but keeps versions current
Invoke-WebRequest -Uri 'https://rm-win10-sql201.testnet.red-gate.com:15156/powershell'  `
-OutFile 'data-catalog.psm1' -Headers @{"Authorization"="Bearer $authToken"}

Import-Module .\data-catalog.psm1

# connect to your SQL Data Catalog instance - you'll need to generate an auth token in the UI
Use-Classification -ClassificationAuthToken $authToken 

# get all columns into a collection
$allColumns = Get-Columns -instanceName $instanceName -databaseName $databaseName 

$outOfScopeColumns = $allColumns | Where-Object { $_.tags.Name -eq "Out of scope - Non PII" }
$outOfScopeColumns.Count
$outOfScopeColumns | Update-ColumnTags -category "Sensitivity" -tags @("Non PII")