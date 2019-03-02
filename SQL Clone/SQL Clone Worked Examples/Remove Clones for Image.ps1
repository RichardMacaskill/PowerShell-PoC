
Connect-SqlClone -ServerUrl  'http://rm-win10-sql201.testnet.red-gate.com:14145'


$image = Get-SqlCloneImage -Name 'TradesDataMart (Full) - 2017-09-04'

$clones = Get-SqlClone -Image $image
$elapsed = [System.Diagnostics.Stopwatch]::StartNew()

"Started at {0}, removing {1} clones for image ""{2}""" -f $(get-date) , $clones.Count , $image.Name

$clones | ForEach-Object { # note - '{' needs to be on same line as 'foreach' !
    $_ | Remove-SqlClone | Wait-SqlCloneOperation
    "Removed clone ""{0}""" -f $_.Name ;
                    };
"Total Elapsed Time: {0}" -f $($elapsed.Elapsed.ToString())