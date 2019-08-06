
# Get SQL Data Catalog modules
Invoke-WebRequest -Uri 'https://rm-win10-sql201.testnet.red-gate.com:15156/powershell' -OutFile 'data-catalog.psm1' -Headers @{"Authorization"="Bearer NTM2OTUxMTYyNzA4OTUxMDQwOmRiNjIyYWMxLWI1NDYtNDQzNi04OTE2LWQ1MzkxNGIzYzI5MQ=="}
Import-Module .\data-catalog.psm1 -Force

# Get SQL Monitor modules
Import-Module .\RedgateSQM.psm1 -force

Initialize -AuthToken "MToyZmVjMTcyNS1lNDRmLTRlNGMtOWM5YS1mNDMyMmZjMzhmZDI= "

$monitoredMachines = Get-Machines
foreach ($machine in $monitoredMachines)
{       
    Write-Output $machine.Name

    Add-RegisteredSqlServerInstance -FullyQualifiedInstanceName  $machine.Name;
}

