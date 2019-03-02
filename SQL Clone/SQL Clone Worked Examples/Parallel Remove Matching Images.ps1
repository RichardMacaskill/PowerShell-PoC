
$myUrl = "http://rm-win10-sql201.testnet.red-gate.com:14145"
# dot source the invoke-parallel function 

. "C:\Dev\Git\PowerShell-PoC\Utils\PowerShell\Invoke-Parallel.ps1"

Connect-SqlClone -ServerUrl $myUrl

$images = Get-SqlCloneImage | Where-Object -FilterScript { $_.Name -like '*AdventureWorks_201807*'  }

-Name 'AdventureWorks_20180508_Masked'#'Forums Redgate Masked v1.2 - 2018-02-21'

$elapsed = [System.Diagnostics.Stopwatch]::StartNew()
"Started at {0}, removing {1} clones for image ""{2}""" -f $(get-date) , $clones.Count , $image.Name

$images | Invoke-Parallel -ImportVariables -ScriptBlock {
     $_ | Remove-SqlCloneImage | Wait-SqlCloneOperation
    "Removed Image ""{0}""" -f $_.Name ;
                    };

"Total Elapsed Time: {0}" -f $($elapsed.Elapsed.ToString())

