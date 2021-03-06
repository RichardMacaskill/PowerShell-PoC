$authToken = "NTM2OTUxMTYyNzA4OTUxMDQwOmRiNjIyYWMxLWI1NDYtNDQzNi04OTE2LWQ1MzkxNGIzYzI5MQ=="

Invoke-WebRequest -Uri 'http://rm-win10-sql201.testnet.red-gate.com:15156/powershell' -OutFile 'data-catalog.psm1' -Headers @{"Authorization" = "Bearer $authToken" }
 
Import-Module .\data-catalog.psm1 

$instanceName = "rm-iclone3.testnet.red-gate.com"
$databaseName = "AW Clone"

# connect to your SQL Data Catalog instance - you'll need to generate an auth token in the UI
Use-Classification  -ClassificationAuthToken $authToken 

# get all $lumns into a collection
$allColumns = Get-Columns -instanceName $instanceName -databaseName $databaseName 

# create group of columns for email
$emailColumns = $allColumns | Where-Object { $_.ColumnName -like "*email*" } `
| Where-Object { $_.ColumnName -notlike "*id*" }

$emailCategories = @{
    "Sensitivity"      = @("Confidential - GDPR")
    "Information Type" = @("Contact Info")
}
Import-ColumnsTags -columns $emailColumns -categories $emailcategories 


# create group of columns for id columns
$idColumns = $allColumns | Where-Object { $_.ColumnName -like "*id" }

$idCategories = @{
    "Sensitivity"      = @("System")
    "Information Type" = @("Other")
}

Import-ColumnsTags -columns $idColumns -categories $idCategories

# create group of columns for non-sensitive geographic fields
$geoColumns = $allColumns | Where-Object { $_.tableName -like "*Country*" }

$geoCategories = @{
    "Sensitivity"      = @("General")
    "Information Type" = @("Other")
}

Import-ColumnsTags -columns $geoColumns -categories $geoCategories

# create group of columns for system-internal tables and columns
$systemColumns = $allColumns `
| Where-Object { $_.tableName -like "*Build*" `
        -or $_.tableName -like "*Database*" `
        -or $_.tableName -like "*Error*" `
        -or $_.columnName -like "*ModifiedDate*" `
        -or $_.columnName -like "*Flag*" }

$systemCategories = @{
    "Sensitivity"      = @("System")
    "Information Type" = @("Other")
}
            
Import-ColumnsTags -columns $systemColumns -categories $systemCategories
            

# there's some commercially sensitive stuff
$commercialColumns = $allColumns | Where-Object { $_.tableName -like '*Vendor*' }

$commercialCategories = @{
    "Sensitivity" = @("Highly Confidential")
}
            
Import-ColumnsTags -columns $commercialColumns -categories $commercialCategories
            
#sales staff
$salesStaffColumns = $allColumns | Where-Object { $_.tableName -like '*SalesPerson*' }

$salesStaffCategories = @{
    "Sensitivity" = @("Highly Confidential")
}
            
Import-ColumnsTags -columns $salesStaffColumns -categories $salesStaffCategories

# and some information about employees which is sensitive
$employeeColumns = $allColumns | `
    Where-Object { $_.columnName -eq 'Resume' `
        -or $_.columnName -like '*SickLeave*' `
        -or $_.tableName -like '*PayHistory*' `
        -or $_.tableName -eq 'Shift' `
        -or $_.columnName -like '*Marital*' `
        -and $_.columnName -ne 'RateChangeDate' }            
 


$employeeCategories = @{
    "Sensitivity" = @("Confidential - GDPR")
    "Owner"       = @("HR Manager")
}
                    
Import-ColumnsTags -columns $employeeColumns -categories $employeeCategories 
        

# The rest of it is public information. Hit the api again to refresh the list, 
# then set remaining columns to sensitivity = 'Public'

$untaggedColumns = Get-Columns -instanceName $instanceName -databaseName $databaseName `
| Where-Object { -not $_.sensitivitylabel }

$untaggedCategories = @{
    "Sensitivity" = @("Public")
}
            
Import-ColumnsTags -columns $untaggedColumns -categories $untaggedCategories

# 
# I also want to set my Ownership tags (which I've added in my taxonomy)
# This is mostly set by schema. 
#

$hrColumns = $allColumns | Where-Object { $_.schemaName -eq "HumanResources"  `
        -or $_.schemaName -eq "People" }

$hrCategories = @{
    "Owner" = @("HR Manager")
}
                    
Import-ColumnsTags -columns $hrColumns -categories $hrCategories


$salesColumns = $allColumns | Where-Object { $_.schemaName -eq "Sales"  `
        -or $_.schemaName -eq "Purchasing" }

$salesCategories = @{
    "Owner" = @("Finance Manager")
}
                            
Import-ColumnsTags -columns $salesColumns -categories $salesCategories

$prodColumns = $allColumns | Where-Object { $_.schemaName -eq "Production" }

$prodCategories = @{
    "Owner" = @("Operations")
}
                            
Import-ColumnsTags -columns $prodColumns -categories $prodCategories

$itopsCategories = @{
    "Owner" = @("Operations")
}
                            
Import-ColumnsTags -columns $itopsColumns -categories $itopsCategories

$itopsColumns = $allColumns | Where-Object { $_.schemaName -eq "dbo" }


$itopsCategories = @{
    "Owner" = @("Operations")
}
                            
Import-ColumnsTags -columns $itopsColumns -categories $itopsCategories
