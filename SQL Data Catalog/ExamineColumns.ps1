Invoke-WebRequest -Uri 'http://sql-data-catalog.testnet.red-gate.com:15156/powershell' -OutFile 'data-catalog.psm1' -Headers @{"Authorization"="Bearer NTM2OTUxMTYyNzA4OTUxMDQwOmRiNjIyYWMxLWI1NDYtNDQzNi04OTE2LWQ1MzkxNGIzYzI5MQ=="}
 
Import-Module .\data-catalog.psm1 -Force

$instanceName = "rm-iclone3.testnet.red-gate.com"
$databaseName = "Masking_SG_OLAP_DATA_20180304"
$authToken = "NTM2OTUxMTYyNzA4OTUxMDQwOmRiNjIyYWMxLWI1NDYtNDQzNi04OTE2LWQ1MzkxNGIzYzI5MQ=="

# connect to your SQL Data Catalog instance - you'll need to generate an auth token in the UI
Use-Classification -ClassificationAuthToken $authToken 

# get all columns into a collection
Measure-Command -Expression {    $allColumns = Get-Columns -instanceName $instanceName -databaseName $databaseName } | Select-Object Minutes, Seconds, Milliseconds

#$allColumns | Format-Table

"Columns returned: "+  $allColumns.Count
<# 
$columnsOnEmptyTables = $allColumns | Where-Object {$_.tableRowCount -eq 0}
#Import-ColumnsCategories -columns $allUnTaggedColumns -categories $allUnTaggedCategories
$allUnTaggedCategories = @{
    "Sensitivity" = @("General")
    "Information Type" = @("Other")
    }
    
Import-ColumnsCategories -columns $columnsOnEmptyTables -categories $allUnTaggedCategories #>

$columnsToMask = $allColumns | Where-Object ($_.tags{})