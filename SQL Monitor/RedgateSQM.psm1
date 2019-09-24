# powershell client
# http://rm-iclone1.testnet.red-gate.com:8080/

<#
	.SYNOPSIS
	Configures the SQL Monitor client with an Authorization Token to use for the Web API.
	Initialize must be called once before any other Cmdlets will work.
	.EXAMPLE
	Initialize -AuthToken "GeneratedAuthenticationToken"
	
	Initializes the SQL Monitor client with the given Authorization Token.
#>
function Initialize {
	param(
		[Parameter(Mandatory = $true)] [string]
		# The API Authorization Token 
	 	$AuthToken
	)

	$Global:RootURL = 'http://rm-iclone1.testnet.red-gate.com:8080/api/v1'
	$authHeader = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
	$authHeader.Add("Authorization", "Bearer $AuthToken")
	$Global:AuthHeader = $authHeader
}


$global:AlertTypes = @{
	MachineUnreachable = 7
	SqlServerUnreachable = 8
	MonitoringStoppedMachineCredentials = 36
	MonitoringStoppedSqlCredentials = 37
	DatabaseUnavailable = 16
	AvailabilityGroupListenerOffline = 43
	AvailabilityGroupReplicaNotHealthy = 46
	AvailabilityGroupDatabaseNotHealthy = 48
	LimitedSampling = 35
	MonitoringErrorMachineDataCollection = 38
	MonitoringErrorSqlServerDataCollection = 39
	CustomMetric = 40
	ClusterFailover = 3
	AvailabilityGroupFailover = 42
	AvailabilityGroupNotHealthy = 47
	LowDiskSpaceAlerter = 9
	SqlJobFailure = 6
	SqlErrorLog = 2
	HighDtuAzureSqlDb = 54
	HighCpu = 1
	HighCpuAzureSqlDb = 52
	LowMemorySpaceAlerter = 10
	HighMemoryAzureSqlDb = 53
	HighDataIoAzureSqlDb = 55
	HighLogIoAzureSqlDb = 56
	HighCpuElasticPool = 62
	HighDtuElasticPool = 63
	HighDataIoElasticPool = 64
	HighLogIoElasticPool = 65
	HighWorkerPercentageAzureElasticPool = 60
	HighWorkerPercentageAzureSqlDb = 58
	HighSessionPercentageAzureElasticPool = 59
	HighSessionPercentageAzureSqlDb = 57
	SqlDeadlockXe = 49
	SqlDeadlock = 4
	AvailabilityGroupReplicaFallingBehind = 45
	AvailabilityGroupDelayedQuery = 44
	ClockSkew = 25
	DatabaseNotBackedUp = 14
	DatabaseNotLogBackedUp = 15
	DatabaseNotDifferentialBackedUp = 51
	DatabaseFileUsage = 50
	IntegrityCheckOverdue = 18
	FragmentedIndex = 19
	PageVerification = 17
	SqlServerAgentState = 27
	SqlServerBrowserState = 33
	SqlServerReportingState = 28
	SqlServerAnalysisState = 30
	SqlServerIntegrationState = 31
	SqlServerSearchState = 29
	SqlServerWriterState = 34
	DatabaseSizeAzureSqlDb = 61
	SqlBlockingProcessAlerter = 11
	SqlLongRunningQueryAlerter = 12
	JobDurationUnusual = 24
	LowCpu = 5
	SqlJobCancelled = 66
}

$global:DatabaseAlertTypes = @{
	DatabaseUnavailable = 16
	CustomMetric = 40
	DatabaseNotBackedUp = 14
	DatabaseNotLogBackedUp = 15
	DatabaseNotDifferentialBackedUp = 51
	DatabaseFileUsage = 50
	IntegrityCheckOverdue = 18
	FragmentedIndex = 19
	PageVerification = 17
}

$global:JobAlertTypes = @{
	SqlJobFailure = 6
	JobDurationUnusual = 24
	SqlJobCancelled = 66
}

$global:DiskAlertTypes = @{
	LowDiskSpaceAlerter = 9
}

$global:InstanceAlertTypes = @{
	SqlServerUnreachable = 8
	MonitoringStoppedSqlCredentials = 37
	DatabaseUnavailable = 16
	LimitedSampling = 35
	MonitoringErrorSqlServerDataCollection = 39
	CustomMetric = 40
	ClusterFailover = 3
	SqlJobFailure = 6
	SqlErrorLog = 2
	SqlDeadlockXe = 49
	SqlDeadlock = 4
	DatabaseNotBackedUp = 14
	DatabaseNotLogBackedUp = 15
	DatabaseNotDifferentialBackedUp = 51
	DatabaseFileUsage = 50
	IntegrityCheckOverdue = 18
	FragmentedIndex = 19
	PageVerification = 17
	SqlServerAgentState = 27
	SqlServerReportingState = 28
	SqlServerAnalysisState = 30
	SqlServerSearchState = 29
	SqlBlockingProcessAlerter = 11
	SqlLongRunningQueryAlerter = 12
	JobDurationUnusual = 24
	SqlJobCancelled = 66
}

