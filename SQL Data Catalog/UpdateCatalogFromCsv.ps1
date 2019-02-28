Clear-Host
# dot source the classification functions (change to where you saved the script)
if ($PSVersionTable.OS -like "*Windows*")
{ 
    . "C:\Dev\Git\PowerShell-PoC\SQL Data Catalog\ClassifyColumn.ps1"
}
else {
    . "/Users/cas/Dev/PowerShell-PoC/PowerShell-PoC/SQL Data Catalog/ClassifyColumn.ps1"   
}


$catalogServerName = "rm-win10-sql201.testnet.red-gate.com"
$instanceName = "rm-iclone1.testnet.red-gate.com"
$databaseName = "AdventureWorks2012"
$authToken = "NTM2OTUxMTYyNzA4OTUxMDQwOmRiNjIyYWMxLWI1NDYtNDQzNi04OTE2LWQ1MzkxNGIzYzI5MQ=="

$csvPath = "C:\Users\richard.macaskill\Documents\CSV\GC_Classification_01.csv"
# connect to your SQL Data Catalog instance - you'll need to generate an auth token in the UI
Use-Classification -ClassificationServer $catalogServerName -ClassificationAuthToken $authToken 

$instances = Get-Instance

$instanceId = $instances[$instanceName]
# Get the data from the .csv file
$importedData = import-csv $csvPath | Select-Object Schema, Table, Column, "Information Type", "Sensitivity Label"

for ($i=0;$i -lt $importedData.Count;$i++)
{
    if (-not $importedData[$i].Schema)
    {
        # Copy-down gaps in schema values. 
        $importedData[$i].Schema = $importedData[$i-1].Schema
    }
    $importedData[$i] | Add-Member -MemberType AliasProperty -Name SchemaName -Value Schema
    $importedData[$i] | Add-Member -MemberType AliasProperty -Name TableName -Value Table
    $importedData[$i] | Add-Member -MemberType AliasProperty -Name ColumnName -Value Column
    $importedData[$i] | Add-Member NoteProperty 'InstanceId' $instanceId
    $importedData[$i] | Add-Member NoteProperty 'DatabaseName' $databaseName
    $importedData[$i] | Update-ColumnTag -category 'Information Type' -tags @($importedData[$i].'Information Type')
    $importedData[$i] | Update-ColumnTag -category 'Sensitivity' -tags @($importedData[$i].'Sensitivity Label')
}
