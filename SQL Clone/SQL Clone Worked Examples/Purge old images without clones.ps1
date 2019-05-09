Connect-SqlClone -ServerUrl  'http://rm-win10-sql201.testnet.red-gate.com:14145'


$imageTimeToLiveDays = 7;
$oldImages = Get-SqlCloneImage | Where-Object {$_.CreatedDate -le (Get-Date).AddDays(0-$imageTimeToLiveDays)}

foreach ($image in $oldImages)
{
    $clones = Get-SqlClone | Where-Object {$_.ParentImageId -eq $image.Id}
    
    if (!($clones -eq $null))
    {
        "Will not remove image {0} because it has {1} dependent clone(s)." -f $image.Name, $clones.Count
    }
    else
    {
        Remove-SqlCloneImage -Image $image
        "Removed image {0}." -f $image.Name
    }
}