$global:ClusterAlertTypes = @{
	MachineUnreachable = 7
	SqlServerUnreachable = 8
	MonitoringStoppedMachineCredentials = 36
	MonitoringStoppedSqlCredentials = 37
	DatabaseUnavailable = 16
	AvailabilityGroupListenerOffline = 43
	AvailabilityGroupReplicaNotHealthy = 46
	AvailabilityGroupDatabaseNotHealthy = 48
	LimitedSampling = 35
	MonitoringErrorMachineDataCollection = 38
	MonitoringErrorSqlServerDataCollection = 39
	CustomMetric = 40
	ClusterFailover = 3
	AvailabilityGroupFailover = 42
	AvailabilityGroupNotHealthy = 47
	LowDiskSpaceAlerter = 9
	SqlJobFailure = 6
	SqlErrorLog = 2
	HighCpu = 1
	LowMemorySpaceAlerter = 10
	SqlDeadlockXe = 49
	SqlDeadlock = 4
	AvailabilityGroupReplicaFallingBehind = 45
	AvailabilityGroupDelayedQuery = 44
	ClockSkew = 25
	DatabaseNotBackedUp = 14
	DatabaseNotLogBackedUp = 15
	DatabaseNotDifferentialBackedUp = 51
	DatabaseFileUsage = 50
	IntegrityCheckOverdue = 18
	FragmentedIndex = 19
	PageVerification = 17
	SqlServerAgentState = 27
	SqlServerBrowserState = 33
	SqlServerReportingState = 28
	SqlServerAnalysisState = 30
	SqlServerIntegrationState = 31
	SqlServerSearchState = 29
	SqlServerWriterState = 34
	SqlBlockingProcessAlerter = 11
	SqlLongRunningQueryAlerter = 12
	JobDurationUnusual = 24
	LowCpu = 5
	SqlJobCancelled = 66
}

$global:StandaloneMachineAlertTypes = @{
	MachineUnreachable = 7
	SqlServerUnreachable = 8
	MonitoringStoppedMachineCredentials = 36
	MonitoringStoppedSqlCredentials = 37
	DatabaseUnavailable = 16
	AvailabilityGroupListenerOffline = 43
	AvailabilityGroupReplicaNotHealthy = 46
	AvailabilityGroupDatabaseNotHealthy = 48
	LimitedSampling = 35
	MonitoringErrorMachineDataCollection = 38
	MonitoringErrorSqlServerDataCollection = 39
	CustomMetric = 40
	ClusterFailover = 3
	AvailabilityGroupFailover = 42
	AvailabilityGroupNotHealthy = 47
	LowDiskSpaceAlerter = 9
	SqlJobFailure = 6
	SqlErrorLog = 2
	HighCpu = 1
	LowMemorySpaceAlerter = 10
	SqlDeadlockXe = 49
	SqlDeadlock = 4
	AvailabilityGroupReplicaFallingBehind = 45
	AvailabilityGroupDelayedQuery = 44
	ClockSkew = 25
	DatabaseNotBackedUp = 14
	DatabaseNotLogBackedUp = 15
	DatabaseNotDifferentialBackedUp = 51
	DatabaseFileUsage = 50
	IntegrityCheckOverdue = 18
	FragmentedIndex = 19
	PageVerification = 17
	SqlServerAgentState = 27
	SqlServerBrowserState = 33
	SqlServerReportingState = 28
	SqlServerAnalysisState = 30
	SqlServerIntegrationState = 31
	SqlServerSearchState = 29
	SqlServerWriterState = 34
	SqlBlockingProcessAlerter = 11
	SqlLongRunningQueryAlerter = 12
	JobDurationUnusual = 24
	LowCpu = 5
	SqlJobCancelled = 66
}

$global:ClusterMachineAlertTypes = @{
	LowDiskSpaceAlerter = 9
}

$global:AgAlertTypes = @{
	AvailabilityGroupListenerOffline = 43
	AvailabilityGroupReplicaNotHealthy = 46
	AvailabilityGroupDatabaseNotHealthy = 48
	AvailabilityGroupFailover = 42
	AvailabilityGroupNotHealthy = 47
	AvailabilityGroupReplicaFallingBehind = 45
	AvailabilityGroupDelayedQuery = 44
}

$global:AzureSqlServerAlertTypes = @{
	MonitoringStoppedSqlCredentials = 37
	MonitoringErrorSqlServerDataCollection = 39
	CustomMetric = 40
	HighDtuAzureSqlDb = 54
	HighCpuAzureSqlDb = 52
	HighMemoryAzureSqlDb = 53
	HighDataIoAzureSqlDb = 55
	HighLogIoAzureSqlDb = 56
	HighCpuElasticPool = 62
	HighDtuElasticPool = 63
	HighDataIoElasticPool = 64
	HighLogIoElasticPool = 65
	HighWorkerPercentageAzureElasticPool = 60
	HighWorkerPercentageAzureSqlDb = 58
	HighSessionPercentageAzureElasticPool = 59
	HighSessionPercentageAzureSqlDb = 57
	SqlDeadlockXe = 49
	DatabaseSizeAzureSqlDb = 61
	SqlBlockingProcessAlerter = 11
	SqlLongRunningQueryAlerter = 12
}

