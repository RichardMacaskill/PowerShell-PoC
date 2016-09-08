cls
$ClonePrefix = '_StackOverflow_Clone_'
$Count = 5

$elapsed = [System.Diagnostics.Stopwatch]::StartNew()
write-host "Started at $(get-date)"

"OK, going to remove {0} clones" -f $Count

for ($i=0;$i -lt $Count;$i++)
{
    Remove-InstantCloneClone -CloneName $ClonePrefix$i
    "Removed clone {0}" -f $i
};

"Total Elapsed Time: {0}" -f $($elapsed.Elapsed.ToString())