# Connect to SQL Clone Server
Connect-SqlClone -ServerUrl 'YOUR CLONE SERVER ADDRESS AND PORT HERE'

# Set variables for Image and Clone Location
$SqlServerInstance = Get-SqlCloneSqlServerInstance -MachineName 'YOUR MACHINE NAME HERE' -InstanceName 'YOUR INSTANCE NAME HERE'
$ImageDestination = Get-SqlCloneImageLocation -Path 'YOUR FILESHARE HERE'

# Set names for developers to receive Clones
$Devs = @("Chris", "Sam", "Cassi", "Becky", "Matt")

# Create New Image
$Image = New-SqlCloneImage -Name 'AdventureWorksImage' -SqlServerInstance $SqlServerInstance -DatabaseName 'AdventureWorks2012' -Destination $ImageDestination | Wait-SqlCloneOperation 

# Create New Clones for Devs
$Devs | ForEach-Object { # note - '{' needs to be on same line as 'foreach' !
    $Image | New-SqlClone -Name "AdventureWorks_Dev_$_" -Location $SqlServerInstance | Wait-SqlCloneOperation
}  


