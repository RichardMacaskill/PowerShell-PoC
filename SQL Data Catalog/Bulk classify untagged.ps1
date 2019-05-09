$authToken = "NTM2OTUxMTYyNzA4OTUxMDQwOmRiNjIyYWMxLWI1NDYtNDQzNi04OTE2LWQ1MzkxNGIzYzI5MQ=="
$instanceName = "rm-iclone1.testnet.red-gate.com"
$databaseName = "StackOverflow2010"

# Get the modules. Extra cost, but keeps versions current
Invoke-WebRequest -Uri 'http://sql-data-catalog.testnet.red-gate.com:15156/powershell' `
 -OutFile 'data-catalog.psm1' -Headers @{"Authorization"="Bearer $authToken"}
 
Import-Module .\data-catalog.psm1

# connect to your SQL Data Catalog instance - you'll need to generate an auth token in the UI
Use-Classification -ClassificationAuthToken $authToken 

# get all columns into a collection
$allColumns = Get-Columns -instanceName $instanceName -databaseName $databaseName 

$untaggedColumns = $allColumns | Where-Object {! $_.tags }

$allColumns.Count

$categories = @{
    "Sensitivity" =  @("Public")
    "Classification Scope" = @("In-scope")
    "Owner" = @("CTO")
  }
  Import-ColumnsTags -columns $untaggedColumns -categories $categories

  $allColumns | Format-Table
