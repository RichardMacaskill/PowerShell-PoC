function Get-CatalogColumns {
    Param ($serverURL, $authToken, $instanceName, $databaseName)
    # Return a collection of all columns for a given database
    $columnsBlob = @()    
    $columnsBlob | Add-Member id $id
    $columnsBlob | Add-Member synchronised false -Force
    $columnsBlob | Add-Member name "$($column.schemaName).$($column.tableName).$($column.columnName)"
    return @{
        mask    = $maskBlob
        columns = @($column)
    }
}


$serverRootUrl = 'http://rm-win10-sql201.testnet.red-gate.com:15156'
$instanceName  = 'rm-iclone1.testnet.red-gate.com' #Read-Host -Prompt 'Please enter the SQL instance for the database to classify.'
$databaseName = 'AdventureWorks2012' # Read-Host =-Prompt 'Please enter the database name.'
$authToken = 'NTE3NjA0OTQ0NjE0Nzg1MDI0Ojc5NzViY2YwLTAyOGUtNGU4My1hZjY4LTJkNWE0ZmI4MmNlMw=='

$AddUrl = "$serverRootUrl/api/instances"

$Headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$Headers.Add("Authorization", "Bearer $AuthToken")

$Instances =@("")

$Response = Invoke-RestMethod -Uri $AddUrl `
    -Headers $Headers `
    -Method Get `
    -AllowUnencryptedAuthentication

$Instances += $Response.instance

$Instances | ForEach-Object { `
    if ($_.name -eq $InstanceName)
    {
       $InstanceId = $_.id
    }
}

$AddUrl = "serverRootUrl/api/instances/" + $InstanceId + "/databases/" + $DatabaseName  `
    + "/columns?Value=1&skip=0&take=200";
$ColumnsResponse = Invoke-RestMethod -Uri $AddUrl `
-Headers $Headers `
-Method Get `
-AllowUnencryptedAuthentication 

$ColumnsResponse.classifiedColumns | ForEach-Object { `
    "Found column {0} on table {1} on schema {2}" -f $_.columnName, $_.tableName, $_.schemaName ; 
}

