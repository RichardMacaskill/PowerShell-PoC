$myUrl = "http://rm-win10-sql201.testnet.red-gate.com:14145"

Connect-SqlClone -ServerUrl $myUrl 

$image = Get-SqlCloneImage -Name 'TradesDataMart (Full) - 2017-09-04' #'StackOverflow Mar 2017'

$clones = Get-SqlClone -Image $image

"Started at {0}, removing {1} clones for image ""{2}""" -f $(get-date) , $clones.Count , $image.Name

Measure-Command -Expression {
$clones | ForEach-Object { # note - '{' needs to be on same line as 'foreach' !
    $_ | Remove-SqlClone | Wait-SqlCloneOperation`
    "Removed clone ""{0}""" -f $_.Name ;
                    };
}  | Select-Object Minutes, Seconds, Milliseconds

