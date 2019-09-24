Clear-Host
# Call as a script. TODO - rebuild as function, export as module

# Create SQL Clone image using masking set
# Script to create a new SQL Clone data image and run a Data Masker masking set on it
 
Connect-SqlClone -ServerUrl 'http://sql-clone.testnet.red-gate.com:14145/'

$SqlServerInstance = Get-SqlCloneSqlServerInstance -MachineName 'rm-iclone1' -InstanceName ''

$ImageDestination = Get-SqlCloneImageLocation -Path '\\rm-iclone1.testnet.red-gate.com\SQL Clone Images'

$MaskingSet = New-SqlCloneMask  -Path "\\rm-iclone1\Masking Set Files\Generated\StackOverflow2010 Generated.DMSMaskSet" -Name "Masking Set for StackOverflow v1.0"

$InternalDevelopmentTeam = Get-SqlCloneTeam  -Name 'Internal Development'
 
$ImageOperation = New-SqlCloneImage -Name "StackOverflow2010-$(Get-Date -Format yyyyMMddHHmmss)-Cleansed" `
    -SqlServerInstance $SqlServerInstance `
    -DatabaseName 'SO-Small-Clone' `
    -Destination $ImageDestination `
    -Modifications $MaskingSet `
    -Team $InternalDevelopmentTeam
 

Write-Progress -Activity "Generating sanitised SQL Clone image using masking set." -Status "Creating image."  
Measure-Command -Expression { Wait-SqlCloneOperation -Operation $ImageOperation } | Select-Object Minutes, Seconds
Write-Progress -Activity "Generating sanitised SQL Clone image using masking set." -Completed

Write-Output "Finished call to create SQL Clone image using generated masking set."
