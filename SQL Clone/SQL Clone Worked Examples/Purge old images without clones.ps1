Connect-SqlClone -ServerUrl  'http://rm-win10-sql201.testnet.red-gate.com:14145'


$imageTimeToLiveDays = 60;
$oldImages = Get-SqlCloneImage | Where-Object {$_.CreatedDate -ge (Get-Date).AddDays(0-$imageTimeToLiveDays)}

foreach ($image in $oldImages)
{
    $clones = Get-SqlClone | Where-Object {$_.ParentImageId -eq $image.Id}
    
    if (!($null -eq $clones))
    {
        "Will not remove image {0} because it has {1} dependent clone(s)." -f $image.Name, $clones.Count
    }
    else
    {
       
        if ($image.Name -like '*Advent*')
        {
        Remove-SqlCloneImage -Image $image
        "Removed image {0}." -f $image.Name
        }
    }
}