# start docker process on the server
# docker -H tcp://0.0.0.0:2375 -d

# dot source the invoke-parallel function 
. "C:\Dev\Git\PowerShell-PoC\Utils\PowerShell\Invoke-Parallel.ps1"

# query docker server
$output = docker -H rm-win10-clone3.testnet.red-gate.com:2375 ps

$returnLines = $output.Split("&") 

$containerIDs = $returnLines | ForEach-Object { $_.Substring(0,12) }

$containersToStart = $containerIDs | Where-Object -FilterScript {$_ -ne "CONTAINER ID"}   

$count=$containersToStart.Count
Measure-Command -Expression {
        1..$count | Invoke-Parallel -ImportVariables -ScriptBlock {
            $containersToStart | ForEach-Object  {docker -H rm-win10-clone3.testnet.red-gate.com:2375 start $_}
                                                                    }
                            } | Select-Object Minutes, Seconds, Milliseconds

$SQLCloneServer= "http://rm-win10-sql201.testnet.red-gate.com:14145"

Connect-SqlClone -ServerUrl $SQLCloneServer

$SourceDataImage = Get-SqlCloneImage -Name  'Forex_20170327'

$CloneName = 'Forex-Hotfix-18554'

# I have several SQL Server instances registered on my SQL Clone Server - I want to deliver a copy to all of them
$Destinations = Get-SqlCloneSqlServerInstance | Where-Object -FilterScript { $_.Username -eq 'sa' }

"Started at {0}, creating clone databases for image ""{1}""" -f $(get-date) , $SourceDataImage.Name 

Measure-Command -Expression {
    foreach ($Destination in $Destinations)
    {
        $SourceDataImage | New-SqlClone -Name $CloneName -Location $Destination | Wait-SqlCloneOperation
        $ServerInstance = $Destination.Server + '\' +$Destination.Instance 
        "Created clone in instance {0}" -f $Destination.Server + '\' + $Destination.Instance;    
    } 
} | Select-Object Minutes, Seconds, Milliseconds