#
# Script to create n copies of a SQL Clone image in a single destinataion
#
Clear-Host
$myUrl = "http://rm-win10-sql201.testnet.red-gate.com:14145"
$myLocalAgent = "RM-IClone1"
$myLocalInstance = ""

# connect to SQL Clone server (using current credentials)
Connect-SqlClone -ServerUrl $myUrl

# fetch target instance for clone databases
$sqlServerInstance = Get-SqlCloneSqlServerInstance -MachineName $myLocalAgent -InstanceName $myLocalInstance

# fetch SQL Clone image to use
$image = Get-SqlCloneImage -Name 'TradesDataMart (Full) - 2017-09-04'#'StackOverflow Mar 2017'

$ClonePrefix = '_TDM_Clone_2017-10-26_'
$Count = 5

# Start a timer
$elapsed = [System.Diagnostics.Stopwatch]::StartNew()

"OK, going to create {0} clones" -f $Count

# create n clone databases

for ($i=0;$i -lt $Count;$i++)
  {
      $image | New-SqlClone -Name ($ClonePrefix + $i.ToString("00")) -Location $sqlServerInstance | Wait-SqlCloneOperation
    "Created clone {0}" -f $i;   
      
  } 


"Total Elapsed Time: {0}" -f $($elapsed.Elapsed.ToString())
