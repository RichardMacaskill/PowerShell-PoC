
$ServerRootUrl = 'http://rm-win10-sql201.testnet.red-gate.com:15156'
$InstanceName  = 'rm-iclone1.testnet.red-gate.com' #Read-Host -Prompt 'Please enter the SQL instance for the database to classify.'
$DatabaseName = 'AdventureWorks2012' # Read-Host =-Prompt 'Please enter the database name.'

$AuthToken = 'NTE3NjA0OTQ0NjE0Nzg1MDI0Ojc5NzViY2YwLTAyOGUtNGU4My1hZjY4LTJkNWE0ZmI4MmNlMw=='

$AddUrl = "$ServerRootUrl/api/instances"

$Headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$Headers.Add("Authorization", "Bearer $AuthToken")

$Instances =@("")

$Response = Invoke-RestMethod -Uri $AddUrl `
    -UseDefaultCredentials `
    -Method Get `
    -AllowUnencryptedAuthentication

$Instances += $Response.instance

$InstanceId = {$Instances | Where-Object $_.name -eq $InstanceName  } |  Select-Object -property Id

$Response.ForEach{
    
    Write-Host $_.instance[0].name ;
    $AddUrl = "$ServerRootUrl/api/databases/$DatabaseName/columns";
    $DbResponse = Invoke-RestMethod -Uri $AddUrl `
    -Headers $Headers `
    -Method Get `
    -AllowUnencryptedAuthentication 
    
    $Databases += $DbResponse.database;
            };

$Databases;


Write-Host "Return Status Code: $($Response.StatusCode)"
