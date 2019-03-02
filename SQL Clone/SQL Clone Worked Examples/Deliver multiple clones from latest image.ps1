# Script to create a new SQL Clone database on each of my connected machines

$SQLCloneServer= "http://rm-win10-sql201.testnet.red-gate.com:14145"
$Myservers[3]
$myserver1="UAT"

Connect-SqlClone -ServerUrl $SQLCloneServer

$SourceDataImage = Get-SqlCloneImage -Name  'AdventureWorks_20180329'

$CloneName = 'AdventureWorks_Latest'

# I have 3 SQL Server instances registered on my SQL Clone Server - I want to deliver a copy to all of them
$Destinations = Get-SqlCloneSqlServerInstance

# I'm only going to make a small adjustment to permissions in this example
$Query = "CREATE USER StackOverflowUser FROM LOGIN [RED-GATE\Richard.Macaskill];ALTER ROLE db_datareader ADD member [StackOverflowUser];"

# Start a timer
$elapsed = [System.Diagnostics.Stopwatch]::StartNew()

"Started at {0}, creating clone databases for image ""{1}""" -f $(get-date) , $SourceDataImage.Name 

foreach ($Destination in $Destinations)
{
    $SourceDataImage | New-SqlClone -Name $CloneName -Location $Destination | Wait-SqlCloneOperation
    $ServerInstance = $Destination.Server + '\' +$Destination.Instance 
    #Start-Sleep -s 10
    #Invoke-Sqlcmd -Query $Query -ServerInstance $ServerInstance -Database $CloneName 
    "Created clone in instance {0}" -f $Destination.Server + '\' + $Destination.Instance;   
}

"Total Elapsed Time: {0}" -f $($elapsed.Elapsed.ToString())  