$global:AzureSqlDatabaseAlertTypes = @{
	CustomMetric = 40
	HighDtuAzureSqlDb = 54
	HighCpuAzureSqlDb = 52
	HighMemoryAzureSqlDb = 53
	HighDataIoAzureSqlDb = 55
	HighLogIoAzureSqlDb = 56
	HighWorkerPercentageAzureSqlDb = 58
	HighSessionPercentageAzureSqlDb = 57
	SqlDeadlockXe = 49
	DatabaseSizeAzureSqlDb = 61
	SqlBlockingProcessAlerter = 11
	SqlLongRunningQueryAlerter = 12
}

$global:ElasticPoolAlertTypes = @{
	HighCpuElasticPool = 62
	HighDtuElasticPool = 63
	HighDataIoElasticPool = 64
	HighLogIoElasticPool = 65
	HighWorkerPercentageAzureElasticPool = 60
	HighSessionPercentageAzureElasticPool = 59
}

<#
	.SYNOPSIS
	Gets the details of all of the base monitors in SQL Monitor.
	.EXAMPLE
	$baseMonitor= Get-BaseMonitors

#>
function Get-BaseMonitors {
	$getUrl = "$($RootURL)/basemonitors"
	[BaseMonitor[]] $baseMonitors = Invoke-ApiGet -URL $getUrl

	return $baseMonitors
}

<#
	.SYNOPSIS
	Gets the details of all of the standalone machines monitored by SQL Monitor.
	.EXAMPLE
	$machines = Get-StandaloneMachines

#>
function Get-StandaloneMachines {
    [Machine[]] $allmachines = @()
	$baseMonitors = Get-BaseMonitors
	foreach ($baseMonitor in $baseMonitors)
	{
		[StandaloneMachine[]] $machines = Invoke-ApiGet -URL $baseMonitor.StandaloneMachinesPath()
        $allMachines += $machines
	}
	return $allMachines
}

<#
	.SYNOPSIS
	Gets the details of all of the clusters monitored by SQL Monitor.
	.EXAMPLE
	$clusters = Get-Clusters

#>
function Get-Clusters {
	[Cluster[]] $allClusters = @()
	$baseMonitors = Get-BaseMonitors
	foreach ($baseMonitor in $baseMonitors)
	{
		[Cluster[]] $clusters = Invoke-ApiGet -URL $baseMonitor.ClustersPath()
		$allClusters += $clusters
	}
	return $allClusters
}

<#
	.SYNOPSIS
	Gets the details of all of the disks for the given machine.
	.EXAMPLE
	$disks = Get-Disks -Machine $machine
#>
function Get-DisksForMachine {
	param(
		[Parameter(Mandatory = $true)] [Machine]
		# The machine object
		$Machine
	)
	$disks = Invoke-ApiGet -URL $Machine.DisksPath()
	$disks = $Machine.CastDisks($disks)
	
	return $disks
}

<#
	.SYNOPSIS
	Gets the details of all of the SQL Server instances for the given machine.
	.EXAMPLE
	$instances = Get-InstancesForMachine -Machine $machine
 #>
function Get-InstancesForMachine {
	param(
		[Parameter(Mandatory = $true)] [Machine]
		# The machine object
		$Machine
	)
    $result = Invoke-ApiGet -URL $Machine.InstancesPath()
	$instances = $Machine.CastInstances($result)
	
	return $instances
}

<#
	.SYNOPSIS
	Gets the details of all of the SQL Server instances for the given machines.
	.EXAMPLE
	$instances = Get-InstancesForMachines -Machines $machines
 #>
function Get-InstancesForMachines {
	param(
		[Parameter(Mandatory = $true)] [Machine[]]
		# The machine object
		$Machines
	)

    $instances = @()

    foreach ($machine in $machines)
    {
        $Instances+=Get-InstancesForMachine -Machine $machine
    }

    return $instances
}

<#
	.SYNOPSIS
	Gets the details of all of the SQL Server instances for the given cluster.
	.EXAMPLE
	$instances = Get-InstancesForCluster -Cluster $cluster
#>
function Get-InstancesForCluster {
	param(
		[Parameter(Mandatory = $true)] [Cluster]
		# The cluster object
		$Cluster
	)
	[ClusterInstance[]] $instances = Invoke-ApiGet -URL $Cluster.InstancesPath()

	return $instances
}

<#
	.SYNOPSIS
	Gets the details of all of the machines for the given cluster.
	.EXAMPLE
	$machines = Get-MachinesForCluster -Cluster $cluster
#>
function Get-MachinesForCluster {
	param(
		[Parameter(Mandatory = $true)] [Cluster]
		# The cluster object
		$Cluster
	)
	[ClusterMachine[]] $machines = Invoke-ApiGet -URL $Cluster.MachinesPath()
	
	return $machines
}

<#
	.SYNOPSIS
	Gets the details of all of the availability groups for the given cluster.
	.EXAMPLE
	$ags = Get-AvailabilityGroupsForCluster -Cluster $cluster
 #>
function Get-AvailabilityGroupsForCluster {
	param(
		[Parameter(Mandatory = $true)] [Cluster]
		# The cluster object
		$Cluster
	)
	[AvailabilityGroup[]] $ags = Invoke-ApiGet -URL $Cluster.AvailabilityGroupsPath()
	
	return $ags
}

<#
	.SYNOPSIS
	Gets the details of all of the databases for the given SQL Server instance.
	.EXAMPLE
	$instances = Get-DatabasesForInstance -Instance $instance
 #>
