<#
  For more information and a worked example refer to https://www.red-gate.com/data-catalog/classify-with-powershell .
#>


<#
.SYNOPSIS
  Initialise authentication for SDPS.
.DESCRIPTION
  Allows other commandlets to authenticate with the API using $ClassificationAuthToken parameter.
.PARAMETER ClassificationAuthToken
  Authentication token which can be obtained from the Web Client. Please refer to https://www.red-gate.com/data-catalog/working-with-rest-api for more information.
.EXAMPLE
  Import-Module .\RedgateDataCatalog.psm1
  Use-Classification -ClassificationAuthToken "auth-token"

  Allows other commandlets to authenticate with the API using $ClassificationAuthToken parameter.
#>

function Use-Classification {
    param(
        [Parameter(Mandatory = $true)] $ClassificationAuthToken
    )

    $classificationURL = 'http://rm-win10-sql201.testnet.red-gate.com:15156/'
    $authHeader = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $authHeader.Add("Authorization", "Bearer $ClassificationAuthToken")

    $Script:ClassificationURL = $classificationURL
    $Script:ClassificationAuthHeader = $authHeader

    $Script:allTagCategories = Get-TagCategories
}

<#
.SYNOPSIS
  Registers a single SQL Server instance.
.DESCRIPTION
  Registers a single SQL Server instance, to make it available within the SDPS classification UI.
.PARAMETER FullyQualifiedInstanceName
  The fully-qualified name of the SQL Server instance to be registered. For a named instance, this should take the form 'fully-qualified-host-name\instance-name' (e.g. "myserver.mydomain.com\myinstance"). For the default instance on a machine, just the fully-qualified name of the machine will suffice (e.g. "myserver.mydomain.com").
.PARAMETER UserId
  Used only for SQL Server Authentication. Known also as "user name". Optional, do not provide for Windows Authentication.
.PARAMETER Password
  Used only for SQL Server Authentication. Optional, do not provide for Windows Authentication.
.PARAMETER Force
  When trying to register an instance that is already registered, the default behaviour is to raise an error. Specifying the -Force parameter will suppress such an error.
.EXAMPLE
  Add-RegisteredSqlServerInstance -FullyQualifiedInstanceName 'mysqlserver.mydomain.com\myinstancename'

  Registers an instance of SQL Server named "myinstancename" running on the "mysqlserver.mydomain.com" machine. Windows Authentication will be used to connect to this intance.
.EXAMPLE
  Add-RegisteredSqlServerInstance -FullyQualifiedInstanceName 'mysqlserver.mydomain.com'

  Registers the default instance of SQL Server running on the "mysqlserver.mydomain.com" machine. Windows Authentication will be used to connect to this intance.
