
$scriptsFolder = 'C:\Dev\Git\RedgateForums'

$validatedSchema = Invoke-DatabaseBuild -InputObject $scriptsFolder

$buildArtifact = New-DatabaseBuildArtifact -InputObject $validatedSchema `
-PackageId 1.0.0.1 -PackageVersion 1.0.0.1

$UAT = New-DatabaseConnection `
 -ServerInstance "RM-DEV-WKS02.TESTNET.RED-GATE.COM\DEV" `
 -Database "Forums for SQL Bits" 

Test-DatabaseConnection -InputObject $UAT

New-DatabaseReleaseArtifact -Source $buildArtifact -Target $UAT | `
Use-DatabaseReleaseArtifact -DeployTo $UAT  -SkipPreUpdateSchemaCheck

$buildArtifact | Publish-DatabaseBuildArtifact -DlmDashboardUrl http://pdm-ltrichardm.red-gate.com:19528/


