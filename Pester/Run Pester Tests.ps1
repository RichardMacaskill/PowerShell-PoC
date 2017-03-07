Import-Module Pester
 
$testsFolder = 'C:\Dev\PowerShell\Pester'
Set-Location  $testsFolder
 
# Run tests for each file
Invoke-Pester "$testsFolder\SQL Configuration.Tests.ps1"