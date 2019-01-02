
$ServerRootUrl = 'http://rm-win10-sql201.testnet.red-gate.com:15156'
$InstanceName = 'rm-win10-sql201.testnet.red-gate.com' #Read-Host -Prompt 'Please enter the SQL instance for the database to classify.'
$DatabaseName = 'SQLEstateManager' # Read-Host =-Prompt 'Please enter the database name.'

$AuthToken = 'NTE3NjA0OTQ0NjE0Nzg1MDI0Ojc5NzViY2YwLTAyOGUtNGU4My1hZjY4LTJkNWE0ZmI4MmNlMw=='

$AddUrl = "$ServerRootUrl/api/instances"

$Headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$Headers.Add("Authorization", "Bearer $AuthToken")

# clunky lookup - could create a function for this
$Instances = @("")

$Response = Invoke-RestMethod -Uri $AddUrl `
    -Headers $Headers `
    -Method Get `
    -AllowUnencryptedAuthentication

$Instances += $Response.instance

$Instances | ForEach-Object { `
        if ($_.name -eq $InstanceName) {
        $InstanceId = $_.id
    }
}

$TagIDs = @(519200451418128384, 502041990993543168)

$json = $TagIDs  | ConvertTo-Json 
$json = "{""tagIDs"": " + $json + "}"

$ColumnCount = Get-DataCatalogColumnCount -ServerRootUrl $ServerRootUrl  -InstanceId $InstanceId -DatabaseName $DatabaseName -AuthToken $AuthToken

#Have to use a loop to get all the columns from the API due to pagination
for ($i = 0; $i -lt $ColumnCount + 200; $i = $i + 200) { 
 
    $AddUrl = "$ServerRootUrl/api/instances/" + $InstanceId + "/databases/" + $DatabaseName  `
        + "/columns?Value=1&skip=$i&take=200";
    $ColumnsResponse = Invoke-RestMethod -Uri $AddUrl `
        -Headers $Headers `
        -Method Get `
        -AllowUnencryptedAuthentication 


    $ColumnsResponse.classifiedColumns | ForEach-Object { `
            "Setting tags on column {0} on table {1} on schema {2}" -f $_.columnName, $_.tableName, $_.schemaName ; 
    
        $AddUrl = "$ServerRootUrl/api" + `
            "/instances/" + $InstanceId + `
            "/databases/" + $DatabaseName + `
            "/schemas/" + $_.schemaName + `
            "/tables/" + $_.tableName + `
            "/columns/" + $_.columnName + `
            "/tags"
    
        Invoke-RestMethod -Uri $AddUrl `
            -Headers $Headers `
            -Method Put `
            -Body $json `
            -ContentType 'application/json' `
            -AllowUnencryptedAuthentication
    }
}
            



