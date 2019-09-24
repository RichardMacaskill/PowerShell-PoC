$serverURL = "http://rm-win10-sql201.testnet.red-gate.com:15156"
$authToken = "NTM2OTUxMTYyNzA4OTUxMDQwOmRiNjIyYWMxLWI1NDYtNDQzNi04OTE2LWQ1MzkxNGIzYzI5MQ=="

# Get the modules. Extra cost, but keeps versions current
Invoke-WebRequest -Uri "$serverURL/powershell" `
 -OutFile 'data-catalog.psm1' -Headers @{"Authorization"="Bearer $authToken"}
 
Import-Module .\data-catalog.psm1

# connect to your SQL Data Catalog instance - you'll need to generate an auth token in the UI
Use-Classification -ClassificationAuthToken $authToken -ServerUrl $serverURL

$instanceName = "rm-iclone1.testnet.red-gate.com"
$databaseName = "AW 2012 Clone number 2"

# get all columns into a collection
$allColumns = Get-Columns -instanceName $instanceName -databaseName $databaseName 

# the definition used is that untaggedColumns have NO tags, NO sensitivity label and NO information type. 
# you may need to adjust to suit your definition

$untaggedColumns = $allColumns|  Where-Object {  $_.tags.count -eq 0 -and !$_.sensitivityLabel -and !$_.informationType}

if ($untaggedColumns.columnName.Count -gt 0)
{
    $text = $untaggedColumns | Format-List | Out-String
    $From = "noreply@red-gate.com"
    $To = "richard.macaskill@red-gate.com"
    $Subject = "Untagged column found in database $databaseName"
    $Body = $text.Normalize()
    $SMTPServer = "internalsmtp.red-gate.com"
    $SMTPPort = "25"
    Send-MailMessage -From $From -to $To -Subject $Subject -Body $Body -SmtpServer $SMTPServer -port $SMTPPort    –DeliveryNotificationOption OnSuccess
}
else {
    "Started at {0}, NO untagged columns found. {1} total columns found" -f $(get-date) , $allColumns.Count
} 
