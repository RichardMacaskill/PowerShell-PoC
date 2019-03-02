######Script by Richard Murphy Trend Micro#################################################################################################################

##Prompt the user for the Application Database they would like to clone####################################################################################
$appdb = Read-Host -Prompt 'Select Application Database you would like to containerize and clone. Must be one of TesdtDB1 TesdtDB2 TesdtDB3'

######Note Images with the $ImageName variable values below need to be pre-created on your SQL CLone server###############################################

If($appdb -Match 'TestDB1')
	{$ImageName = 'TestDB1img'
	$CloneName = 'TestDB1Clone'}
ElseIf($appdb -Match 'TestDB2')
	{$ImageName = 'TestDB2img'
	$CloneName = 'TestDB2Clone'}
ElseIf($appdb -Match 'TestDB3')
	{$ImageName = 'TestDB3img'
	$CloneName = 'TestDB3Clone'}
Else{Write-Host "App Database not in Catalogue"
	exit}

##Prompt the use for that SQL version they require in their container####################################################################################

$sqlversion = Read-Host -Prompt 'Enter required SQL version. Must be one of 2012 2014 2016'
$containerimg = "mssql-" + $sqlversion 

##Call on Windocks to create the Container###############################################################################################################

Write-Host "Creating SQL Container Version "$sqlversion 

$output = docker run -d $containerimg

	$returnValues = $output.Split("&") 

	# Gets " ContainerPort = ***** "
	# Sanitizes $portString to just "*****"
	$portString = $returnValues | where { $_ -match "ContainerPort" }
$dbPort = $portString.Split("=")[1].Trim()

# repeat for dbPass
$passString = $returnValues | where { $_ -match "MSSQLServerSaPassword" }
$dbPass = $passString.Split("=")[1].Trim()

Write-Host "Container Created"

##Import the SQL CLone Powershell Module################################################################################################################

Write-Host "Importing Required Modules"
Import-Module -Name C:\"Program Files (x86)"\"Red Gate"\"SQL Clone PowerShell Client"\RedGate.SqlClone.Powershell
Write-Host "Modules Imported"

##Connect to your Clone Server##########################################################################################################################

Write-Host "Connecting to Clone Server"

##Add your Clone Server into a variable and connect ####################################################################################################
$SQLCloneServer = 'http://10.xxx.xxx.xxx:14145'

Connect-SqlClone -Server $SQLCloneServer 
$Image = Get-SqlCloneImage -Name $ImageName

##Connect to your target################################################################################################################################
##Important Step here - The port number of your container needs to be preceded by a comma###############################################################

$InstanceName = "," + $dbPort.ToString()
$MachineName = hostname

##Connect to your target SQL Instance###################################################################################################################

$SqlServerInstance = Get-SqlCloneSqlServerInstance -MachineName $MachineName -InstanceName $InstanceName

##Generate Clone########################################################################################################################################

Write-Host "Cloning Source Database "$appdb 

$Image | New-SqlClone -Name $CloneName -Location $SqlServerInstance | Wait-SqlCloneOperation

Write-Host "Clone Complete"

##Provide Summary with connection details###############################################################################################################

$message = "Please connect to your SQL Container using the following connection string : "

$message  + $MachineName + "," + $dbPort
Write-Host "The sa password is " $dbPass