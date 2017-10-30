# dot source the invoke-parallel function 

. "C:\Dev\Git\PowerShell-PoC\Utils\PowerShell\Invoke-Parallel.ps1"

$myUrl = "http://rm-win10-sql201.testnet.red-gate.com:14145"
$myLocalAgent = "PDM-LTRICHARDM"
$myLocalInstance = "Dev"
Connect-SqlClone -ServerUrl $myUrl
$sqlServerInstance = Get-SqlCloneSqlServerInstance -MachineName $myLocalAgent -InstanceName $myLocalInstance
$count = 10

$image = Get-SqlCloneImage -Name 'TradesDataMart (Full) - 2017-09-04'

$ClonePrefix = '_Parallel_'

$elapsed = [System.Diagnostics.Stopwatch]::StartNew()
"Started at {0}" -f $(get-date)

"OK, going to create {0} clones" -f $Count

1..$count | Invoke-Parallel -ImportVariables -ScriptBlock {
    $image | New-SqlClone -Name ($ClonePrefix + $_.ToString("00")) -Location $sqlServerInstance | Wait-SqlCloneOperation
  "Created clone {0}" -f $_.ToString("00");   

  
};

"Total Elapsed Time: {0}" -f $($elapsed.Elapsed.ToString())
