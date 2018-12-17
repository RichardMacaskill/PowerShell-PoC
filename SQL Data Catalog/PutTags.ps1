
$ServerRootUrl = 'http://rm-win10-sql201.testnet.red-gate.com:15156'
$AuthToken = 'NTE3NjA0OTQ0NjE0Nzg1MDI0Ojc5NzViY2YwLTAyOGUtNGU4My1hZjY4LTJkNWE0ZmI4MmNlMw=='

$InstanceId = "499137862709542912"
$DatabaseName = "Forex"
$SchemaName = "dbo"
$TableName = "Currency"
$ColumnName = "HasSubUnits"
$TagIDs = @(519200451418128384,491581451368660992,502041990993543168)

$AddUrl = "$ServerRootUrl/api" + `
        "/instances/" + $InstanceId + `
        "/databases/" + $DatabaseName + `
        "/schemas/" + $SchemaName + `
        "/tables/" + $TableName + `
        "/columns/" + $ColumnName + `
        "/tags"

$Headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$Headers.Add("Authorization", "Bearer $AuthToken")

$json = $TagIDs  | ConvertTo-Json 
$json = "{""tagIDs"": " + $json + "}"


# Get list of instances
$Response = Invoke-RestMethod -Uri $AddUrl `
    -Headers $Headers `
    -Method Put `
    -Body $json `
    -ContentType 'application/json' `
    -AllowUnencryptedAuthentication



    