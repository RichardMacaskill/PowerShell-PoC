# This removes all clones and images from the end-to-end example run today

# dot source the invoke-parallel function 
. "C:\Dev\Github\PowerShell-PoC\Utils\PowerShell\Invoke-Parallel.ps1"

$ImageName = "StackOverflow2010-$(Get-Date -Format yyyyMMdd)-Cleansed";
# OR set it manually 
# $ImageName = "StackOverflow2010-20191120-Cleansed"

Connect-SqlClone -ServerUrl  'http://rm-win10-sql201.testnet.red-gate.com:14145';

$image = Get-SqlCloneImage -Name $ImageName;

if(!$image) {break}; # dangerous if image not found, random clone deletion!

$clones = Get-SqlClone -Image $image
$elapsed = [System.Diagnostics.Stopwatch]::StartNew()

"Started at {0}, removing {1} clones for image ""{2}""" -f $(get-date) , $clones.Count , $image.Name

<# $clones | ForEach-Object { # note - '{' needs to be on same line as 'foreach' !
    $_ | Remove-SqlClone | Wait-SqlCloneOperation
    "Removed clone ""{0}""" -f $_.Name ;
}; #>

$clones | Invoke-Parallel -ImportVariables -ScriptBlock {
    $_ | Remove-SqlClone | Wait-SqlCloneOperation
    "Removed clone ""{0}""" -f $_.Name ;
}

Remove-SqlCloneImage -Image $image;

"Total Elapsed Time: {0}" -f $($elapsed.Elapsed.ToString())