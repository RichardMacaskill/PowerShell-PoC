﻿$myUrl = "http://rm-win10-sql201.testnet.red-gate.com:14145"
# dot source the invoke-parallel function 

. "C:\Dev\Git\PowerShell-PoC\Utils\PowerShell\Invoke-Parallel.ps1"

Connect-SqlClone -ServerUrl $myUrl

$image = Get-SqlCloneImage -Name 'AdventureWorks Masked for Demos Feb 2019' #'Forums Redgate Masked v1.2 - 2018-02-21'

$clones = Get-SqlClone -Image $image

$elapsed = [System.Diagnostics.Stopwatch]::StartNew()
"Started at {0}, removing {1} clones for image ""{2}""" -f $(get-date) , $clones.Count , $image.Name

$clones | Invoke-Parallel -ImportModules -ImportVariables -ScriptBlock {
     $_ | Remove-SqlClone | Wait-SqlCloneOperation
    "Removed clone ""{0}""" -f $_.Name ;
                    };

"Total Elapsed Time: {0}" -f $($elapsed.Elapsed.ToString())
