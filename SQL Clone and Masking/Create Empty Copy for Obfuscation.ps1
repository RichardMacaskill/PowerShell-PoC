$ServerInstance = "RM-IClone1.testnet.red-gate.com"
$DatabaseName = "StackOverflow"
$EmptyDatabaseName = "StackOverflow-Obfuscated"
invoke-Sqlcmd -Query "CREATE DATABASE [$EmptyDatabaseName];" -ServerInstance $ServerInstance 
$SourceDB = New-DlmDatabaseConnection -ServerInstance $ServerInstance -Database $DatabaseName
$TargetDB = New-DlmDatabaseConnection -ServerInstance $ServerInstance -Database $EmptyDatabaseName
Test-DlmDatabaseConnection $SourceDB 
Test-DlmDatabaseConnection $TargetDB 
$Release = New-DlmDatabaseRelease -Source $SourceDB -Target $TargetDB 
Use-DlmDatabaseRelease -InputObject $Release -DeployTo $TargetDB 

