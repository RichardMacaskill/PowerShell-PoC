
$scriptsFolder = 'C:\Dev\Git\LightningWorks\lightningworks\db\Forex'
$validatedSchema = Invoke-DlmDatabaseSchemaValidation -InputObject $scriptsFolder
$documentation = $validatedSchema | New-DlmDatabaseDocumentation
$databasePackage = New-DlmDatabasePackage $validatedSchema -PackageId 1.0.0 -Documentation $documentation -PackageDescription 'My new database package'
Publish-DlmDatabasePackage -InputObject $databasePackage -DlmDashboardUrl 'http://pdm-ltrichardm:19528' -Verbose