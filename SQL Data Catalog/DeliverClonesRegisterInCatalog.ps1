Clear-Host
Import-Module -Name RedGate.SqlClone.PowerShell

$dataCatalogAuthToken = "NTM2OTUxMTYyNzA4OTUxMDQwOmRiNjIyYWMxLWI1NDYtNDQzNi04OTE2LWQ1MzkxNGIzYzI5MQ=="

Invoke-WebRequest -Uri 'https://rm-win10-sql201.testnet.red-gate.com:15156/powershell' -OutFile 'data-catalog.psm1' -Headers @{"Authorization" = "Bearer $dataCatalogAuthToken" } 
Import-Module .\data-catalog.psm1 -Force

# dot source the invoke-parallel function 
. "C:\Dev\Github\PowerShell-PoC\Utils\PowerShell\Invoke-Parallel.ps1"

# Connect to SQL Clone server
$SQLCloneServer = "http://rm-win10-sql201.testnet.red-gate.com:14145"
Connect-SqlClone -ServerUrl $SQLCloneServer

# Reference to image
$ForumsImage = Get-SqlCloneImage -Name  'Redgate Forums Masked'

# I have several SQL Server instances registered on my SQL Clone Server - I want to deliver a copy to all of them
$Destinations = Get-SqlCloneSqlServerInstance | 
Where-Object -FilterScript { $_.Server -like '*WKS*' -and $_.Instance -eq 'Dev' }

$Template = Get-SqlCloneTemplate -Image $ForumsImage -Name "Update permissions for Dev"

# Create clone Dbs for Devs 
$ForumsCloneName = 'Forums Masked for Dev - TEST'

# Start a timer
$elapsed = [System.Diagnostics.Stopwatch]::StartNew()

"Started at {0}, creating clone databases for image ""{1}""" -f $(get-date) , $ForumsImage.Name 

$Destinations | Invoke-Parallel -ImportModules -ImportVariables -ScriptBlock {
    $ForumsImage | New-SqlClone -Name $ForumsCloneName -Template $Template -Location $_ | Wait-SqlCloneOperation
}
    # Register clones in Data Catalog


    # Copy classification for clones

    # Push into extended properties
Use-Classification -ClassificationAuthToken $dataCatalogAuthToken     


Add-RegisteredSqlServerInstance -FullyQualifiedInstanceName "rm-dev-wks01\dev"