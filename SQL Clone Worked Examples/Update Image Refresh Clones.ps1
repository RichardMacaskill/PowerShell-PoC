# update an image and 'refresh' all clones to use the new image

#Connect-SqlClone -ServerUrl 'http://sql-clone.example.com:14145'
Connect-SqlClone -ServerUrl  'http://rm-win10-sql201.testnet.red-gate.com:14145'

$oldImageName = 'Forex_20170301'
$newImageName = 'Forex_20170302'

$oldImage = Get-SqlCloneImage -Name $oldImageName
$newImage = Get-SqlCloneImage -Name $newImageName

$oldClones = Get-SqlClone | Where-Object {$_.ParentImageId -eq $oldImage.Id}

foreach ($clone in $oldClones)
{
    $thisDestination = Get-SqlCloneSqlServerInstance | Where-Object {$_.Id -eq $clone.LocationId}
    Remove-SqlClone $clone | Wait-SqlCloneOperation
    "Removed clone ""{0}"" from instance ""{1}"" " -f $clone.Name , $thisDestination.Server + '\' + $thisDestination.Instance;   
    $newImage | New-SqlClone -Name $clone.Name -Location $thisDestination  | Wait-SqlCloneOperation
    "Added clone ""{0}"" to instance ""{1}"" " -f $clone.Name , $thisDestination.Server + '\' + $thisDestination.Instance;   
}

Remove-SqlCloneImage -Image $oldImage;