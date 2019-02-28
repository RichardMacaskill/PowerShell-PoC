Invoke-WebRequest -Uri 'http://rm-win10-sql201.testnet.red-gate.com:15156/powershell' -OutFile 'data-catalog.psm1' -Headers @{"Authorization"="Bearer NTM2OTUxMTYyNzA4OTUxMDQwOmRiNjIyYWMxLWI1NDYtNDQzNi04OTE2LWQ1MzkxNGIzYzI5MQ=="}
 
Import-Module .\data-catalog.psm1

$instanceName = "rm-iclone1.testnet.red-gate.com"
$databaseName = "AW 2012 Clone"
$authToken = "NTM2OTUxMTYyNzA4OTUxMDQwOmRiNjIyYWMxLWI1NDYtNDQzNi04OTE2LWQ1MzkxNGIzYzI5MQ=="

# connect to your SQL Data Catalog instance - you'll need to generate an auth token in the UI
Use-Classification -ClassificationAuthToken $authToken 

# get all columns into a collection
$allColumns = Get-Columns -instanceName $instanceName -databaseName $databaseName 

$columnsOnEmptyTables = $allColumns | Where-Object {$_.tableRowCount -eq 0}

#Import-ColumnsCategories -columns $allUnTaggedColumns -categories $allUnTaggedCategories
$allUnTaggedCategories = @{
    "Sensitivity" = @("General")
    "Information Type" = @("Other")
    }
    
Import-ColumnsCategories -columns $columnsOnEmptyTables -categories $allUnTaggedCategories