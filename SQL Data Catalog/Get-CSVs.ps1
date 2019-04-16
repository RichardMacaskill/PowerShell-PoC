Invoke-WebRequest -Uri 'http://sql-data-catalog.testnet.red-gate.com:15156/powershell' -OutFile 'data-catalog.psm1' -Headers @{"Authorization" = "Bearer NTM2OTUxMTYyNzA4OTUxMDQwOmRiNjIyYWMxLWI1NDYtNDQzNi04OTE2LWQ1MzkxNGIzYzI5MQ=="}
 
Import-Module .\data-catalog.psm1 

$instanceName = "rm-iclone3.testnet.red-gate.com"
$databaseNames = @("AW 2012 Clone", "StackOverflow2010", "Forex")

$authToken = "NTM2OTUxMTYyNzA4OTUxMDQwOmRiNjIyYWMxLWI1NDYtNDQzNi04OTE2LWQ1MzkxNGIzYzI5MQ=="

#$filePath = "c:\temp\Catalog Reports\"

$filePath = "~\Dev\Data Catalog Reports\"

# connect to your SQL Data Catalog instance - you'll need to generate an auth token in the UI
Use-Classification -ClassificationAuthToken $authToken 


$databaseNames | ForEach-Object {
    $fileName = $filePath + $_ + ".csv"
    Export-ClassificationCsv -instanceName $instanceName -databaseName $_ -exportFile $fileName
}
