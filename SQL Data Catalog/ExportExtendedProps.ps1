$authToken = "NTM2OTUxMTYyNzA4OTUxMDQwOmRiNjIyYWMxLWI1NDYtNDQzNi04OTE2LWQ1MzkxNGIzYzI5MQ=="

Invoke-WebRequest -Uri 'http://rm-win10-sql201.testnet.red-gate.com:15156/powershell' `
    -OutFile 'data-catalog.psm1' -Headers @{"Authorization" = "Bearer $authToken" }
 
Import-Module .\data-catalog.psm1 -Force

$instanceName = "rm-iclone3.testnet.red-gate.com"
$databaseName = "AW Clone 2"

# connect to your SQL Data Catalog instance - you'll need to generate an auth token in the UI
Use-Classification  -ClassificationAuthToken $authToken 

Export-ClassificationExtendedProperties -instanceName $instanceName -databaseName $databaseName -userName 'sa' -password 'Berlin99' -forceUpdate