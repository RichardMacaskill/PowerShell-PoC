#config
$dataCatalogServer = "http://rm-win10-sql201.testnet.red-gate.com:15156"
$dataCatalogAuthToken = "NTM2OTUxMTYyNzA4OTUxMDQwOmRiNjIyYWMxLWI1NDYtNDQzNi04OTE2LWQ1MzkxNGIzYzI5MQ=="

#retrieve modules from data catalog api
Invoke-WebRequest -Uri "$dataCatalogServer/powershell" -OutFile "datacatalog.psm1" -Headers @{"Authorization" = "Bearer $dataCatalogAuthToken" }
 
#import data catalog modules
Import-Module .\datacatalog.psm1 -Force

$instanceName = 'rm-iclone1.testnet.red-gate.com'
$databaseName = 'StackOverflow2010'

# connect to your SQL Data Catalog instance - you'll need to generate an auth token in the UI
Use-Classification -ClassificationAuthToken $dataCatalogAuthToken -ServerUrl $dataCatalogServer

# get all columns into a collection
$allColumns = Get-Columns -instanceName $instanceName -databaseName $databaseName 

#$allColumns | Format-Table

"{0} columns returned." -f  $allColumns.Count 

$emptyTableColumns = $allColumns | Where-Object {$_.tableRowCount -eq 0 } 

"There are {0} empty tables" -f $emptyTableColumns.Count