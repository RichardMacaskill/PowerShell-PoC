
Import-Module dbatools


$options = New-DbaScriptingOption 
$options.ScriptDrops = $false
$options.WithDependencies = $true


Export-DbaUser -SqlInstance "rm-iclone1.testnet.red-gate.com" -Database "Forex" `
-Path C:\temp\forex-users.sql -ScriptingOptionsObject $options