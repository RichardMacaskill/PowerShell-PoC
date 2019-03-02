Clear-Host
# Script to create a new SQL Clone database on each of my connected machines

# dot source the invoke-parallel function 
. "C:\Dev\Git\PowerShell-PoC\Utils\PowerShell\Invoke-Parallel.ps1"

$SQLCloneServer= "http://rm-win10-sql201.testnet.red-gate.com:14145"

Connect-SqlClone -ServerUrl $SQLCloneServer

$SourceDataImage = Get-SqlCloneImage -Name  'StackOverflow Mar 2017'

$CloneName = 'StackOverflow-Hotfix84358'

# I have several SQL Server instances registered on my SQL Clone Server - I want to deliver a copy to all of them
$Destinations = Get-SqlCloneSqlServerInstance | Where-Object -FilterScript { $_.Server -like '*WKS*' }

"Started at {0}, creating clone databases for image ""{1}""" -f $(get-date) , $SourceDataImage.Name 

Measure-Command -Expression {
     $Destinations | Invoke-Parallel -ImportVariables -ScriptBlock {
            $SourceDataImage | New-SqlClone -Name $CloneName -Location $_ | Wait-SqlCloneOperation
        $ServerInstance = $Destination.Server + '\' +$_.Instance 
        "Created clone in instance {0}" -f $_.Server + '\' + $_.Instance;    
    } 
} | Select-Object Minutes, Seconds, Milliseconds

