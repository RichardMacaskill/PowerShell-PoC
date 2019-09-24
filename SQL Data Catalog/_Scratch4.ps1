$authToken = "NTM2OTUxMTYyNzA4OTUxMDQwOmRiNjIyYWMxLWI1NDYtNDQzNi04OTE2LWQ1MzkxNGIzYzI5MQ=="
$instanceName = "rm-iclone1.testnet.red-gate.com"
$databaseName = "AW 2012 Clone"

# Get the modules. Extra cost, but keeps versions current
Invoke-WebRequest -Uri 'https://rm-win10-sql201.testnet.red-gate.com:15156/powershell' `
 -OutFile 'data-catalog.psm1' -Headers @{"Authorization"="Bearer $authToken"}
 
Import-Module .\data-catalog.psm1

Use-Classification -ClassificationAuthToken $authToken

Get-RegisteredInstances