.EXAMPLE
  Add-RegisteredSqlServerInstance -FullyQualifiedInstanceName 'mysqlserver.mydomain.com\myinstancename' -UserId 'somebody' -Password 'myPassword'

  Registers an instance of SQL Server named "myinstancename" running on the "mysqlserver.mydomain.com" machine. SQL Server Authentication will be used to connect to this intance.
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

        [string] $UserId = $null,
        [string] $Password = $null,
        [switch] $Force
    )

    process {
        $ServerRootUrl = $ClassificationURL
        $AddUrl = $ServerRootUrl + "api/instances"

        $PostData = @{
            InstanceFqdn = $FullyQualifiedInstanceName
            UserId       = $UserId
            Password     = $Password
        }
        $PostJson = $PostData | ConvertTo-Json

        try {
            $Response = Invoke-RestMethod -Uri $AddUrl -Headers $ClassificationAuthHeader -Method Post -Body $PostJson -ContentType 'application/json'
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
                            401 {
                                $ErrorObject = 'Provided auth token is not valid.'
                            }
                            417 {
                                $ErrorObject = 'The application encountered an error connecting to the database.'
                            }
                            409 {
                                if ($Force.IsPresent) {
                                    Write-Host "$FullyQualifiedInstanceName was already added."
                                    $ErrorObject = $Null
                                }
                                else {
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


function Get-HashResult {
    param(
        $array,
        $key,
        $value
    )

    $hash = @{}

    foreach ($item in $array) {
        $hash.Add($item.$key, $item.$value)
    }
    return  $hash
}


function Get-TagCategories {
    $url = $ClassificationURL + "api/tagcategories"
    $tagcategories = Invoke-RestMethod -Uri $url -Method Get -Headers $ClassificationAuthHeader

    $hash = @{}

    foreach ($tagcategory in $tagcategories) {
        $tags = Get-Tags -tagCategoryId $tagcategory.id

        $tagcategoryWithTags = New-Object PSObject -Property @{
            Id            = $tagcategory.id
            Name          = $tagcategory.name
            IsMultiValued = $tagcategory.IsMultiValued
            Tags          = $tags
        }
        $hash.Add($tagcategory.name, $tagcategoryWithTags)
    }
    return  $hash
}

function Get-Tags {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)] [string] $tagCategoryId
    )

    $url = $ClassificationURL + "api/tagcategories/" + $tagCategoryId + '/tags'
    $tags = Invoke-RestMethod -Uri $url -Method Get -Headers $ClassificationAuthHeader
    return  Get-HashResult -array $tags -key 'name' -value 'id'
}


function Get-RegisteredInstances {
    $url = $ClassificationURL + "api/instances"
    $instances = Invoke-RestMethod -Uri $url -Method Get -Headers $ClassificationAuthHeader

    $hash = @{}

    foreach ($instance in $instances) {
        $hash.Add($instance.instance.name, $instance.instance.id)
    }
    return  $hash
}

<#
.SYNOPSIS
  Gets all columns for a given database.
.DESCRIPTION
  Gets all columns for a given database.

  # Available column properties:
  # - ColumnName
  # - TableName
  # - SchemaName
  # - Description
  # - InformationType
  # - SensitivityLabel
  # - Tags
  # - FreeTextAttributes
  # - TableRowCount
  # - DataType

.PARAMETER InstanceName
  The fully-qualified name of the SQL Server instance. For a named instance, this should take the form 'fully-qualified-host-name\instance-name' (e.g. "myserver.mydomain.com\myinstance"). For the default instance on a machine, just the fully-qualified name of the machine will suffice (e.g. "myserver.mydomain.com").
.PARAMETER DatabaseName
  Database name to fetch columns from.
.EXAMPLE
  Get-Columns -instanceName "sqlserver\sql2016" -databaseName "WideWorldImporters"

  Fetches all columns from instance "sqlserver\sql2016" database "WideWorldImporters".
#>
function Get-Columns {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)] [string] $instanceName,
        [Parameter(ValueFromPipeline)] [string] $databaseName
    )
    $instances = Get-RegisteredInstances
    $instanceId = $instances[$instanceName]
    $url = $ClassificationURL +
    "api/instances/" + $instanceId +
    "/databases/" + [uri]::EscapeDataString($databaseName) +
    "/columns"
    $columnResult = Invoke-RestMethod -Uri $url -Method Get -Headers $ClassificationAuthHeader
    return $columnResult.ClassifiedColumns
}


function Get-ColumnTags {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)] [object] $column
    )

    $url = $ClassificationURL +
    "api/instances/" + $column.instanceId +
    "/databases/" + [uri]::EscapeDataString($column.databaseName) +
    "/schemas/" + [uri]::EscapeDataString($column.schemaName) +
    "/tables/" + [uri]::EscapeDataString($column.tableName) +
    "/columns/" + [uri]::EscapeDataString($column.columnName) +
    "/tags"

    return Invoke-RestMethod -Uri $url  -ContentType "application/json" -Method GET -Headers $ClassificationAuthHeader
}

<#
.SYNOPSIS
  Update column with the tags specified.
.DESCRIPTION
  Update column with the tags specified. Only one tag category will be updated.
.PARAMETER Column
  Column to update tags.
.PARAMETER Category
  Name of tag category e.g. "Sensitivity".
.PARAMETER Tags
  Names of tags e.g. @("Confidential - GDPR")
  Can be used with multi tags e.g. @("GDPR", "HIPPA")
.PARAMETER ForceUpdate
  Switch to force update column tag.
  When used: will remove any existing tags in that category on that column before assigning the given tags.
  When not used: 
     For sigle tag category, if a tag is provided, will throw error if the column has been assigned with different tag.
     For multi tag category, tags provided will be added to existing assigned tags.
.EXAMPLE
  Import-Module .\RedgateDataCatalog.psm1
  Use-Classification -ClassificationAuthToken "auth-token"
  $allColumns = Get-Columns -instanceName "sqlserver\sql2016" -databaseName "WideWorldImporters"

  $emailColumns  = $allColumns | Where-Object {$_.ColumnName -like "email"}
  $emailColumns | Update-ColumnTags -category "Sensitivity" -tags @("Confidential - GDPR")
  $emailColumns | Update-ColumnTags -category "Information Type" -tags @("Contact Info")

  Updates all columns with name like email to  Sensitivity - "Confidential - GDPR" and "Information Type" - "Contact Info".
