﻿
$scriptsFolder = 'C:\Dev\Github\Forex'
$validatedSchema = Invoke-DlmDatabaseSchemaValidation -InputObject $scriptsFolder
$documentation = $validatedSchema | New-DlmDatabaseDocumentation
$databasePackage = New-DlmDatabasePackage $validatedSchema -PackageId 1 -PackageVersion 0.4 -Documentation $documentation -PackageDescription 'My new database package' 

#Publish-DlmDatabasePackage -InputObject $databasePackage -DlmDashboardUrl 'http://rm-iclone1.testnet.red-gate.com:19528/' -Verbose
$databasePackage | Publish-DatabaseBuildArtifact -DlmDashboardUrl http://rm-iclone1.testnet.red-gate.com:19528 -Verbose

$UAT = New-DatabaseConnection `
    -ServerInstance "RM-DEV-WKS02.TESTNET.RED-GATE.COM\DEV" `
    -Database "Forex" 

Test-DatabaseConnection -InputObject $UAT

New-DatabaseReleaseArtifact -Source $databasePackage -Target $UAT | `
    Use-DatabaseReleaseArtifact -DeployTo $UAT  -SkipPreUpdateSchemaCheck

   $databasePackage | Publish-DatabaseBuildArtifact -DlmDashboardUrl http://rm-iclone1.testnet.red-gate.com:19528 -Verbose

#$buildArtifact = New-DatabaseBuildArtifact -InputObject $databasePackage -PackageId 1.0 -PackageVersion 4



