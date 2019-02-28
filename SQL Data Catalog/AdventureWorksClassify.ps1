# dot source the classification functions (change to where you saved the script)

#. "C:\Dev\Git\PowerShell-PoC\SQL Data Catalog\ClassifyColumn.ps1"
. "/Users/richard.macaskill/Dev/Github/PowerShell-PoC/SQL Data Catalog/ClassifyColumn.ps1"

$catalogServerName = "rm-win10-sql201.testnet.red-gate.com"
$instanceName = "rm-iclone1.testnet.red-gate.com"
$databaseName = "AW 2012 Clone"
$authToken = "NTM2OTUxMTYyNzA4OTUxMDQwOmRiNjIyYWMxLWI1NDYtNDQzNi04OTE2LWQ1MzkxNGIzYzI5MQ=="

# connect to your SQL Data Catalog instance - you'll need to generate an auth token in the UI
Use-Classification -ClassificationServer $catalogServerName -ClassificationAuthToken $authToken 

# get all columns into a collection
$allColumns = Get-Columns -instanceName $instanceName -databaseName $databaseName 

# create group of columns for email
$emailColumns  = $allColumns | Where-Object {$_.ColumnName -like "*email*" } `
| Where-Object {$_.ColumnName -notlike "*id*" }

# create group of columns for id columns
$idColumns =  $allColumns | Where-Object {$_.ColumnName -like "*id" }

# create group of columns for non-sensitive geographic fields
$geoColumns =  $allColumns | Where-Object {$_.tableName -like "*Country*" }

# create group of columns for system-internal tables and columns
$systemColumns =  $allColumns `
| Where-Object {$_.tableName -like "*Build*" `
            -or $_.tableName  -like "*Database*" `
            -or $_.tableName -like "*Error*" `
            -or $_.columnName -like "*ModifiedDate*" `
            -or $_.columnName -like "*Flag*"}

# there's some commercially sensitive stuff
$commercialColumns = $allColumns | Where-Object {$_.tableName -like '*Vendor*'}

#sales staff
$salesStaffColumns = $allColumns | Where-Object {$_.tableName -like '*SalesPerson*'}

# and some information about employees which is sensitive
$employeeColumns = $allColumns | `
    Where-Object { $_.columnName -eq 'Resume' `
            -or $_.columnName -like '*SickLeave*' `
            -or $_.tableName -like '*PayHistory*' `
            -or $_.tableName -eq 'Shift' `
            -or $_.columnName -like '*Marital*' }            
            
#
# Apply tags based on groupings. Tags are not overwritten by this method, 
# so it's best to apply the most sensitive ones first.
#

$employeeColumns |  Update-ColumnTag -category "Sensitivity" -tags @("Confidential - GDPR")

$emailColumns | Update-ColumnTag -category "Sensitivity" -tags @("Confidential - GDPR")
$emailColumns | Update-ColumnTag -category "Information Type" -tags @("Contact Info")

$commercialColumns |  Update-ColumnTag -category "Sensitivity" -tags @("Highly Confidential")

$salesStaffColumns |  Update-ColumnTag -category "Sensitivity" -tags @("Confidential")

$idColumns | Update-ColumnTag -category "Sensitivity" -tags @("System")
$idColumns | Update-ColumnTag -category "Information Type" -tags @("Other")

$geoColumns  | Update-ColumnTag -category "Sensitivity" -tags @("General")
$geoColumns   | Update-ColumnTag -category "Information Type" -tags @("Other")

$systemColumns | Update-ColumnTag -category "Sensitivity" -tags @("System")

# The rest of it is public information. Hit the api again to refresh the list, 
# then set remaining columns to sensitivity = 'Public'

$untaggedColumns = Get-Columns -instanceName $instanceName -databaseName $databaseName `
| Where-Object {-not $_.sensitivitylabel }

$untaggedColumns  | Update-ColumnTag -category "Sensitivity" -tags @("Public") 

# 
# I also want to set my Ownership tags (which I've added in my taxonomy)
# This is mostly set by schema. 
#

# get all columns into a collection
$allColumns = Get-Columns -instanceName $instanceName -databaseName $databaseName 

$hrColumns  = $allColumns | Where-Object {$_.schemaName -eq "HumanResources"  `
 -or $_.schemaName -eq "People"}

$hrColumns  | Update-ColumnTag -category "Owner" -tags @("HR Manager") 

$salesColumns  = $allColumns | Where-Object {$_.schemaName -eq "Sales"  `
 -or $_.schemaName -eq "Purchasing"}

$salesColumns  | Update-ColumnTag -category "Owner" -tags @("Finance Manager") 


$salesColumns  = $allColumns | Where-Object {$_.schemaName -eq "Sales"  `
 -or $_.schemaName -eq "Purchasing"}

$salesColumns  | Update-ColumnTag -category "Owner" -tags @("Finance Manager") 

$prodColumns  = $allColumns | Where-Object {$_.schemaName -eq "Production"}

$prodColumns  | Update-ColumnTag -category "Owner" -tags @("Operations") 

# The dbo schema has deployment and error information, so IT owns those under the CTO.

$itopsColumns  = $allColumns | Where-Object {$_.schemaName -eq "dbo"}

$itopsColumns  | Update-ColumnTag -category "Owner" -tags @("CTO")