
Connect-SqlClone -ServerUrl  'http://rm-win10-sql201.testnet.red-gate.com:14145'

$date = (Get-Date).AddDays(-7)
$oldImageName = 'AdventureWorks_' + $date.ToString('yyyyMMdd')

$image = Get-SqlCloneImage -Name $oldImageName 

$clones = Get-SqlClone -Image $image

Measure-Command -Expression {
"Started at {0}, removing {1} clones for image ""{2}""" -f $(get-date) , $clones.Count , $image.Name
$clones | ForEach-Object { # note - '{' needs to be on same line as 'foreach' !
    $_ | Remove-SqlClone | Wait-SqlCloneOperation
    "Removed clone ""{0}""" -f $_.Name ;
                    };
}

Remove-SqlCloneImage -Image $image