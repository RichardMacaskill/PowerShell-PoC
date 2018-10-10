

$ServerRootUrl = 'http://rm-win10-sql201.testnet.red-gate.com:15156'
$AddUrl = "$ServerRootUrl/api/instances"
 
$Response = Invoke-RestMethod -Uri $AddUrl `
    -UseDefaultCredentials `
    -Method Get 
   
$Response.ForEach{
    $InstanceId =  $_.instance[0].id ;
    Write-Host $_.instance[0].name ;
    $AddUrl = "$ServerRootUrl/api/instances/$InstanceId/databases";
    $DbResponse = Invoke-RestMethod -Uri $AddUrl `
    -UseDefaultCredentials `
    -Method Get 
    $DbResponse;
    $databases+= $DbResponse.database[0].name;
            };




Write-Host "Return Status Code: $($Response.StatusCode)"
