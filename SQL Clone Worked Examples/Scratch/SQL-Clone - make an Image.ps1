$myUrl = "http://rm-win10-sql201.testnet.red-gate.com:14145"
$myLocalAgent = "RM-ICLONE1"
$myLocalInstance = ""

Connect-SqlClone -ServerUrl $myUrl -Verbose

$sourceDatabaseName = 'TradesDataMart'
$imageDestination = Get-SqlCloneImageLocation -Path '\\is-filestore02.testnet.red-gate.com\BigVol2\SQL Clone Images'
$sqlServerInstance =  Get-SqlCloneSqlServerInstance -MachineName $myLocalAgent -InstanceName $myLocalInstance
$imageName = ('TradesDataMart (Full) - {0}' -f $((get-date).ToString("yyyy-MM-dd"))) 

"Started at {0}, creating image ""{1}"" from database ""{2}""" -f $(get-date) , $imageName , $sourceDatabaseName

Measure-Command -Expression {
$imageOperation = New-SqlCloneImage -Name $ImageName `
    -SqlServerInstance $sqlServerInstance `
    -DatabaseName $sourceDatabaseName `
    -Destination $imageDestination 

$imageOperation | Wait-SqlCloneOperation
}  | Select-Object Hours, Minutes, Seconds 


"Completed at {0}" -f $(get-date)
