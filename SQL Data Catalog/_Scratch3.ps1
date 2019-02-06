# dot source the classification functions (change to where you saved the script)
if ($PSVersionTable.OS -like "*Windows*")
{ 
    . "C:\Dev\Git\PowerShell-PoC\SQL Data Catalog\ClassifyColumn.ps1"
}
else {
    . "/Users/richard.macaskill/Dev/Github/PowerShell-PoC/SQL Data Catalog/ClassifyColumn.ps1"   
}
#. "/Users/cas/Dev/PowerShell-PoC/PowerShell-PoC/SQL Data Catalog/ClassifyColumn.ps1"

$catalogServerName = "rm-win10-sql201.testnet.red-gate.com"
$instanceName = "rm-iclone1.testnet.red-gate.com"
$databaseName = "AW 2012 Clone"
$authToken = "NTM2OTUxMTYyNzA4OTUxMDQwOmRiNjIyYWMxLWI1NDYtNDQzNi04OTE2LWQ1MzkxNGIzYzI5MQ=="

# connect to your SQL Data Catalog instance - you'll need to generate an auth token in the UI
Use-Classification -ClassificationServer $catalogServerName -ClassificationAuthToken $authToken 

# get all columns into a collection
$allColumns = Get-Columns -instanceName $instanceName -databaseName $databaseName 