Clear-Host
# Script to create a new SQL Clone database on each of my connected machines

$SQLCloneServer= "http://rm-win10-sql201.testnet.red-gate.com:14145"

Connect-SqlClone -ServerUrl $SQLCloneServer

$SourceDataImage = Get-SqlCloneImage -Name  'Forex_20170327'

$CloneName = 'AdventureWorks'

# I have several SQL Server instances registered on my SQL Clone Server - I want to deliver a copy to all of them
$Destinations = Get-SqlCloneSqlServerInstance | Where-Object -FilterScript { $_.Username -eq  'sa' }

"Started at {0}, creating clone databases for image ""{1}""" -f $(get-date) , $SourceDataImage.Name 

Measure-Command -Expression {
    foreach ($Destination in $Destinations)
    {
        $SourceDataImage | New-SqlClone -Name $CloneName -Location $Destination | Wait-SqlCloneOperation
        $ServerInstance = $Destination.Server + '\' +$Destination.Instance 
        "Created clone in instance {0}" -f $Destination.Server + '\' + $Destination.Instance;    
    } 
} | Select-Object Minutes, Seconds, Milliseconds

