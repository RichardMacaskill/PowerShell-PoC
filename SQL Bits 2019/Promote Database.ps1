
$scriptsFolder = 'C:\Dev\Github\Forex'

$localInstanceForBuild = New-DatabaseConnection `
    -ServerInstance "RM-DEV-WKS02.TESTNET.RED-GATE.COM\DEV" `
    -Database "_Temp" 

$validatedSchema = Invoke-DatabaseBuild -InputObject $scriptsFolder -TemporaryDatabaseServer localInstanceForBuild

$buildArtifact = New-DatabaseBuildArtifact -InputObject $validatedSchema `
    -PackageId 1.0.1 -PackageVersion 1.0.1

$UAT = New-DatabaseConnection `
 -ServerInstance "RM-DEV-WKS02.TESTNET.RED-GATE.COM\DEV" `
 -Database "Forex" 

Test-DatabaseConnection -InputObject $UAT

New-DatabaseReleaseArtifact -Source $buildArtifact -Target $UAT | `
Use-DatabaseReleaseArtifact -DeployTo $UAT  -SkipPreUpdateSchemaCheck

$buildArtifact | Publish-DatabaseBuildArtifact -DlmDashboardUrl http://rm-iclone1.testnet.red-gate.com:19528


