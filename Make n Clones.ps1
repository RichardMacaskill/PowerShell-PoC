# Script to create a new SQL Clone data image from a backup file

$SQLCloneServer= "http://rm-win10-sql201.testnet.red-gate.com:14145"
$SQLCloneAgent = "rm-iclone1"

Connect-SqlClone -ServerUrl $myUrl

$Snapshot = 'StackOverflow Jan 2017'
$ClonePrefix = '_SO_Clone'
$Count = 15

$elapsed = [System.Diagnostics.Stopwatch]::StartNew()
"Started at {0}" -f $(get-date)

"OK, going to create {0} clones" -f $Count

for ($i=0;$i -lt $Count;$i++)
{
    New-InstantCloneClone -SnapshotName $Snapshot -NewDatabaseName $ClonePrefix$i
    "Created clone {0}" -f $i;
};

"Total Elapsed Time: {0}" -f $($elapsed.Elapsed.ToString())