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

$myServerRootUrl  = http://rm-win10-sql201.testnet.red-gate.com:15156

$ret = Get-DataCatalogColumnCount -ServerRootUrl $myServerRootUrl -InstanceId  $myInstanceId -DatabaseName $myDatabaseName -Authtoken $myAuthToken
