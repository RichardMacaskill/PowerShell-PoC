$authToken = "NTM2OTUxMTYyNzA4OTUxMDQwOmRiNjIyYWMxLWI1NDYtNDQzNi04OTE2LWQ1MzkxNGIzYzI5MQ=="
$serverUrl = "http://rm-win10-sql201.testnet.red-gate.com:15156"
 
# Get the modules. Extra cost, but keeps versions current
Invoke-WebRequest -Uri "$serverURL/powershell" -OutFile 'data-catalog.psm1' -Headers @{"Authorization" = "Bearer $authToken" }
 
Import-Module .\data-catalog.psm1 -Force
 
# connect to your SQL Data Catalog instance - you'll need to generate an auth token in the UI
Connect-SqlDataCatalog -ClassificationAuthToken $authToken -ServerUrl $serverURL

$instanceName = 'rm-iclone1.testnet.red-gate.com'
$databaseName = 'StackOverflow2010'

# get all columns into a collection
$allColumns = Get-ClassificationColumn -instanceName $instanceName -databaseName $databaseName 

#$allColumns | Format-Table

"{0} columns returned." -f $allColumns.Count 

$emptyTableColumns = $allColumns | Where-Object { $_.tableRowCount -eq 0 } 

"There are {0} empty tables" -f $emptyTableColumns.Count