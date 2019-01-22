# dot source the classification functions (change to where you saved the script)

. "C:\Dev\Git\PowerShell-PoC\SQL Data Catalog\ClassifyColumn.ps1"
#. "/Users/cas/Dev/PowerShell-PoC/PowerShell-PoC/SQL Data Catalog/ClassifyColumn.ps1"

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
            
# apply tags based on groupings
$idColumns | Update-ColumnTag -category "Sensitivity" -tags @("System")

$systemColumns | Update-ColumnTag -category "Sensitivity" -tags @("System")

$geoColumns  | Update-ColumnTag -category "Sensitivity" -tags @("General")
$geoColumns   | Update-ColumnTag -category "Information Type" -tags @("Other")

$emailColumns | Update-ColumnTag -category "Sensitivity" -tags @("Confidential - GDPR")
$emailColumns | Update-ColumnTag -category "Information Type" -tags @("Contact Info")

$commercialColumns |  Update-ColumnTag -category "Sensitivity" -tags @("Highly Confidential")
$commercialColumns | Update-ColumnTag -category "Information Type" -tags @("Other")

$employeeColumns |  Update-ColumnTag -category "Sensitivity" -tags @("Confidential - GDPR")

$salesStaffColumns |  Update-ColumnTag -category "Sensitivity" -tags @("Confidential")

# The rest of it is public information. hit the api again to refresh the list, then set to 'Public'
$untaggedColumns = Get-Columns -instanceName $instanceName -databaseName $databaseName `
| Where-Object {-not $_.sensitivitylabel }

$untaggedColumns  | Update-ColumnTag -category "Sensitivity" -tags @("Public") 