function Get-DatabasesForInstance {
	param(
		[Parameter(Mandatory = $true)] [Instance]
		# The SQL Server Instance object
		$Instance
	)
	$result = Invoke-ApiGet -URL $Instance.DatabasesPath()
	$databases = $Instance.CastDatabases($result)
	
	return $databases	
}

<#
	.SYNOPSIS
	Gets the details of all of the databases for all SQL Server instances.
	.EXAMPLE
	$instances = Get-DatabasesForInstances -Instances $instances
 #>
function Get-DatabasesForInstances {
	param(
		[Parameter(Mandatory = $true)] [Instance[]]
		# Instances of SQL Server
		$instances
	)
    $databases = @()

    foreach ($instance in $instances)
    {
        $databases+=Get-DatabasesForInstance -Instance $instance
    }

    return $databases
}

<#
	.SYNOPSIS
	Gets the details of all of the jobs for the given SQL Server instance.
	.EXAMPLE
	$instances = Get-JobsForInstance -Instance $instance
 #>
function Get-JobsForInstance {
	param(
		[Parameter(Mandatory = $true)] [Instance]
	# The SQL Server Instance object
		$Instance
	)
	$result = Invoke-ApiGet -URL $Instance.JobsPath()
	$jobs = $Instance.CastJobs($result)

	return $jobs
}

<#
	.SYNOPSIS
	Gets the details of all of the Azure SQL Servers monitored by SQL Monitor.
	.EXAMPLE
	$azureSqlServers = Get-AzureSqlServers

#>
function Get-AzureSqlServers {
	[AzureSqlServer[]] $allAzureSqlServers = @()
	$baseMonitors = Get-BaseMonitors
	foreach ($baseMonitor in $baseMonitors)
	{
		[AzureSqlServer[]] $azureSqlServers = Invoke-ApiGet -URL $baseMonitor.AzureSqlServersPath()
		$allAzureSqlServers += $azureSqlServers
	}
	return $allAzureSqlServers
}

<#
	.SYNOPSIS
	Gets details of main groups on SQL Monitor
	.EXAMPLE
	$mainGroups = Get-MainGroups
#>
function Get-MainGroups {
	[Group[]] $allGroups = @()
	$baseMonitors = Get-BaseMonitors
	foreach ($baseMonitor in $baseMonitors)
	{
		[Group[]] $groups = Invoke-ApiGet -URL $baseMonitor.GroupsPath()
		$allGroups += $groups
	}
	return $allGroups
}

<#
	.SYNOPSIS
	Gets details of subgroups of a specific group on SQL Monitor
	.EXAMPLE
	$subGroups = Get-SubGroups
#>
function Get-SubGroups {
	param(
		[Parameter(Mandatory = $true)] [Group]
		# Group object
		$Group
	)
	[Group[]] $groups = Invoke-ApiGet -URL $Group.SubGroupsPath()
	return $groups
}

<#
	.SYNOPSIS
	Gets the details of all of the databases for the given Azure SQL Server.
	.EXAMPLE
	$azureSqlDatabases = Get-DatabasesForAzureSqlServer -Server $azureSqlServer

#>
function Get-DatabasesForAzureSqlServer {
	param(
		[Parameter(Mandatory = $true)] [AzureSqlServer]
	# The Azure SQL server object
		$Server
	)
	[AzureSqlDatabase[]] $databases = Invoke-ApiGet -URL $Server.DatabasesPath()
	return $databases
}

<#
	.SYNOPSIS
	Gets the details of all of the elastic pools for the given Azure SQL Server.
	.EXAMPLE
	$elasticPools = Get-ElasticPoolsForAzureSqlServer -Server $azureSqlServer
	
 #>
function Get-ElasticPoolsForAzureSqlServer {
	param(
		[Parameter(Mandatory = $true)] [AzureSqlServer]
	# The Azure SQL server object
		$Server
	)
	
	[ElasticPool[]] $elasticPools = Invoke-ApiGet -URL $Server.ElasticPoolsPath()
	return $elasticPools
}

<#
	.SYNOPSIS
	Gets the alert settings for a specific monitored object and alert type.
	.EXAMPLE
	$alertSettings = Get-AlertSettings -MonitoredObject $cluster -AlertType $ClusterAlertTypes["SqlServerUnreachable"]

#>
function Get-AlertSettings {
	param(
		[Parameter(Mandatory = $true)] [MonitoredObject] $MonitoredObject,
		# The object to be configured (e.g. cluster, disk, database etc)
		[Parameter(Mandatory = $true)] [int32] $AlertType
		# The id of the alert type
	)

	try	{
		return Invoke-ApiGet -URL "$($MonitoredObject.Path() )/alertsettings/$AlertType" -ErrorAction Stop
	} catch {
		Find-InvalidMonitoredObject -MonitoredObject $MonitoredObject
		throw
	}
}

<#
	.SYNOPSIS
	Updates the status of the alert configuration for a specific monitored object and alert type.
	.EXAMPLE
	Update-AlertSettingsStatus -MonitoredObject $cluster -AlertType $ClusterAlertTypes["SqlServerUnreachable"] -Status "Disabled"

