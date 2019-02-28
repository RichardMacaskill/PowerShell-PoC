import-module "C:\Program Files (x86)\Red Gate\SQL Clone PowerShell Client\RedGate.SqlClone.PowerShell"

Connect-SqlClone -ServerUrl "http://rm-win10-sql201.testnet.red-gate.com:14145"

$machines = Get-SqlCloneMachine | Where-Object {$_.StatusDescription -eq "Up to date"}

$machines | ForEach-Object {
    $thisMachine = Get-SqlCloneSqlServerInstance -MachineName $_.MachineName  ;    
    $thisInstance = $thisMachine.ServerAddress ;
    if ($thisMachine.Instance -eq "DEV") { $thisInstance += '\' + $thisMachine.Instance};
    "Testing Disk Speed for databases on {0}" -f $thisInstance;
    Test-DbaDiskSpeed -SqlInstance $thisInstance | `
        Select-Object ComputerName , Database , FileName, ReadPerformance , write-performance | `
        Sort-Object Database, Filename | ` # Out-GridView
        Format-Table # NOTE - replace this line with the following 2 to change output to db table
        #ConvertTo-DbaDataTable | `
        #Write-DbaDataTable -SQLServer "pdm-ltrichardm\dev" -Table DBATools.dbo.DiskSpeedTest -AutoCreateTable 
}