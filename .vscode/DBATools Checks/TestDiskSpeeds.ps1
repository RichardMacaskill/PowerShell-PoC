Connect-SqlClone -ServerUrl "http://rm-win10-sql201.testnet.red-gate.com:14145"

$machines = Get-SqlCloneMachine

$machines | ForEach-Object {
    $thisMachine = Get-SqlCloneSqlServerInstance -MachineName $_.MachineName  ;    
    $thisInstance = $thisMachine.ServerAddress ;
    if ($thisMachine.Instance -ne "") { $thisInstance += '\' + $thisMachine.Instance};
    "Testing Disk Speed for databases on {0}" -f $thisInstance;
    Test-DbaDiskSpeed -SqlInstance $thisInstance | `
        Select-Object ComputerName , Database , FileName, ReadPerformance , write-performance | `
        Sort-Object Database, Filename | `
        Format-Table
    #ConvertTo-DbaDataTable | `
    #Write-DbaDataTable -SQLServer "pdm-ltrichardm\dev" -Table DBATools.dbo.DiskSpeedTest -AutoCreateTable 
}