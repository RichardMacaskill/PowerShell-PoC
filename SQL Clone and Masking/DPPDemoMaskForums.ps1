# Connect to SQL Clone Server
Connect-SqlClone -ServerUrl "http://rm-win10-sql201.testnet.red-gate.com:14145"

# Set variables for Image and Clone Location
$SqlServerInstance = Get-SqlCloneSqlServerInstance -MachineName 'PDM-LTRICHARDM' -InstanceName 'DEV'
$ImageDestination = Get-SqlCloneImageLocation -Path '\\is-filestore02.testnet.red-gate.com\BigVol2\SQL Clone Images' 
# Set names for developers to receive Clones
$Devs = @("Chris", "Becky", "Cassi", "Test")

# Create New Temp Image and Temp Clone
$TempImage = New-SqlCloneImage -Name 'TempImage' -SqlServerInstance $SqlServerInstance -BackupFileName 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup\forums-redgate-com_Production.bak' -Destination $ImageDestination | Wait-SqlCloneOperation
$TempClone = New-SqlClone -Name 'forums-redgate-com_Temp' -Location $SqlServerInstance -Image (Get-SqlCloneImage -Name 'TempImage') | Wait-SqlCloneOperation

Start-Sleep -Seconds 2

# Mask Temp Clone
& "C:\Program Files (x86)\Red Gate\Data Masker for SQL Server\DataMasker.exe" "C:\Program Files (x86)\Red Gate\Data Masker for SQL Server\MaskingSets\forums-redgate-com_TempContacts.DMSSet" -R -X | out-null

Start-Sleep -Seconds 2

# Create New Masked Image from Clone
$script = New-SqlCloneSqlScript -Path  "C:\temp\modified.sql"
New-SqlCloneImage -Name 'forums-redgate-com_Production' -SqlServerInstance $SqlServerInstance -DatabaseName 'forums-redgate-com_Temp' -Destination $ImageDestination -Modifications $script | Wait-SqlCloneOperation
$DevImage = Get-SqlCloneImage -Name 'forums-redgate-com_Production'

# Remove Temporary Image and Clone
Remove-SqlClone -Clone (Get-SqlClone -Name 'forums-redgate-com_Temp')| Wait-SqlCloneOperation 
Remove-SqlCloneImage -Image (Get-SqlCloneImage -Name 'TempImage')| Wait-SqlCloneOperation 

# Create New Clones for Devs
$Devs| ForEach-Object { # note - '{' needs to be on same line as 'foreach' !
   $DevImage | New-SqlClone -Name "forums-redgate-com_Dev_$_" -Location $SqlServerInstance | Wait-SqlCloneOperation
};