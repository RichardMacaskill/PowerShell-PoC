cls
$Snapshot = 'StackOverflow-Snapshot-20160504'
$ClonePrefix = '_StackOverflow_Clone_'
$Count = 5

$elapsed = [System.Diagnostics.Stopwatch]::StartNew()
"Started at {0}" -f $(get-date)

"OK, going to create {0} clones" -f $Count

for ($i=0;$i -lt $Count;$i++)
{
    New-InstantCloneClone -SnapshotName $Snapshot -NewDatabaseName $ClonePrefix$i
    "Created clone {0}" -f $i;
};

"Total Elapsed Time: {0}" -f $($elapsed.Elapsed.ToString())