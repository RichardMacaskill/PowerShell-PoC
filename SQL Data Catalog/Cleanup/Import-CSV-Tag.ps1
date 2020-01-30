Clear-Host
# dot source the classification functions (change to where you saved the script)

. "C:\Dev\Git\PowerShell-PoC\SQL Data Catalog\ClassifyColumn.ps1"
. "C:\Dev\Git\PowerShell-PoC\Utils\PowerShell\Join-Object.ps1"
#. "/Users/cas/Dev/PowerShell-PoC/PowerShell-PoC/SQL Data Catalog/ClassifyColumn.ps1"


$catalogServerName = "rm-win10-sql201.testnet.red-gate.com"
$instanceName = "rm-iclone1.testnet.red-gate.com"
$databaseName = "AW 2012 Clone"
$authToken = "NTM2OTUxMTYyNzA4OTUxMDQwOmRiNjIyYWMxLWI1NDYtNDQzNi04OTE2LWQ1MzkxNGIzYzI5MQ=="

$csvPath = "C:\Users\richard.macaskill\Documents\CSV\GC_Classification_01.csv"

# Get the data from the .csv file
$importedData = import-csv $csvPath |  `
                Select-Object Schema, Table, Column, "Information Type", "Sensitivity Label"

# Copy-down gaps in schema values. 
for ($i=0;$i -lt $importedData.Count;$i++)
{
    if (-not $importedData[$i].Schema)
    {
        $importedData[$i].Schema = $importedData[$i-1].Schema
    }   
}

# connect to your SQL Data Catalog instance - you'll need to generate an auth token in the UI
Use-Classification -ClassificationServer $catalogServerName -ClassificationAuthToken $authToken 

# get all columns into a collection
$allColumns = Get-Columns -instanceName $instanceName -databaseName $databaseName 

<# $joinParams = @{
    Left                =   $allColumns 
    Right               =   $importedData 
    LeftJoinProperty    =   'schemaName' + 'tableName' + 'columnName' 
    RightJoinProperty   =   'Schema' + 'Table' + 'Column' 
    Type                =   'OnlyIfInBoth'    
    Prefix              =   'InBoth_'
}

Join-Object @joinParams
 #>
