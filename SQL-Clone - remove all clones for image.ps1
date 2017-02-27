$myUrl = "http://rm-win10-sql201.testnet.red-gate.com:14145"
$myLocalAgent = "PDM-LTRICHARDM"
$myLocalInstance = "Dev"
Connect-SqlClone -ServerUrl $myUrl 
$sqlServerInstance = Get-SqlCloneSqlServerInstance -MachineName $myLocalAgent -InstanceName $myLocalInstance

$image = Get-SqlCloneImage -Name 'StackOverflow Jan 2017'

$clones = Get-SqlClone -Image $image

$elapsed = [System.Diagnostics.Stopwatch]::StartNew()
"Started at {0}, removing {1} clones for image ""{2}""" -f $(get-date) , $clones.Count , $image.Name

$clones | foreach { # note - '{' needs to be on same line as 'foreach' !
    $_ | Remove-SqlClone | Wait-SqlCloneOperation
    "Removed clone ""{0}""" -f $_.Name ;
                    };

"Total Elapsed Time: {0}" -f $($elapsed.Elapsed.ToString())
