
$SQLCloneServer = "http://rm-win10-sql201.testnet.red-gate.com:14145"

Connect-SqlClone -ServerUrl $SQLCloneServer

$CloneInstances = Get-SqlCloneSqlServerInstance | Where-Object {$_.Instance -notlike "Instance*"}  |Select-Object ServerAddress  

#Measure-Command -Expression {
        $CloneInstances | ForEach-Object {
                                            Find-DbaInstance -ComputerName $_.ServerAddress -ScanType TCPPort, SqlConnect, Browser, SPN, SqlService
                                        }
#} # | Select-Object Minutes, Seconds, Milliseconds