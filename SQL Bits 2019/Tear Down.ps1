$myUrl = "http://rm-win10-sql201.testnet.red-gate.com:14145"

Connect-SqlClone -ServerUrl $myUrl 

$clones = Get-SqlClone | Where-Object {$_.Name -Like "*Bits*"}

"Started at {0}, removing {1} clones" -f $(get-date) , $clones.Count 

Measure-Command -Expression {
$clones | ForEach-Object { # note - '{' needs to be on same line as 'foreach' !
    $_ | Remove-SqlClone | Wait-SqlCloneOperation 
    "Removed clone ""{0}""" -f $_.Name ;
                    };
}  | Select-Object Minutes, Seconds, Milliseconds

