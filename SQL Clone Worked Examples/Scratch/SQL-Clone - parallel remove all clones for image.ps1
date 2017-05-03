$myUrl = "http://rm-win10-sql201.testnet.red-gate.com:14145"
# dot source the invoke-parallel function 

. "C:\Dev\Git\PowerShell-PoC\Utils\PowerShell\Invoke-Parallel.ps1"

Connect-SqlClone -ServerUrl $myUrl 

$image = Get-SqlCloneImage -Name 'StackOverflow Mar 2017'

$clones = Get-SqlClone -Image $image

$elapsed = [System.Diagnostics.Stopwatch]::StartNew()
"Started at {0}, removing {1} clones for image ""{2}""" -f $(get-date) , $clones.Count , $image.Name

$clones | Invoke-Parallel -ImportVariables -ScriptBlock {
     $_ | Remove-SqlClone | Wait-SqlCloneOperation
    "Removed clone ""{0}""" -f $_.Name ;
                    };

"Total Elapsed Time: {0}" -f $($elapsed.Elapsed.ToString())