#>
function Update-ColumnTags {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)] [object] $column,
        [Parameter(Mandatory = $true)] [string] $category,
        [string[]] $tags,
        [switch] $forceUpdate
    )

    process {
        $columnTags = $column | Get-ColumnTags
        $columnTagIds = $columnTags.Tags

        $tagCategory = $allTagCategories[$category]

        $tagIds = New-Object System.Collections.ArrayList(, @( $columnTagIds | ForEach-Object {$_.id} ))

        if ($tagCategory.IsMultiValued -eq $true) {
            # clear tag category for multi tag
            if ($forceUpdate) {
                foreach ($tagIdToRemove in $tagCategory.Tags.Values) {
                    if ($tagIds -contains $tagIdToRemove) {
                        $tagIds.Remove($tagIdToRemove)
                    }
                }
            }

            foreach ($tag in $tags) {
                $tagId = $tagCategory.Tags[$tag]
                if ( -Not ($columnTagIds.id -contains $tagId)) {
                    $tagIds.Add($tagId)
                }
            }
            if ($tagIds.Count -le 0) {
                return
            }
        }
        else {
            if ($tags.Count -gt 1) {
                $errorMessage = "Tag category: " + $tagCategory.Name + " can accept only one tag"
                Write-Error -Message $errorMessage -Category InvalidArgument
                return
            }
            $singleValueCategory = $columnTagIds | Where-Object {$_.categoryId -eq $tagCategory.id}
            $tagId = $tagCategory.Tags[$tags]
            if ($singleValueCategory) {
                if ($singleValueCategory.id -eq $tagId ) {
                    return
                }
                else {
                    if ($forceUpdate) {
                        $tagIds.Remove($singleValueCategory.id)
                        $tagIds.AddRange($tagId)
                    }
                    else {
                        $errorMessage = "Error :" +
                        " database: " + $column.databaseName +
                        " schema: " + $column.schemaName +
                        " table: " + $column.tableName +
                        " column: " + $column.columnName +
                        " Has already been assigned to " + $tagCategory.Name
                        Write-Error -Message $errorMessage -Category InvalidArgument
                        return
                    }
                }
            }
            else {
                $tagIds.AddRange($tagId)
            }
        }

        Update-ColumnWithTagIds -column $column -tagIds $tagIds.ToArray()
    }
}

function Update-ColumnWithTagIds {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline, Mandatory = $true)] [object] $column,
        [string[]] $tagIds
    )
    process {
        $url = $ClassificationURL +
        "api/instances/" + $column.instanceId +
        "/databases/" + [uri]::EscapeDataString($column.databaseName) +
        "/schemas/" + [uri]::EscapeDataString($column.schemaName) +
        "/tables/" + [uri]::EscapeDataString($column.tableName) +
        "/columns/" + [uri]::EscapeDataString($column.columnName) +
        "/tags"
        $body = @{
            TagIds = $tagIds
        }
        $body = $body | ConvertTo-Json;
        Invoke-RestMethod -Uri $url  -ContentType "application/json" -Method PUT -Headers $ClassificationAuthHeader -Body $body
    }
}

<#
.SYNOPSIS
  Copy classification across database with same schema.
.DESCRIPTION
  Copy classification across database with same schema.
.PARAMETER SourceInstanceName
  The fully-qualified name of the source SQL Server instance. For a named instance, this should take the form 'fully-qualified-host-name\instance-name' (e.g. "myserver.mydomain.com\myinstance"). For the default instance on a machine, just the fully-qualified name of the machine will suffice (e.g. "myserver.mydomain.com").
.PARAMETER SourceDatabaseName
  Source database name.
.PARAMETER DestinationInstanceName
  The fully-qualified name of the destination SQL Server instance. For a named instance, this should take the form 'fully-qualified-host-name\instance-name' (e.g. "myserver.mydomain.com\myinstance"). For the default instance on a machine, just the fully-qualified name of the machine will suffice (e.g. "myserver.mydomain.com").
.PARAMETER SourceDatabaseName
  Destination database name.
.EXAMPLE
  Import-Module .\RedgateDataCatalog.psm1
  Use-Classification -ClassificationAuthToken "auth-token"
  
  Copy-DatabaseClassification -sourceInstanceName "(local)\MSSQL2017" -sourceDatabaseName "sourceDB" -destinationInstanceName "(local)\MSSQL2017" -destinationDatabaseName "destinationDB"
#>
function Copy-DatabaseClassification {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [string] $sourceInstanceName,
        [Parameter(Mandatory = $true)] [string] $sourceDatabaseName,
        [Parameter(Mandatory = $true)] [string] $destinationInstanceName,
        [Parameter(Mandatory = $true)] [string] $destinationDatabaseName
    )
    $classifiedColumns = Get-Columns -instanceName $sourceInstanceName -databaseName $sourceDatabaseName
    $instances = Get-RegisteredInstances 
    $destinationInstanceId = $instances[$destinationInstanceName]
    foreach ($column in $classifiedColumns) {
        $column.instanceId = $destinationInstanceId
        $column.databaseName = $destinationDatabaseName
        $tagIds = $column.tags.id
        Update-ColumnWithTagIds -column $column -tagIds $tagIds
    }
}

