$ServerInstance = "RM-IClone1.testnet.red-gate.com"
$DatabaseName = "StackOverflow"
$EmptyDatabaseName = "StackOverflow-ObfuscatedCopy"
invoke-Sqlcmd -Query "CREATE DATABASE [$EmptyDatabaseName];" -ServerInstance $ServerInstance 
$SourceDB = New-DatabaseConnection -ServerInstance $ServerInstance -Database $DatabaseName
$TargetDB = New-DatabaseConnection -ServerInstance $ServerInstance -Database $EmptyDatabaseName
Test-DatabaseConnection $SourceDB 
Test-DatabaseConnection $TargetDB 
$Release = New-DatabaseRelease -Source $SourceDB -Target $TargetDB 
Use-DatabaseRelease -InputObject $Release -DeployTo $TargetDB 

