$myUrl = "http://rm-win10-sql201.testnet.red-gate.com:14145"
$myLocalAgent = "RM-ICLONE1"
$myLocalInstance = ""

Connect-SqlClone -ServerUrl $myUrl -Verbose

$sourceDatabaseName = 'StackOverflow'
$imageDestination = Get-SqlCloneImageLocation -Path '\\is-filestore02.testnet.red-gate.com\rm-iclone\RM\SQL Clone Beta Images'
$sqlServerInstance =  Get-SqlCloneSqlServerInstance -MachineName $myLocalAgent -InstanceName $myLocalInstance


$elapsed = [System.Diagnostics.Stopwatch]::StartNew()
"Started at {0}" -f $(get-date)

"OK, going to create an image " -f $Count

$imageOperation = New-SqlCloneImage -Name $('StackOverflow {0}' -f $((get-date).ToString("yyyy-MM-dd HH:mm"))) `
    -SqlServerInstance $sqlServerInstance `
    -DatabaseName $sourceDatabaseName `
    -Destination $imageDestination

$imageOperation | Wait-SqlCloneOperation

"Total Elapsed Time: {0}" -f $($elapsed.Elapsed.ToString())
