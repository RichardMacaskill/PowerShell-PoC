# Connect to SQL Clone Server
Connect-SqlClone -ServerUrl 'YOUR CLONE SERVER ADDRESS AND PORT HERE'

# Set variables for Image and Clone Location
$SqlServerInstance = Get-SqlCloneSqlServerInstance -MachineName 'YOURMACHINE' -InstanceName 'YOURINSTANCE'
$ImageDestination = Get-SqlCloneImageLocation -Path 'YOUR FILESHARE HERE'

# Set names for developers to receive Clones
$Devs = @("Chris", "Sam", "Cassi", "Becky", "Matt")

# Create New Temp Image and Temp Clone
$TempImage = New-SqlCloneImage -Name 'TempImage' -SqlServerInstance $SqlServerInstance -DatabaseName 'AdventureWorks_Production' -Destination $ImageDestination | Wait-SqlCloneOperation
$TempClone = New-SqlClone -Name 'AdventureWorks_Temp' -Location $SqlServerInstance -Image $TempImage | Wait-SqlCloneOperation

# Mask Temp Clone
& "C:\Program Files\Red Gate\Data Masker for SQL Server\DataMasker.exe" "C:\[…]\Documents\Example1.DMSSet" -R -D "YOURMACHINE\YOURINSTANCE[AdventureWorks_Dev_Chris] = YOURMACHINE\YOURINSTANCE[AdventureWorks_Temp]" -X | out-null

# Create New Masked Image from Clone
$DevImage = New-SqlCloneImage -Name 'AdventureWorksImage' -SqlServerInstance $SqlServerInstance -DatabaseName 'AdventureWorks_Temp' -Destination $ImageDestination | Wait-SqlCloneOperation 

# Remove Temporary Image and Clone
Remove-SqlClone -Clone $TempClone | Wait-SqlCloneOperation 
Remove-SqlCloneImage -Image $TempImage | Wait-SqlCloneOperation 

# Create New Clones for Devs
$Devs| ForEach-Object { # note - '{' needs to be on same line as 'foreach' !
   $DevImage | New-SqlClone -Name "AdventureWorks_Dev_$i" -Location $SqlServerInstance | Wait-SqlCloneOperation
}; 