#>
function Update-AlertSettingsStatus {
	param(
		[Parameter(Mandatory = $true)] [MonitoredObject]
		# The object to be configured (e.g. cluster, disk, database etc)
		$MonitoredObject,
		[Parameter(Mandatory = $true)] [int32]
		# The id of the alert type
		$AlertType,
		[Parameter(Mandatory = $true)] [string]
		# The status to set the alert to ("Inherited" or "Disabled")
		$Status
	)
	Invoke-ApiPatch -URL "$($MonitoredObject.Path())/alertsettings/$AlertType/status" -Body $Status
}

<#
	.SYNOPSIS
	Updates the comments of the alert configuration for a specific monitored object and alert type.
	.EXAMPLE
	Update-AlertSettingsComments -MonitoredObject $cluster -AlertType $ClusterAlertTypes["SqlServerUnreachable"] -Comments "..."

#>
function Update-AlertSettingsComments {
	param(
		[Parameter(Mandatory = $true)] [MonitoredObject]
		# The object to be configured (e.g. cluster, disk, database etc)
		$MonitoredObject,
		[Parameter(Mandatory = $true)] [int32]
		# The id of the alert type
		$AlertType,
		[Parameter(Mandatory = $false)] [string]
		# The comments for the alert
		$Comments
	)
	Invoke-ApiPatch -URL "$($MonitoredObject.Path())/alertsettings/$AlertType/comments" -Body $Comments
}

<#
	.SYNOPSIS
	Enumeration containing all the email notification options that can be specified.
	.EXAMPLE
    $notificationsettings = [NotificationSettings] @{
		EmailNotificationOption = [EmailNotificationOption]::SendToCustom
		EmailAddresses = , "foo@bar.com"
		SlackEnabled = $false
		SnmpEnabled = $null # to leave a property as it is, ensure it has a null value
	}
#>
enum EmailNotificationOption
{
    DontEmail
    SendToDefault
    SendToCustom
}

<#
	.SYNOPSIS
	Class containing all the properties that can be customized.
	.EXAMPLE
    $notificationsettings = [NotificationSettings] @{
		EmailNotificationOption = [EmailNotificationOption]::SendToCustom
		EmailAddresses = , "foo@bar.com"
		SlackEnabled = $false
		SnmpEnabled = $null # to leave a property as it is, ensure it has a null value
	}
#>
class NotificationSettings {
    [Nullable[EmailNotificationOption]] $EMailNotificationOption = $null
    [String[]] $EmailAddresses = $null
    [Nullable[Boolean]] $SlackEnabled = $null
    [Nullable[Boolean]] $SnmpEnabled = $null
}

<#
	.SYNOPSIS
	Customizes the alert notification configuration for a specific monitored object and alert type.
	.EXAMPLE
    $notificationsettings = @{
        EmailNotificationOption = [EmailNotificationOption]::SendToCustom
        EmailAddresses = 'foo.bar@companymail.com', 'monkey.banana@companymail.com'
        SlackEnabled = $true
		SnmpEnabled = null # to leave a setting unchanged, simply leave as null
    }
	Update-AlertNotificationSettings -MonitoredObject $database -AlertType $DatabaseAlertTypes["DatabaseFileUsage"] -Settings $notificationsettings
#>
function Update-AlertNotificationSettings {
	param(
		[Parameter(Mandatory = $true)] [MonitoredObject]
		# The object to be configured (e.g. cluster, disk, database etc)
		$MonitoredObject,
		[Parameter(Mandatory = $true)] [int32]
		# The id of the alert type
		$AlertType,
		[Parameter(Mandatory = $true)] [PSCustomObject]
		# The configuration to apply
		$Settings
	)
	Invoke-ApiPatch -URL "$($MonitoredObject.Path())/alertsettings/$AlertType/notificationsettings" -Body $Settings
}

<#
    .SYNOPSIS
    Adds the given monitored entity to SQL Monitor.

    .EXAMPLE 
    Add-MonitoredEntity -MonitoredEntity "localhost" -BaseMonitor $BaseMonitor
#>
function Add-MonitoredEntity {
	Param(
		[Parameter(Mandatory=$True)]
		[string]
		# The address of the monitored entity e.g. "localhost"
		$MonitoredEntity,
		[Parameter(Mandatory=$True)]
		[BaseMonitor] 
		# The base monitor to add the monitored entity to
		$BaseMonitor,
		[string]
		# Group name to put server into, e.g. [1 - Production]
		$Group,
		[string]
		# The Windows UserName to connect to the windows host, if not supplied, using Base Monitor Service account
		$WindowsUserName,
		[string]
		# The Windows Password to connect to the windows host, if not supplied, using Base Monitor Service account
		$WindowsPassword,
		[ValidateSet('windows','sqlserver', 'inherit')]
		[string]
		# "windows" or "sqlServer" or "inherit", the last option uses the credentials supplied for Windows username/password or Base Monitor Service credentials
		$SqlServerAuthenticationMode = 'inherit',
		[string]
		# SQL login username to connect to SQL Server instance with
		$SqlServerUserName,
		[string]
		# SQL login password to connect to SQL Server instance with
		$SqlServerPassword
	)

	$InheritBaseMonitorAccount = [string]::IsNullOrWhiteSpace($WindowsUserName)
	$UseSameCredentialsAsHostMachine = $SqlServerAuthenticationMode -eq 'inherit'
	$AuthenticationMode = If ($AuthenticationMode -eq 'sqlserver') {"sqlserver"} Else {"windows"}

	$body = @(
	@{
		group = $Group;
		SqlServers = $MonitoredEntity;
		WindowsMachineCredentials=
		@{
			IsBaseMonitorAccount = $InheritBaseMonitorAccount;
			UserName = $WindowsUserName;
			Password = $WindowsPassword
		};
		SqlServerCredentials =
		@{
			IsSameAsWindowsCredentials = $UseSameCredentialsAsHostMachine;
			AuthenticationMode = $AuthenticationMode;
			UserName = $SqlServerUserName;
			Password = $SqlServerPassword
		}
	}
	)

	Invoke-ApiPost -URL "$($BaseMonitor.Path())/monitoredservers" -Body $body
}

