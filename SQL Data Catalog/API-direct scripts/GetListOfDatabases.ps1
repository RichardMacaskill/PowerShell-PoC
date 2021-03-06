

$ServerRootUrl = 'http://rm-win10-sql201.testnet.red-gate.com:15156'
$AuthToken = 'NTE3NjA0OTQ0NjE0Nzg1MDI0Ojc5NzViY2YwLTAyOGUtNGU4My1hZjY4LTJkNWE0ZmI4MmNlMw=='

$AddUrl = "$ServerRootUrl/api/instances"

$Databases=@("");

$Headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$Headers.Add("Authorization", "Bearer $AuthToken")

$Response = Invoke-RestMethod -Uri $AddUrl `
    -UseDefaultCredentials `
    -Method Get `
    -AllowUnencryptedAuthentication
   
$Response.ForEach{
    $InstanceId =  $_.instance[0].id ;
    Write-Host $_.instance[0].name ;
    $AddUrl = "$ServerRootUrl/api/instances/$InstanceId/databases";
    $DbResponse = Invoke-RestMethod -Uri $AddUrl `
    -Headers $Headers `
    -Method Get `
    -AllowUnencryptedAuthentication 
    
    $Databases += $DbResponse.database;
            };

$Databases;


Write-Host "Return Status Code: $($Response.StatusCode)"
