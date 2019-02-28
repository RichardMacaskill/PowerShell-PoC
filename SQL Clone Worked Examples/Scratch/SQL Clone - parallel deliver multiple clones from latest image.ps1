# Script to create a new SQL Clone database on each of my connected machines matching a name pattern
Clear-Host

# dot source the invoke-parallel function 
. "C:\Dev\Git\PowerShell-PoC\Utils\PowerShell\Invoke-Parallel.ps1"

#Get-Help Invoke-Parallel -full 

$SQLCloneServer= "http://rm-win10-sql201.testnet.red-gate.com:14145"

Connect-SqlClone -ServerUrl $SQLCloneServer

$SourceDataImage = Get-SqlCloneImage -Name  'AdventureWorks Masked for Demos Feb 2019' 

$CloneName = 'AdventureWorks - Masked 123123123'

# I have several SQL Server instances registered on my SQL Clone Server - I want to deliver a copy to all of them
$Destinations = Get-SqlCloneSqlServerInstance | 
Where-Object -FilterScript { $_.Server -like '*WKS*' -and $_.Instance -eq 'Dev' }

$Template = Get-SqlCloneTemplate -Image $SourceDataImage -Name "Update permissions for Dev"


# Start a timer
$elapsed = [System.Diagnostics.Stopwatch]::StartNew()

"Started at {0}, creating clone databases for image ""{1}""" -f $(get-date) , $SourceDataImage.Name 

 $Destinations | Invoke-Parallel -ImportVariables -ScriptBlock {
    $SourceDataImage | New-SqlClone -Name $CloneName -Template $Template -Location $_  | Wait-SqlCloneOperation
    "Created clone in instance {0}" -f $_.Server + '\' + $_.Instance;
}


"Total Elapsed Time: {0}" -f $($elapsed.Elapsed.ToString())  
