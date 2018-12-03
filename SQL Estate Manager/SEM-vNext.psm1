<#
.SYNOPSIS
  Registers a single SQL Server instance.
.DESCRIPTION
  Registers a single SQL Server instance, to make it available within the SDPS classification UI.
.PARAMETER FullyQualifiedInstanceName
  The fully-qualified name of the SQL Server instance to be registered. For a named instance, this should take the form 'fully-qualified-host-name\instance-name' (e.g. "myserver.mydomain.com\myinstance"). For the default instance on a machine, just the fully-qualified name of the machine will suffice (e.g. "myserver.mydomain.com").
.PARAMETER Force
  When trying to register an instance that is already registered, the default behaviour is to raise an error. Specifying the -Force parameter will suppress such an error.
.EXAMPLE
  Add-RegisteredSqlServerInstance -FullyQualifiedInstanceName 'mysqlserver.mydomain.com\myinstancename'

  Registers an instance of SQL Server named "myinstancename" running on the "mysqlserver.mydomain.com" machine.
.EXAMPLE
  Add-RegisteredSqlServerInstance -FullyQualifiedInstanceName 'mysqlserver.mydomain.com'

  Registers the default instance of SQL Server running on the "mysqlserver.mydomain.com" machine.
.EXAMPLE
  Add-RegisteredSqlServerInstance -FullyQualifiedInstanceName 'mysqlserver.mydomain.com' -Force

  In the previous two examples, an error is raised if the specified SQL Server instance is already registered. Using the -Force parameter will suppress this error.
.EXAMPLE
  @('dbserver1.mydomain.com', 'dbserver2.mydomain.com') | Add-RegisteredSqlServerInstance -Force

  Demonstrates how multiple SQL Server instances in a list can be registered.
.EXAMPLE
  Get-Content -Path '.\myinstances.txt' | Add-RegisteredSqlServerInstance -Force

  Demonstrates how the names of the instances to be registered can be taken from a simple text file. The file should contain one instance name per line.
#>

function Add-RegisteredSqlServerInstance {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeLine = $True)]
        [string] $FullyQualifiedInstanceName,
        
        [switch] $Force
    )

    process {
        $ServerRootUrl = 'http://PDM-LTRICHARDM.red-gate.com:15156'
        $AddUrl = "$ServerRootUrl/api/instances"

        $PostData = @{
            InstanceFqdn = $FullyQualifiedInstanceName
        }
        $PostJson = $PostData | ConvertTo-Json

        try {
            $Response = Invoke-RestMethod -Uri $AddUrl -UseDefaultCredentials -Method Post -Body $PostJson -ContentType 'application/json'
            Write-Host "$FullyQualifiedInstanceName added successfully."
        }
        catch {
            $ErrorObject = $_.Exception
            $Response = $_.Exception.Response
            if ($Response) {
                $StatusCode = $Response.StatusCode
                if ($StatusCode) {
                    $StatusCodeValue = $StatusCode.value__
                    if ($StatusCodeValue) {
                        switch ($StatusCode.value__) {
                            417 {
                                $ErrorObject = 'The application encountered an error connecting to the database.' 
                            }
                            409 {
                                if ($Force.IsPresent) {
                                    Write-Host "$FullyQualifiedInstanceName was already added."
                                    $ErrorObject = $Null
                                } else {
                                    $ErrorObject = 'A name conflict occured when adding this instance. Please check if it has already been added.'
                                }
                            }
                            default {
                                $ErrorObject = "Response code: $StatusCodeValue" 
                            }
                        }
                    }
                }
            }

            if ($ErrorObject) {
                Write-Error $ErrorObject
            }
        }
    }
}


Export-ModuleMember -Function Add-RegisteredSqlServerInstance