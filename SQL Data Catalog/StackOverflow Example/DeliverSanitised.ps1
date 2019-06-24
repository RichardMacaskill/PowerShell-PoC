# Script to create a new SQL Clone database on each of my connected machines matching a name pattern
Clear-Host

$SQLCloneServer = "http://sql-clone.testnet.red-gate.com:14145"

Connect-SqlClone -ServerUrl $SQLCloneServer

$StackOverflowImage = Get-SqlCloneImage -Name  'StackOverflow2010-20190617142829-Cleansed'

$StackOverflowCloneName = 'StackOverflow2010 (masked)' 

# I have several SQL Server instances registered on my SQL Clone Server - I want to deliver a copy to all of them
$Destinations = Get-SqlCloneSqlServerInstance | 
Where-Object -FilterScript { $_.Server -like '*WKS*' -and $_.Instance -eq 'Dev' }

# Start a timer
$elapsed = [System.Diagnostics.Stopwatch]::StartNew()

"Started at {0}, creating clone databases for image ""{1}""" -f $(get-date) , $ForumsImage.Name 

$Destinations | ForEach-Object  {
    $StackOverflowImage | New-SqlClone -Name $StackOverflowCloneName -Location $_ | Wait-SqlCloneOperation
        
    "Created clone in instance {0}" -f $_.Server + '\' + $_.Instance;

}
"Total Elapsed Time: {0}" -f $($elapsed.Elapsed.ToString()) 