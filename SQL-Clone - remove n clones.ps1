$myUrl = "http://rm-win10-sql201.testnet.red-gate.com:14145"
$myLocalAgent = "PDM-LTRICHARDM"
$myLocalInstance = "Dev"
Connect-SqlClone -ServerUrl $myUrl
$sqlServerInstance = Get-SqlCloneSqlServerInstance -MachineName $myLocalAgent -InstanceName $myLocalInstance

$image = Get-SqlCloneImage -Name 'Forex_Large'

$ClonePrefix = '_Forex_Clone'
$Count = 50

$elapsed = [System.Diagnostics.Stopwatch]::StartNew()
"Started at {0}" -f $(get-date)

"OK, going to remove {0} clones" -f $Count

for ($i=0;$i -lt $Count;$i++)
{
   $thisClone =  Get-SqlClone -Name $ClonePrefix$i
   Remove-SqlClone -Clone  $thisClone | Wait-SqlCloneOperation
  "Removed clone {0}" -f $i;
};

"Total Elapsed Time: {0}" -f $($elapsed.Elapsed.ToString())