<#
    .Synopsis
    Removes the given monitored entity from SQL Monitor.

    .Example 
    Remove-MonitoredEntity -MonitoredEntity "localhost" -BaseMonitor $BaseMonitor -DeleteData $True
#>
function Remove-MonitoredEntity {
	Param(
		[Parameter(Mandatory=$True)]
		[string]
		# The address of the monitored entity e.g. "localhost"
		$MonitoredEntity,
		[Parameter(Mandatory=$True)]
		[BaseMonitor]
		# The base monitor to remove the monitored entity from
		$BaseMonitor,
		[Parameter(Mandatory=$True)]
		[bool]
		# Whether to remove associated data from SQL Monitor when removing the monitored entity
		$DeleteData
	)
	$body = @{
		Name = $MonitoredEntity;
		DeleteData = $DeleteData;
	}
	
	Invoke-ApiDelete -URL "$($BaseMonitor.Path())/monitoredservers" -Body $body	
}

function Invoke-ApiGet {
	param(
		[Parameter(Mandatory = $true)] [string] $URL
	)	
	return Invoke-RestMethod -Uri $URL -Method Get -Headers $authHeader	
}

function Handle-ApiError {
	param(
		$exception,
		$URL
	)

	Write-Host "$URL didn't work"
	$Response = $exception.Exception.Response

	if ($Response) {
		$StatusCode = $Response.StatusCode
		Write-Host "$StatusCode Returned"
	}
}

function Find-InvalidMonitoredObject {
	param(
		[Parameter(Mandatory = $true)] [MonitoredObject] $MonitoredObject
	)
	$current = $MonitoredObject
	$failed = $null
	while($current -ne $null) {
		try {
			Invoke-WebRequest -Uri $current.Path() -Method Get -Headers $authHeader -ErrorAction Stop
			break
		} catch {
			$failed = $current
		} finally {
			$current = $current.Parent()
		}
	}
	
	$alias = @{}
	$alias.Add((New-Object BaseMonitor).GetType().Name, "base monitor")
	$alias.Add((New-Object StandaloneMachine).GetType().Name, "standalone machine")
	$alias.Add((New-Object ClusterMachine).GetType().Name, "node")
	$alias.Add((New-Object Cluster).GetType().Name, "cluster")
	$alias.Add((New-Object AzureSqlServer).GetType().Name, "Azure SQL Server")
	$alias.Add((New-Object AzureSqlDatabase).GetType().Name, "database")
	$alias.Add((New-Object ElasticPool).GetType().Name, "elastic pool")
	$alias.Add((New-Object Group).GetType().Name, "group")
	$alias.Add((New-Object ClusterInstance).GetType().Name, "SQL Server instance")
	$alias.Add((New-Object MachineInstance).GetType().Name, "SQL Server instance")
	$alias.Add((New-Object AvailabilityGroup).GetType().Name, "availability group")
	$alias.Add((New-Object Database).GetType().Name, "database")
	$alias.Add((New-Object Disk).GetType().Name, "disk")
	$alias.Add((New-Object Job).GetType().Name, "job")	
	if ($failed -and $failed.Parent()) {
		Write-Error "$($failed.Name) is not a valid $($alias[$failed.GetType().Name]) of the $($alias[$failed.Parent().GetType().Name]) $($failed.Parent().Name)"
	}
}

function Invoke-ApiPatch {
	param(
		[Parameter(Mandatory = $true)] [string] $URL,
		[Parameter(Mandatory = $true)] [PSObject] $Body
	)

	$BodyJson = $Body | ConvertTo-Json;
	try {
		Invoke-RestMethod -Uri $URL -ContentType "application/json; charset=utf-8" -Method Patch -Headers $authHeader -Body $BodyJson
	} catch {
		Handle-ApiError -exception $_ -URL $URL
		throw
	}
}

function Invoke-ApiPost {
	param(
		[Parameter(Mandatory = $true)] [string] $URL,
		[Parameter(Mandatory = $true)] [PSObject] $Body
	)

	$BodyJson = $Body | ConvertTo-Json;
	try {
		Invoke-RestMethod -Uri $URL -ContentType "application/json; charset=utf-8" -Method Post -Headers $authHeader -Body $BodyJson
	} catch {
		Handle-ApiError -exception $_ -URL $URL
		throw
	}
}

function Invoke-ApiDelete {
	param(
		[Parameter(Mandatory = $true)] [string] $URL,
		[Parameter(Mandatory = $true)] [PSObject] $Body
	)
	$BodyJson = $Body | ConvertTo-Json;
	try	{
		Invoke-RestMethod -Uri $URL -ContentType "application/json; charset=utf-8" -Method Delete -Headers $authHeader -Body $BodyJson
	} catch {
		Handle-ApiError -exception $_ -URL $URL
		throw
	}
}

