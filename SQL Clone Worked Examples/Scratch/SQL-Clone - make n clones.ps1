$myUrl = "http://rm-win10-sql201.testnet.red-gate.com:14145"
$myLocalAgent = "PDM-LTRICHARDM"
$myLocalInstance = "Dev"
Connect-SqlClone -ServerUrl $myUrl
$sqlServerInstance = Get-SqlCloneSqlServerInstance -MachineName $myLocalAgent -InstanceName $myLocalInstance

$image = Get-SqlCloneImage -Name 'TradesDataMart (Full) - 2017-09-04'#'StackOverflow Mar 2017'

$ClonePrefix = '_TDM_'
$Count = 5

$elapsed = [System.Diagnostics.Stopwatch]::StartNew()
"Started at {0}" -f $(get-date)

"OK, going to create {0} clones" -f $Count

for ($i=0;$i -lt $Count;$i++)
{
    $image | New-SqlClone -Name ($ClonePrefix + $i.ToString("00")) -Location $sqlServerInstance | Wait-SqlCloneOperation
  "Created clone {0}" -f $i;   
};

"Total Elapsed Time: {0}" -f $($elapsed.Elapsed.ToString())
