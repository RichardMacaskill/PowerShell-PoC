function Get-DataCatalogColumnCount 
{ 
    Param(
         [Parameter(Mandatory=$true)] [string] $ServerRootUrl
        ,[Parameter(Mandatory=$true)] [string] $InstanceId
        ,[Parameter(Mandatory=$true)] [string] $DatabaseName
        ,[Parameter(Mandatory=$true)] [string] $AuthToken
    )
    # Lookup the column count for given values
 
    $Headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $Headers.Add("Authorization", "Bearer $AuthToken")

    $AddUrl = "$ServerRootUrl/api" + `
    "/instances/" + $InstanceId + `
    "/databases/" + $DatabaseName 

    Write-Host $AddUrl

    $DatabaseResponse = Invoke-RestMethod -Uri $AddUrl `
    -Headers $Headers `
    -Method Get `
    -AllowUnencryptedAuthentication 

    return $DatabaseResponse.metadata.sensitivityLabelDistribution.value.notClassifiedColumnCount
}

$ServerRootUrl = 'http://rm-win10-sql201.testnet.red-gate.com:15156'
$DatabaseName = 'SQLEstateManager' # Read-Host =-Prompt 'Please enter the database name.'
$InstanceId = 499137865058353152
$AuthToken = 'NTE3NjA0OTQ0NjE0Nzg1MDI0Ojc5NzViY2YwLTAyOGUtNGU4My1hZjY4LTJkNWE0ZmI4MmNlMw=='

Get-DataCatalogColumnCount -ServerRootUrl $ServerRootUrl  -InstanceId $InstanceId -DatabaseName $DatabaseName -AuthToken $AuthToken
