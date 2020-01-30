$authToken = "NTM2OTUxMTYyNzA4OTUxMDQwOmRiNjIyYWMxLWI1NDYtNDQzNi04OTE2LWQ1MzkxNGIzYzI5MQ=="
$instanceName = "rm-iclone1.testnet.red-gate.com"
$databaseName = "AW 2012 Clone"

# Get the modules. Extra cost, but keeps versions current
Invoke-WebRequest -Uri 'http://rm-win10-sql201.testnet.red-gate.com:15156/powershell' `
 -OutFile 'data-catalog.psm1' -Headers @{"Authorization"="Bearer $authToken"}
 
Import-Module .\data-catalog.psm1


function discoverHosts() {
    $output = ''
    if($mode -eq "local") {
        $output = Find-DbaInstance -ComputerName $env:computername | Select ComputerName,InstanceName
    } else {
        $output = Find-DbaInstance -DiscoveryType Domain | Select ComputerName,InstanceName
    }
    
    foreach ($line in $output) {
        if ($line.InstanceName.ToLower() -eq "mssqlserver" -Or $line.InstanceName.ToLower() -eq "default") {
            $foundInstanceFqdn = $line.ComputerName
        } else {
            $foundInstanceFqdn = ($line.ComputerName + "\" + $line.InstanceName).ToLower()
        }
        Write-Host "Adding instance:" $foundInstanceFqdn
        RegisteredSqlServerInstance($foundInstanceFqdn)
    }
}

if (-Not (Get-Module -ListAvailable -Name dbatools)) {
    Install-Module dbatools
}
if ($mode -eq "singleHost") {
    if (!$instanceFqdn) {
        $instanceFqdn = Read-Host -Prompt 'Input server connection string'
    }
    RegisteredSqlServerInstance($instanceFqdn)
} elseif ($mode -eq "domain" -Or $mode -eq "local") {
    discoverHosts
} else {
    Get-Help $MyInvocation.MyCommand.Definition  -Detailed
}