class MonitoredObject {
	[String] $Name
	MonitoredObject() {
		if($this.GetType() -eq [MonitoredObject]){
			throw("Class should not be instantiated")
		}
	}
	[String] Path() {
		throw("Class MonitoredObject must be inherited")
	}
	
	hidden [MonitoredObject] Parent() {
		return $null
	}
}

class BaseMonitor : MonitoredObject {
	hidden [String] Path() {
		return "$($Global:RootURL)/basemonitors/$($this.Name)"
	}
	
	hidden [String] StandaloneMachinesPath() {
		return "$($this.Path())/standalonemachines"
	}

	hidden [String] ClustersPath() {
		return "$($this.Path())/clusters"
	}

	hidden [String] AzureSqlServersPath() {
		return "$($this.Path())/azuresqlservers"
	}
	
	hidden [String] GroupsPath() {
    	return "$($this.Path())/groups"
    }
}

class Machine : MonitoredObject{
	Machine() {
		if ($this.GetType() -eq [Machine]){
			throw("Class should not be instantiated")
		}
	}
	hidden [String] Path() {
		throw("Class Machine must be inherited")
	}
	hidden [String] DisksPath() {
		return "$($this.Path())/disks"
	}
	
	hidden [String] InstancesPath() {
		return "$($this.Path())/instances"
	}
	
	
}

class StandaloneMachine : Machine {
	[BaseMonitor] $BaseMonitor
	hidden [String] Path() {
		return "$($this.BaseMonitor.StandaloneMachinesPath())/$($this.Name)"
	}

	hidden [MonitoredObject] Parent() {
		return $this.BaseMonitor
	}
	
    hidden [Instance[]] CastInstances([PSCustomObject[]] $result) {
        [Instance[]] $instances = @()
        foreach ($element in $result) {
			$instance = $this.CastInstance($element)
            $instances += $instance
        }
        return $instances
    }

	hidden [Instance] CastInstance([PSCustomObject] $result) {
		$instance = New-Object MachineInstance
		$instance.Machine = [StandaloneMachine]$result.Machine
		$instance.Name = $result.Name
		return $instance
	}

	hidden [Disk[]] CastDisks([PSCustomObject[]] $result) {
		[Disk[]] $disks = @()
		foreach ($element in $result) {
			$disk = New-Object Disk
			$disk.Machine = [StandaloneMachine]$element.Machine
			$disk.Name = $element.Name
			$disks += $disk
		}
		return $disks
	}
}

class ClusterMachine : Machine {
	[Cluster] $Cluster
	hidden [String] Path() {
		return "$($this.Cluster.MachinesPath())/$($this.Name)"
	}
	
	hidden [MonitoredObject] Parent() {
		return $this.Cluster
	}
	
	hidden [Instance[]] CastInstances([PSCustomObject[]] $result)
	{
		[Instance[]]$instances = @()
		foreach ($element in $result)
		{
			$instance = $this.CastInstance($element)
			$instances += $instance
		}
		return $instances
	}

	hidden [Instance] CastInstance([PSCustomObject] $result) {
		$instance = New-Object MachineInstance
		$instance.Machine = [ClusterMachine]$result.Machine
		$instance.Name = $result.Name
		return $instance
	}

	hidden [Disk[]] CastDisks([PSCustomObject[]] $result) {
		[Disk[]] $disks = @()
		foreach ($element in $result) {
			$disk = New-Object Disk
			$disk.Machine = [ClusterMachine]$element.Machine
			$disk.Name = $element.Name
			$disks += $disk
		}
		return $disks
	}
}

class Cluster : MonitoredObject{
	[BaseMonitor] $BaseMonitor
	hidden [String] Path() {
		return "$($this.BaseMonitor.ClustersPath())/$($this.Name)"
	}

	hidden [MonitoredObject] Parent() {
		return $this.BaseMonitor
	}
	
	hidden [String] InstancesPath() {
		return "$($this.Path())/instances"
	}
	
	hidden [String] MachinesPath() {
		return "$($this.Path())/machines"
	}
	
	hidden [String] AvailabilityGroupsPath() {
		return "$($this.Path())/availabilitygroups"
	}
}

class Instance : MonitoredObject{
	Instance(){
		if($this.GetType() -eq [Instance]){
			throw("Class should not be instantiated")
		}
	}
	hidden [String] Path() {
		throw("Class Instance must be inherited")
	}
	
	hidden [String] DatabasesPath() {
		return "$($this.Path())/databases"
	}

	hidden [String] JobsPath() {
		return "$($this.Path())/jobs"
	}
}

class AzureSqlServer : MonitoredObject {
	[BaseMonitor] $BaseMonitor
	hidden [String] Path() {
		return "$($this.BaseMonitor.AzureSqlServersPath())/$($this.Name)"
	}

	hidden [MonitoredObject] Parent() {
		return $this.BaseMonitor
	}

	hidden [String] DatabasesPath() {
		return "$($this.path())/databases"
	}
	
	hidden [String] ElasticPoolsPath() {
		return "$($this.path())/elasticpools"
	}
}

