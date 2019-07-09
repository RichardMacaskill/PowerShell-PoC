$authToken = "NTM2OTUxMTYyNzA4OTUxMDQwOmRiNjIyYWMxLWI1NDYtNDQzNi04OTE2LWQ1MzkxNGIzYzI5MQ=="
$instanceName = 'rm-iclone3.testnet.red-gate.com'
$databaseName = 'AW Clone 2'

Invoke-WebRequest -Uri 'https://rm-win10-sql201.testnet.red-gate.com:15156/powershell' -OutFile 'data-catalog.psm1' -Headers @{"Authorization"="Bearer $authToken"}
 
Import-Module .\data-catalog.psm1 -Force

# connect to your SQL Data Catalog instance - you'll need to generate an auth token in the UI
Use-Classification -ClassificationAuthToken $authToken 

# get all columns into a collection
$allColumns = Get-Columns -instanceName $instanceName -databaseName $databaseName 

$allEmptyTables = $allColumns | Where-Object {
    $_.tableRowCount -eq 0}
"All empty tables " + $allEmptyTables.Count
 
 $emptyTables = $allEmptyTables | Where-Object {
        $_.tableRowCount -eq 0 -and
        $_.sensitivityLabel -eq "TBD Review" -and 
        $_.informationType -eq "Other"  -and
        $_.tags.name -eq "Test"
        }
"Test tables " + $emptyTables.Count