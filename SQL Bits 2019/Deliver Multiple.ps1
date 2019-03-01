# Script to create a new SQL Clone database on each of my connected machines matching a name pattern
Clear-Host
Import-Module -Name SqlChangeAutomation
Import-Module -Name RedGate.SqlClone.PowerShell

# dot source the invoke-parallel function 
. "C:\Dev\Git\PowerShell-PoC\Utils\PowerShell\Invoke-Parallel.ps1"

$WorkItem = "(SQL Bits 2019 is Awesome)"

$SQLCloneServer= "http://rm-win10-sql201.testnet.red-gate.com:14145"

Connect-SqlClone -ServerUrl $SQLCloneServer

$ForumsImage = Get-SqlCloneImage -Name  'Redgate Forums Masked (SQL Bits)'
$TradesImage = Get-SqlCloneImage -Name  'TradesDataMart-2019-02-28'
$ForexImage = Get-SqlCloneImage -Name  'Forex-2019-02-28'

$ForumsCloneName = 'Redgate Forums (masked) ' + $WorkItem
$TradesCloneName = 'TradesDataMart ' + $WorkItem
$ForexCloneName = 'Forex ' + $WorkItem

# I have several SQL Server instances registered on my SQL Clone Server - I want to deliver a copy to all of them
$Destinations = Get-SqlCloneSqlServerInstance | 
Where-Object -FilterScript { $_.Server -like '*WKS*' -and $_.Instance -eq 'Dev' }

$Template = Get-SqlCloneTemplate -Image $ForumsImage -Name "Update permissions for Dev"

# Start a timer
$elapsed = [System.Diagnostics.Stopwatch]::StartNew()

"Started at {0}, creating clone databases for image ""{1}""" -f $(get-date) , $ForumsImage.Name 

 $Destinations | Invoke-Parallel -ImportModules -ImportVariables -ScriptBlock {
    $ForumsImage | New-SqlClone -Name $ForumsCloneName -Template $Template -Location $_  | Wait-SqlCloneOperation

    $TradesImage | New-SqlClone -Name $TradesCloneName  -Location $_  | Wait-SqlCloneOperation
    
    $ForexImage | New-SqlClone -Name $ForexCloneName  -Location $_  | Wait-SqlCloneOperation
        
    "Created clone in instance {0}" -f $_.Server + '\' + $_.Instance;

}


$scriptsFolder = 'C:\Dev\Git\RedgateForums'

$validatedSchema = Invoke-DatabaseBuild -InputObject $scriptsFolder

$buildArtifact = New-DatabaseBuildArtifact -InputObject $validatedSchema `
-PackageId 1.0.0.1 -PackageVersion 1.0.0.1

# These target databases are clones, so I _know_ that a release that's good for one is good for all
$Target = New-DatabaseConnection `
-ServerInstance "RM-DEV-WKS01.TESTNET.RED-GATE.COM\DEV" `
-Database $ForumsCloneName

$Release = New-DatabaseReleaseArtifact -Source $buildArtifact -Target $Target

$Destinations | ForEach-Object { `

$InstanceName = $_.Server + ".TESTNET.RED-GATE.COM\DEV"
$DevInstance = New-DatabaseConnection `
-ServerInstance $InstanceName `
-Database $ForumsCloneName

Test-DatabaseConnection -InputObject $DevInstance

Use-DatabaseReleaseArtifact -InputObject $Release -DeployTo $DevInstance  -SkipPreUpdateSchemaCheck

}

"Total Elapsed Time: {0}" -f $($elapsed.Elapsed.ToString()) 