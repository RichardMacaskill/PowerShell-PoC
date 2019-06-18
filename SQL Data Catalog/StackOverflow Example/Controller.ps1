Clear-Host
# Call as a script. TODO - rebuild as function, export as module
Measure-Command -Expression{./CatalogToDataMasker.ps1} | Select-Object Minutes, Seconds
Write-Output "Created masking set based on SQL Data Catalog tag values."

# Create SQL Clone image using masking set
# Script to create a new SQL Clone data image and run a Data Masker masking set on it
 
Connect-SqlClone -ServerUrl 'http://sql-clone.testnet.red-gate.com:14145/'

$SqlServerInstance = Get-SqlCloneSqlServerInstance -MachineName 'rm-iclone1' -InstanceName ''

$ImageDestination = Get-SqlCloneImageLocation -Path '\\rm-iclone1.testnet.red-gate.com\SQL Clone Images'

$MaskingSet = New-SqlCloneMask -Path "\\rm-iclone1.testnet.red-gate.com\Masking Set Files\Generated\StackOverflow2010 Generated.DMSMaskSet"
 
$ImageOperation = New-SqlCloneImage -Name "StackOverflow2010-$(Get-Date -Format yyyyMMddHHmmss)-Cleansed" `
    -SqlServerInstance $SqlServerInstance `
    -DatabaseName 'StackOverflow2010' `
    -Destination $ImageDestination `
    -Modifications @($MaskingSet)
 
Measure-Command -Expression { Wait-SqlCloneOperation -Operation $ImageOperation } | Select-Object Minutes, Seconds

Write-Output "Finished call to create SQL Clone image using generated masking set."
