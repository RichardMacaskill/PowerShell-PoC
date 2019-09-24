Clear-Host
#Import-Module -Name RedGate.SqlClone.PowerShell

$dataCatalogAuthToken = "NTM2OTUxMTYyNzA4OTUxMDQwOmRiNjIyYWMxLWI1NDYtNDQzNi04OTE2LWQ1MzkxNGIzYzI5MQ=="

Invoke-WebRequest -Uri 'http://rm-win10-sql201.testnet.red-gate.com:15156/powershell' -OutFile 'data-catalog.psm1' -Headers @{"Authorization" = "Bearer $dataCatalogAuthToken" } 
Import-Module .\data-catalog.psm1 -Force

# dot source the invoke-parallel function 
. "C:\Dev\Github\PowerShell-PoC\Utils\PowerShell\Invoke-Parallel.ps1"

# Connect to SQL Clone server
$SQLCloneServer = "http://rm-win10-sql201.testnet.red-gate.com:14145"
Connect-SqlClone -ServerUrl $SQLCloneServer

# Reference to image
$Image = Get-SqlCloneImage -Name  'StackOverflow2010--Cleansed'

$ImageSourceInstance = $Image.OriginServerName + '.testnet.red-gate.com'
$ImageSourceDatabase = $Image.OriginDatabaseName

# I have several SQL Server instances registered on my SQL Clone Server - I want to deliver a copy to all of them
$Destinations = Get-SqlCloneSqlServerInstance | Where-Object -FilterScript { $_.Server -like '*WKS*' -and $_.Instance -eq 'Dev' }

$Template = Get-SqlCloneTemplate -Image $Image -Name "Drop masking tables"

# Create clone Dbs for Devs 
$CloneName = 'StackOverflow Masked for Dev - 20190905'

"Started at {0}, creating clone databases for image ""{1}""" -f $(get-date) , $Image.Name 

$Destinations | Invoke-Parallel -ImportModules -ImportVariables -ScriptBlock {
    $Image | New-SqlClone -Name $CloneName -Template $Template -Location $_ | Wait-SqlCloneOperation
}
# Push into extended properties
Use-Classification -ClassificationAuthToken $dataCatalogAuthToken     

# Register clones in Data Catalog by updating the instance (forcing a scan)
$Destinations | ForEach-Object { $machineInstance = $_.Machine.MachineName.ToString() + "\" + $_.Instance.ToString(); `
Start-InstanceScan  -FullyQualifiedInstanceName $machineInstance }

# Copy classification for clones
$Destinations | ForEach-Object `
{ $machineInstance = $_.Machine.MachineName.ToString() + "\" + `
$_.Instance.ToString(); Copy-DatabaseClassification -sourceInstanceName $ImageSourceInstance `
-sourceDatabaseName $ImageSourceDatabase -destinationInstanceName $machineInstance -destinationDatabaseName $CloneName}



