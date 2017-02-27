$myUrl = "http://rm-win10-sql201.testnet.red-gate.com:14145"
$myLocalAgent = "PDM-LTRICHARDM"
$myLocalInstance = "Dev"
Connect-SqlClone -ServerUrl $myUrl
$sqlServerInstance = Get-SqlCloneSqlServerInstance -MachineName $myLocalAgent -InstanceName $myLocalInstance

$image = Get-SqlCloneImage -Name 'StackOverflow Jan 2017'

$ClonePrefix = '_SO_Clone'
$Count = 5

$elapsed = [System.Diagnostics.Stopwatch]::StartNew()
"Started at {0}" -f $(get-date)

"OK, going to create {0} clones" -f $Count

for ($i=0;$i -lt $Count;$i++)
{
    $image | New-SqlClone -Name $ClonePrefix$i -Location $sqlServerInstance | Wait-SqlCloneOperation
  "Created clone {0}" -f $i;   
};

"Total Elapsed Time: {0}" -f $($elapsed.Elapsed.ToString())