<#
.SYNOPSIS
  Bulk update columns with tags supplied.
.DESCRIPTION
  Bulk update columns with tags supplied, will overwrite existing tags.
.PARAMETER Columns
  Array of columns to bulk update.
.PARAMETER Categories
  Array of Category with its tags e.g.
  $categories = @{
    "Sensitivity" =  @("Confidential - GDPR")
    "Information Type" = @("Contact Info")
  }
.EXAMPLE
  Import-Module .\RedgateDataCatalog.psm1
  Use-Classification -ClassificationAuthToken "auth-token"
  $allColumns = Get-Columns -instanceName "sqlserver\sql2016" -databaseName "WideWorldImporters"
  
  $peopleTableColumns = $allColumns | Where-Object {$_.SchemaName -eq "Application" -and $_.TableName -eq "People" }
  $categories = @{
    "Sensitivity" =  @("Confidential - GDPR")
    "Information Type" = @("Contact Info")
  }
  Import-ColumnsTags -columns $peopleTableColumns -categories $categories
#>
function Import-ColumnsTags {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [object[]] $columns,
        [Parameter(Mandatory = $true)] [hashtable] $categories
    )

    $tagIds = New-Object System.Collections.ArrayList(, @( ))
    foreach ($category in $categories.Keys) {
        $tags = $categories[$category]
        $tagCategory = $allTagCategories[$category]

        if ($tagCategory.IsMultiValued -eq $true) {
            foreach ($tag in $tags) {
                $tagId = $tagCategory.Tags[$tag]
                $tagIds.Add($tagCategory.Tags[$tag])
            }
            if ($tagIds.Count -le 0) {
                return
            }
        }
        else {
            if ($tags.Count -gt 1) {
                $errorMessage = "Tag category: " + $tagCategory.Name + " can accept only one tag"
                Write-Error -Message $errorMessage -Category InvalidArgument
                return
            }
            $tagId = $tagCategory.Tags[$tags]
            $tagIds.AddRange($tagId)
        }
    }
    $url = $ClassificationURL + 'api/columns/bulk-classification'
    $body = @{
        ColumnIdentifiers  = $columns
        TagIds             = $tagIds.ToArray()
        FreeTextAttributes = @{}
    }
    $body = $body | ConvertTo-Json;
    Invoke-RestMethod -Uri $url  -ContentType "application/json" -Method PUT -Headers $ClassificationAuthHeader -Body $body
}

<#
.SYNOPSIS
  Export classification in CSV format.
.PARAMETER InstanceName
  The fully-qualified name of the SQL Server instance. For a named instance, this should take the form 'fully-qualified-host-name\instance-name' (e.g. "myserver.mydomain.com\myinstance"). For the default instance on a machine, just the fully-qualified name of the machine will suffice (e.g. "myserver.mydomain.com").
.PARAMETER DatabaseName
  Optional parameter. Database name to fetch columns from. If not specified, all columns on the instance are exported.
.PARAMETER exportFile
  Specifies the csv file. Enter a path and file name. If the path is omitted, the default is the current location.
  If the file exists, it will be overwritten.
.EXAMPLE
  Import-Module .\RedgateDataCatalog.psm1
  Use-Classification -ClassificationAuthToken "auth-token"
  Export-ClassificationCsv -instanceName "sqlserver\sql2016" -databaseName "WideWorldImporters" -exportFile "WideWorldImporters.csv"
  Export-ClassificationCsv -instanceName "sqlserver\sql2016" -exportFile "sql2016.csv"
#>
function Export-ClassificationCsv {
    [CmdletBinding()]
    param(
      [Parameter(Mandatory = $true)] [string] $instanceName,
      [string] $databaseName,
      [Parameter(Mandatory = $true)] [string] $exportFile
    )
    $instances = Get-RegisteredInstances
    $instanceId = $instances[$instanceName]
	if($databaseName) 
	{
		$url = $ClassificationURL +
		"api/instances/" + $instanceId +
		"/databases/" + [uri]::EscapeDataString($databaseName) +
		"/columns/all?format=csv"
	}
	else 
	{
		$url = $ClassificationURL +
		"api/instances/" + $instanceId +
		"/columns/all?format=csv"
	}
    Invoke-RestMethod -Uri $url -Method Get -Headers $ClassificationAuthHeader -OutFile $exportFile
}

Export-ModuleMember -Function Use-Classification
Export-ModuleMember -Function Add-RegisteredSqlServerInstance
Export-ModuleMember -Function Get-Columns
Export-ModuleMember -Function Update-ColumnTags
Export-ModuleMember -Function Import-ColumnsTags
Export-ModuleMember -Function Copy-DatabaseClassification
Export-ModuleMember -Function Export-ClassificationCsv
