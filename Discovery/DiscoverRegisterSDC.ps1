# Fetch and import the SQL Data Catalog PS functions from its API
# Change the auth token and Uri to match your environment
$dataCatalogAuthToken = "NTM2OTUxMTYyNzA4OTUxMDQwOmRiNjIyYWMxLWI1NDYtNDQzNi04OTE2LWQ1MzkxNGIzYzI5MQ=="
Invoke-WebRequest -Uri 'http://rm-win10-sql201.testnet.red-gate.com:15156/powershell' -OutFile 'datacatalog.psm1' -Headers @{"Authorization" = "Bearer $dataCatalogAuthToken" }
 
Import-Module .\datacatalog.psm1 -Force

# Connect to SQL Data Catalog
Use-Classification -ClassificationAuthToken $dataCatalogAuthToken

# Install DBATools if you don't already have it. May require admin.
if (-Not (Get-Module -ListAvailable -Name dbatools)) {Install-Module dbatools }

# Use DBATools to discover SQL Server instances. It's well worth exploring options https://dbatools.io/find-sql-instances/
# IMPORTANT - speak to your infosec team before running on a corporate network, as various scans are involved. Or get ready to do some explaining.

$output = Find-DbaInstance -DiscoveryType DataSourceEnumeration -ScanType Browser, TCPPort  | Select-Object  ComputerName,InstanceName
       
foreach ($line in $output) {
    if ($line.InstanceName.ToLower() -eq "mssqlserver" -Or $line.InstanceName.ToLower() -eq "default") {
        $foundInstanceFqdn = $line.ComputerName
    } else {
        $foundInstanceFqdn = ($line.ComputerName + "\" + $line.InstanceName).ToLower()
    }
    Write-Host "Adding instance:" $foundInstanceFqdn
    Add-RegisteredSqlServerInstance -FullyQualifiedInstanceName $foundInstanceFqdn
}
      