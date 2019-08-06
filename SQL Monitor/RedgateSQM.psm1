# powershell client
# http://rm-iclone1.testnet.red-gate.com:8080/

<#
	.SYNOPSIS
	Configures the SQL Monitor client with an Authorization Token to use for the Web API.
	.EXAMPLE
	Initialize -AuthToken "MTo2NDBkZjllNC02MjAzLTRiZTctYTUxNi12NzI5MmUxYzliNmQ="
	
	Initializes the SQL Monitor client with the given Authorization Token.
#>
function Initialize {
	param(
		[Parameter(Mandatory = $true)] [string]
		# The API Authorization Token 
	 	$AuthToken
	)

	$Global:RootURL = 'http://rm-iclone1.testnet.red-gate.com:8080/'
	$authHeader = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
	$authHeader.Add("Authorization", "Bearer $AuthToken")
	$Global:AuthHeader = $authHeader

}

<#
	.SYNOPSIS
	Gets details of all machines monitored by SQL Monitor
	.EXAMPLE
	$machines = $machines = Get-Machines

#>
function Get-Machines {
	$getUrl = $RootURL + "api/v1/machines"
	$machines = Invoke-ApiGet -URL $getUrl

	return $machines
}

<#
	.SYNOPSIS
	Gets details of all disks for the given machine
	.EXAMPLE
	$disks = Get-Disks -MachineName $machine.Name
#>
function Get-Disks {
	param(
		[Parameter(Mandatory = $true)] [string]
		# The name of the machine
		$MachineName
	)
	$getUrl = $RootURL + "api/v1/machines/" + $MachineName + "/disks"
	$disks = Invoke-ApiGet -URL $getUrl

	return $disks
}

<#
	.SYNOPSIS
	Gets the current alert settings for a given machine, disk, and alert type
	.EXAMPLE
	$settings = Get-AlertSettings -MachineName $machine.Name -DiskName $disk.Name -AlertType 9
#>
function Get-AlertSettings {
param(
		[Parameter(Mandatory = $true)] [string] 
		# The name of the machine
		$MachineName,
		[Parameter(Mandatory = $true)] [string] 
		# The name of the disk
		$DiskName,
		[Parameter(Mandatory = $true)] [int32] 
		# The id of the alert type
		$AlertType
	)
	$getUrl = $RootURL + "api/v1/machines/" + $MachineName + "/disks/" + $DiskName + "/alertsettings/" + $AlertType
	$settings = Invoke-ApiGet -URL $getURL

	return $settings
}

<#
	.SYNOPSIS
	Updates the alert settings for a given machine, disk, and alert type
	.EXAMPLE
	Update-AlertSettings -MachineName $machine.Name -DiskName $disk.Name -AlertType 9 -Status "Disabled" | Out-Null
	.EXAMPLE
	Update-AlertSettings -MachineName $machine.Name -DiskName $disk.Name -AlertType 9 -Status "Inherited" | Out-Null
#>
function Update-AlertSettings {
param(
	[Parameter(Mandatory = $true)] [string]
	# The name of the machine
	$MachineName,
	[Parameter(Mandatory = $true)] [string]
	# The name of the disk
	$DiskName,
	[Parameter(Mandatory = $true)] [int32]
	# The id of the alert type
	$AlertType,
	[Parameter(Mandatory = $true)] [string]
	# The status to set the alert to ("Inherited" or "Disabled")
	$Status
	)
	$getUrl = $RootURL + "api/v1/machines/" + $MachineName + "/disks/" + $DiskName + "/alertsettings/" + $AlertType
	$body = @{
            Status = $Status
        }
	Invoke-ApiPatch -URL $getURL -Body $body
}


function Invoke-ApiGet {
	param(
		[Parameter(Mandatory = $true)] [string] $URL
	)

	return Invoke-RestMethod -Uri $URL -Method Get -Headers $authHeader
}

function Invoke-ApiPatch {
	param(
		[Parameter(Mandatory = $true)] [string] $URL,
		[Parameter(Mandatory = $true)] [PSObject] $Body
	)

	$BodyJson = $Body | ConvertTo-Json;
	Invoke-RestMethod -Uri $URL -ContentType "application/json; charset=utf-8" -Method Patch -Headers $authHeader -Body $BodyJson
}

Export-ModuleMember -function Initialize
Export-ModuleMember -function Get-Machines
Export-ModuleMember -function Get-Disks
Export-ModuleMember -function Get-AlertSettings
Export-ModuleMember -function Update-AlertSettings