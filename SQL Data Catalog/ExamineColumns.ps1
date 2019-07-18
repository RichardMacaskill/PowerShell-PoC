Invoke-WebRequest -Uri 'http://rm-win10-sql201.testnet.red-gate.com:15156/powershell' -OutFile 'data-catalog.psm1' -Headers @{"Authorization"="Bearer NTM2OTUxMTYyNzA4OTUxMDQwOmRiNjIyYWMxLWI1NDYtNDQzNi04OTE2LWQ1MzkxNGIzYzI5MQ=="}
 
Import-Module .\data-catalog.psm1 -Force

$instanceName = 'rm-iclone1.testnet.red-gate.com'
$databaseName = 'StackOverflow2010'
$authToken = "NTM2OTUxMTYyNzA4OTUxMDQwOmRiNjIyYWMxLWI1NDYtNDQzNi04OTE2LWQ1MzkxNGIzYzI5MQ=="

# connect to your SQL Data Catalog instance - you'll need to generate an auth token in the UI
Use-Classification -ClassificationAuthToken $authToken 

# get all columns into a collection
Measure-Command -Expression {    $allColumns = Get-Columns -instanceName $instanceName -databaseName $databaseName } | Select-Object Minutes, Seconds, Milliseconds

#$allColumns | Format-Table

"Columns returned: "+  $allColumns.Count #17443

$maskableColumns = $allColumns | Where-Object {$_.tags.name -like "*Masked *" } # 722

$specificMaskableColumns = $maskableColumns | Where-Object {$_.tags.name  -notcontains  "Masked TBD"} #173

$specificMaskableColumns.schemaName | Select-Object -Unique    
<# 
OLAP
Release
Reporting
Staging
Transform 
#>
$specificMaskableColumns.tags.name | Select-string  "Masked" | Select-Object -Unique
<# 
Masked EmailAddress
Masked ForeName
Masked DateOfBirth #>

