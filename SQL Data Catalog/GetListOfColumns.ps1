
$ServerRootUrl = 'http://rm-win10-sql201.testnet.red-gate.com:15156'
$InstanceName  = 'rm-iclone1.testnet.red-gate.com' #Read-Host -Prompt 'Please enter the SQL instance for the database to classify.'
$DatabaseName = 'AdventureWorks2012' # Read-Host =-Prompt 'Please enter the database name.'

$AuthToken = 'NTE3NjA0OTQ0NjE0Nzg1MDI0Ojc5NzViY2YwLTAyOGUtNGU4My1hZjY4LTJkNWE0ZmI4MmNlMw=='

$AddUrl = "$ServerRootUrl/api/instances"

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

$AddUrl = "$ServerRootUrl/api/instances/" + $InstanceId + "/databases/" + $DatabaseName  `
    + "/columns?Value=1&skip=0&take=200";
$ColumnsResponse = Invoke-RestMethod -Uri $AddUrl `
-Headers $Headers `
-Method Get `
-AllowUnencryptedAuthentication 

$ColumnsResponse.classifiedColumns | ForEach-Object { `
    "Found column {0} on table {1} on schema {2}" -f $_.columnName, $_.tableName, $_.schemaName ; 
}
            




Write-Host "Return Status Code: $($Response.StatusCode)"