class AzureSqlDatabase : MonitoredObject {
	[AzureSqlServer] $AzureSqlServer
	hidden [String] Path() {
		return "$($this.AzureSqlServer.DatabasesPath())/$($this.Name)"
	}

	hidden [MonitoredObject] Parent() {
		return $this.AzureSqlServer
	}
}

class ElasticPool : MonitoredObject {
	[AzureSqlServer] $AzureSqlServer
	hidden [String] Path() {
		return "$($this.AzureSqlServer.ElasticPoolsPath())/$($this.Name)"
	}

	hidden [MonitoredObject] Parent() {
		return $this.AzureSqlServer
	}
}

class Group : MonitoredObject {
	[BaseMonitor] $BaseMonitor
	[String] $Id
	[String] $ParentId
	hidden [String] Path() {
		return "$($this.BaseMonitor.GroupsPath())/$($this.Id)"
	}

	hidden [MonitoredObject] Parent() {
		return $this.BaseMonitor
	}
	
	hidden [String] SubGroupsPath() {
		return "$($this.Path())/groups"
	}
}

class ClusterInstance : Instance {
	[Cluster] $Cluster
	hidden [String] Path() {
		return "$($this.Cluster.InstancesPath())/$($this.Name)"
	}

	hidden [MonitoredObject] Parent() {
		return $this.Cluster
	}
	
	hidden [Database[]] CastDatabases([PSCustomObject[]] $result) {
		[Database[]] $databases = @()
		foreach ($element in $result){
			$database = New-Object Database
			$database.Instance = [ClusterInstance]$element.Instance
			$database.Name = $element.Name
			$databases += $database
		}
		return $databases
	}

	hidden [Job[]] CastJobs([PSCustomObject[]] $result) {
		[Job[]] $jobs = @()
		foreach ($element in $result){
			$job = New-Object Job
			$job.Instance = [ClusterInstance]$element.Instance
			$job.Name = $element.Name
			$jobs += $job
		}
		return $jobs
	}
}

class MachineInstance : Instance {
	[Machine] $Machine
	hidden [String] Path() {
		return "$($this.Machine.InstancesPath())/$($this.Name)"
	}

	hidden [MonitoredObject] Parent() {
		return $this.Machine
	}
	
	hidden [Database[]] CastDatabases([PSCustomObject[]] $result) {
		[Database[]] $databases = @()
		foreach ($element in $result){
			$database = New-Object Database
			$database.Instance = $this.Machine.CastInstance($element.Instance) 
			$database.Name = $element.Name
			$databases += $database
		}
		return $databases
	}

	hidden [Job[]] CastJobs([PSCustomObject[]] $result) {
		[Job[]] $jobs = @()
		foreach ($element in $result){
			$job = New-Object Job
			$job.Instance = $this.Machine.CastInstance($element.Instance)
			$job.Name = $element.Name
			$jobs += $job
		}
		return $jobs
	}
}

class AvailabilityGroup : MonitoredObject{
	[Cluster] $Cluster
	hidden [String] Path(){
		return "$($this.Cluster.AvailabilityGroupsPath())/$($this.Name)"
	}

	hidden [MonitoredObject] Parent() {
		return $this.Cluster
	}
}

class Database : MonitoredObject{
	[Instance] $Instance
	hidden [String] Path() {
		return "$($this.Instance.DatabasesPath())/$($this.Name)"
	}

	hidden [MonitoredObject] Parent() {
		return $this.Instance
	}
}

class Disk : MonitoredObject{
	[Machine] $Machine
	hidden [String] Path() {
		return "$($this.Machine.DisksPath())/$($this.Name)"
	}

	hidden [MonitoredObject] Parent() {
		return $this.Machine
	}
}

class Job : MonitoredObject{
	[Instance] $Instance
	hidden [String] Path() {
		return "$($this.Instance.JobsPath())/$($this.Name)"
	}

	hidden [MonitoredObject] Parent() {
		return $this.Instance
	}
}

class AlertType{
	[String] $Name
	[int32] $Id
}

Export-ModuleMember -function Initialize
Export-ModuleMember -function Get-BaseMonitors
Export-ModuleMember -function Get-StandaloneMachines
Export-ModuleMember -function Get-Clusters
Export-ModuleMember -function Get-DisksForMachine
Export-ModuleMember -function Get-InstancesForMachine
Export-ModuleMember -function Get-InstancesForMachines
Export-ModuleMember -function Get-InstancesForCluster
Export-ModuleMember -function Get-MachinesForCluster
Export-ModuleMember -function Get-AvailabilityGroupsForCluster
Export-ModuleMember -function Get-DatabasesForInstance
Export-ModuleMember -function Get-DatabasesForInstances
Export-ModuleMember -function Get-JobsForInstance
Export-ModuleMember -function Get-AzureSqlServers
Export-ModuleMember -function Get-DatabasesForAzureSqlServer
Export-ModuleMember -function Get-ElasticPoolsForAzureSqlServer
Export-ModuleMember -function Get-MainGroups
Export-ModuleMember -function Get-SubGroups
Export-ModuleMember -function Get-AlertSettings
Export-ModuleMember -function Update-AlertSettingsStatus
Export-ModuleMember -function Update-AlertSettingsComments
Export-ModuleMember -function Update-AlertNotificationSettings
Export-ModuleMember -function Add-MonitoredEntity
Export-ModuleMember -function Remove-MonitoredEntity
