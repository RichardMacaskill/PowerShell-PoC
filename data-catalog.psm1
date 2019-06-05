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

    $classificationURL = 'https://rm-win10-sql201.testnet.red-gate.com:15156/'
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
        $AddUrl = "api/instances"

        $PostData = @{
            InstanceFqdn = $FullyQualifiedInstanceName
            UserId       = $UserId
            Password     = $Password
        }
        $PostJson = $PostData | ConvertTo-Json

        Invoke-ApiCall -Uri $AddUrl -Method Post -Body $PostJson
        Write-Host "Instance $FullyQualifiedInstanceName added successfully."
    }
}

<#
.SYNOPSIS
  Updates authentication details for a single SQL Server instance.
.DESCRIPTION
  Updates authentication details for a single SQL Server instance, i.e. userId and password for SQL Server authentication.
.PARAMETER FullyQualifiedInstanceName
  The fully-qualified name of the SQL Server instance to be registered. For a named instance, this should take the form 'fully-qualified-host-name\instance-name' (e.g. "myserver.mydomain.com\myinstance"). For the default instance on a machine, just the fully-qualified name of the machine will suffice (e.g. "myserver.mydomain.com").
.PARAMETER UserId
  Used only for SQL Server Authentication. Known also as "user name". Optional, do not provide for Windows Authentication.
.PARAMETER Password
  Used only for SQL Server Authentication. Optional, do not provide for Windows Authentication.
.EXAMPLE
  Update-RegisteredSqlServerInstance -FullyQualifiedInstanceName 'mysqlserver.mydomain.com\myinstancename'

  Sets an authentication method to Windows Authentication for a registered instance of SQL Server named "myinstancename" running on the "mysqlserver.mydomain.com" machine.
.EXAMPLE
  Update-RegisteredSqlServerInstance -FullyQualifiedInstanceName 'mysqlserver.mydomain.com\myinstancename' -UserId 'somebody' -Password 'myPassword'

  Sets an authentication method to SQL Server Authentication with given userId and password for a registered instance of SQL Server named "myinstancename" running on the "mysqlserver.mydomain.com" machine.
#>

function Update-RegisteredSqlServerInstance {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeLine = $True)]
        [string] $FullyQualifiedInstanceName,

        [string] $UserId = $null,
        [string] $Password = $null
    )

    process {
        $instanceId = Get-InstanceIdByName $FullyQualifiedInstanceName
        $url =
        "api/instances/" + $instanceId +
        "/update"

        $PostData = @{
            UserId   = $UserId
            Password = $Password
        }
        $PostJson = $PostData | ConvertTo-Json

        Invoke-ApiCall -Uri $url -Method Post -Body $PostJson
        Write-Host "Instance $FullyQualifiedInstanceName updated successfully."
    }
}


function Get-HashResult {
    param(
        $array,
        $key,
        $value
    )

    $hash = @{ }

    foreach ($item in $array) {
        $hash.Add($item.$key, $item.$value)
    }
    return  $hash
}


function Invoke-ApiCall {
    param(
        $Uri,
        $Method,
        $Body,
        $OutFile
    )

    if ($null -eq $ClassificationURL) {
        throw 'Run Use-Classification before using any other cmdlet. For help run: Get-Help Use-Classification'
    }

    $Uri = $ClassificationURL + $Uri

    try {
        return Invoke-RestMethod -Uri $Uri -Method $Method -Headers $ClassificationAuthHeader `
            -Body $Body -ContentType 'application/json; charset=utf-8' -OutFile $OutFile
    }
    catch {
        $ErrorObject = $_.Exception
        $Response = $_.Exception.Response
        if ($Response) {
            $result = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($result)
            $reader.BaseStream.Position = 0
            $reader.DiscardBufferedData()
            $responseBody = $reader.ReadToEnd();
            Write-Error $responseBody
        }

        if ($ErrorObject) {
            Write-Error $ErrorObject
        }
    }
}


function Get-TagCategories {
    $url = "api/tagcategories"
    $tagcategories = Invoke-ApiCall -Uri $url -Method Get

    $hash = @{ }

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

    $url = "api/tagcategories/" + $tagCategoryId + '/tags'
    $tags = Invoke-ApiCall -Uri $url -Method Get
    return  Get-HashResult -array $tags -key 'name' -value 'id'
}

function Get-RegisteredInstances {
    $url = "api/instances"
    $instances = Invoke-ApiCall -Uri $url -Method Get

    $hash = @{ }

    foreach ($instance in $instances) {
        $hash.Add($instance.instance.name, $instance.instance.id)
    }
    return  $hash
}

function Get-InstanceIdByName {
    param(
        $instanceName
    )
    $instances = Get-RegisteredInstances
    if (!$instances.ContainsKey($instanceName)) {
        Write-Error "Instance $instanceName not found."
        return
    }
    return $instances[$instanceName]
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
    $instanceId = Get-InstanceIdByName $instanceName

    $url =
    "api/instances/" + $instanceId +
    "/databases/" + [uri]::EscapeDataString($databaseName) +
    "/columns"
    $columnResult = Invoke-ApiCall -Uri $url -Method Get

    foreach ($classifiedColumn in $columnResult.ClassifiedColumns) {
        $classifiedColumn | Add-Member NoteProperty 'InstanceId' $instanceId
        $classifiedColumn | Add-Member NoteProperty 'DatabaseName' $databaseName
    }
    return $columnResult.ClassifiedColumns
}

function Get-ColumnTags {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)] [object] $column
    )

    $url =
    "api/instances/" + $column.instanceId +
    "/databases/" + [uri]::EscapeDataString($column.databaseName) +
    "/schemas/" + [uri]::EscapeDataString($column.schemaName) +
    "/tables/" + [uri]::EscapeDataString($column.tableName) +
    "/columns/" + [uri]::EscapeDataString($column.columnName) +
    "/tags"

    return Invoke-ApiCall -Uri $url -Method GET
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

        $tagIds = New-Object System.Collections.ArrayList(, @( $columnTagIds | ForEach-Object { $_.id } ))

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
            $singleValueCategory = $columnTagIds | Where-Object { $_.categoryId -eq $tagCategory.id }
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
        $url =
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
        Invoke-ApiCall -Uri $url -Method PUT -Body $body
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
    $destinationInstanceId = Get-InstanceIdByName $instanceName
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
    $url = 'api/columns/bulk-classification'
    $body = @{
        ColumnIdentifiers  = $columns
        TagIds             = $tagIds.ToArray()
        FreeTextAttributes = @{ }
    }
    $body = $body | ConvertTo-Json;
    Invoke-ApiCall -Uri $url -Method PUT -Body $body
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
    $instanceId = Get-InstanceIdByName $instanceName
    if ($databaseName) {
        $url =
        "api/instances/" + $instanceId +
        "/databases/" + [uri]::EscapeDataString($databaseName) +
        "/columns/all?format=csv"
    }
    else {
        $url =
        "api/instances/" + $instanceId +
        "/columns/all?format=csv"
    }
    Invoke-ApiCall -Uri $url -Method Get -OutFile $exportFile
}

function Update-Classification {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)] $cmd,
        [string] $name,
        [string] $value = $null
    )
    try {
        $cmd.Parameters["@name"].Value = $name
        if ([string]::IsNullOrEmpty($value)) {
            if ($cmd.Parameters.Contains("@value")) {
                $cmd.Parameters.RemoveAt("@value")
            }
            $cmd.CommandType = [System.Data.CommandType]::StoredProcedure
            $cmd.CommandText = "sys.sp_dropextendedproperty"
        }
        else {
            $cmd.Parameters["@value"].Value = $value
            $cmd.CommandType = [System.Data.CommandType]::Text
            $cmd.CommandText = "IF EXISTS (SELECT 1
            FROM sys.columns c
            INNER JOIN sys.objects o ON c.object_id = o.object_id
            INNER JOIN sys.schemas s ON o.schema_id = s.schema_id
            INNER JOIN sys.extended_properties xp ON xp.major_id = o.object_id AND xp.minor_id = c.column_id
            WHERE xp.name = @name AND c.name = @level2name AND o.name = @level1name AND s.name = @level0name)
              EXEC sp_updateextendedproperty @name = @name, @level0type = 'schema', @level0name = @level0name, @level1type = 'table',
                  @level1name = @level1name, @level2type = 'column', @level2name = @level2name, @value = @value
            ELSE
              EXEC sp_addextendedproperty @name = @name, @level0type = 'schema', @level0name = @level0name, @level1type = 'table',
                  @level1name = @level1name, @level2type = 'column', @level2name = @level2name, @value = @value"
        }
        $cmd.ExecuteNonQuery()
    }
    catch {
        Write-Host $_.Exception.Message
    }
}

<#
.SYNOPSIS
  Push sensitivity label and information type for columns of a given database from Data Catalog to the database's extended properties.
.PARAMETER instanceName
  Fully qualified domain name of the instance
.PARAMETER databaseName
  Name of the database
.PARAMETER userName
  User name. Do not use this parameter for Windows Authentication
.PARAMETER password
  Password. Do not use this parameter for Windows Authentication
.PARAMETER forceUpdate
  Use this flag to overwrite any existing classification stored in extended properties by the classification from the SQL Data Catalog.
  Note that any unassigned classifications in Data Catalog will also remove the classifications in extended properties.
.EXAMPLE
  Import-Module .\RedgateDataCatalog.psm1
  Use-Classification -ClassificationAuthToken "auth-token"
  Export-ClassificationExtendedProperties -instanceName "sqlserver\sql2016" -databaseName "WideWorldImporters" -user "admin" -password "P@ssword123" -forceUpdate
#>
function Export-ClassificationExtendedProperties {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [string] $instanceName,
        [Parameter(Mandatory = $true)] [string] $databaseName,
        [string] $userName = $null,
        [string] $password = $null,
        [switch] $forceUpdate
    )

    $infoTypes = @{ }
    $infoTypes.Add("Banking", "8A462631-4130-0A31-9A52-C6A9CA125F92")
    $infoTypes.Add("Contact Info", "5C503E21-22C6-81FA-620B-F369B8EC38D1")
    $infoTypes.Add("Credentials", "C64ABA7B-3A3E-95B6-535D-3BC535DA5A59")
    $infoTypes.Add("Credit Card", "D22FA6E9-5EE4-3BDE-4C2B-A409604C4646")
    $infoTypes.Add("Date Of Birth", "3DE7CC52-710D-4E96-7E20-4D5188D2590C")
    $infoTypes.Add("Financial", "C44193E1-0E58-4B2A-9001-F7D6E7BC1373")
    $infoTypes.Add("Health", "6E2C5B18-97CF-3073-27AB-F12F87493DA7")
    $infoTypes.Add("Name", "57845286-7598-22F5-9659-15B24AEB125E")
    $infoTypes.Add("National ID", "6F5A11A7-08B1-19C3-59E5-8C89CF4F8444")
    $infoTypes.Add("Networking", "B40AD280-0F6A-6CA8-11BA-2F1A08651FCF")
    $infoTypes.Add("SSN", "D936EC2C-04A4-9CF7-44C2-378A96456C61")
    $infoTypes.Add("Other", "9C5B4809-0CCC-0637-6547-91A6F8BB609D")

    $sensitivityLabels = @{ }
    $sensitivityLabels.Add("Public", "1866CA45-1973-4C28-9D12-04D407F147AD")
    $sensitivityLabels.Add("General", "684A0DB2-D514-49D8-8C0C-DF84A7B083EB")
    $sensitivityLabels.Add("Confidential", "331F0B13-76B5-2F1B-A77B-DEF5A73C73C2")
    $sensitivityLabels.Add("Confidential - GDPR", "989ADC05-3F3F-0588-A635-F475B994915B")
    $sensitivityLabels.Add("Highly Confidential", "B82CE05B-60A9-4CF3-8A8A-D6A0BB76E903")
    $sensitivityLabels.Add("Highly Confidential - GDPR", "3302AE7F-B8AC-46BC-97F8-378828781EFD")

    $credentials = ""
    if ([string]::IsNullOrEmpty($userName)) {
        $credentials = "Integrated Security=True"
    }
    else {
        $credentials = "User ID=$userName; Password=$password"
    }
    $classifiedColumns = Get-Columns -instanceName $instanceName -databaseName $databaseName

    $connection = New-Object System.Data.SqlClient.SqlConnection
    $connection.ConnectionString = "Server=$instanceName; Database=$databaseName; $credentials"
    $connection.Open()

    $cmd = New-Object System.Data.SqlClient.SqlCommand

    $cmd.Connection = $connection
    $cmd.CommandText = "SELECT 1 FROM sys.all_objects WHERE type = 'P' AND name = 'sp_addextendedproperty'"
    $exists = $cmd.ExecuteScalar()
    if ($null -eq $exists) {
        $connection.Close()
        Write-Host "Database does not support extended properties"
        return
    }
    $cmd.Parameters.AddWithValue("@level0type", 'Schema')
    $cmd.Parameters.AddWithValue("@level1type", 'Table')
    $cmd.Parameters.AddWithValue("@level2type", 'Column')
    $cmd.Parameters.AddWithValue("@value", $null)
    $cmd.Parameters.AddWithValue("@name", '')
    $cmd.Parameters.AddWithValue("@level0name", '')
    $cmd.Parameters.AddWithValue("@level1name", '')
    $cmd.Parameters.AddWithValue("@level2name", '')

    Foreach ($col in $classifiedColumns) {
        $cmd.Parameters["@level0name"].Value = $col.schemaName
        $cmd.Parameters["@level1name"].Value = $col.tableName
        $cmd.Parameters["@level2name"].Value = $col.columnName

        if ($forceUpdate -eq $true) {
            Update-Classification -cmd $cmd -name 'sys_information_type_name' -value $col.informationType
            if ([string]::IsNullOrEmpty($col.informationType)) {
                Update-Classification -cmd $cmd -name 'sys_information_type_id'
            }
            else {
                Update-Classification -cmd $cmd -name 'sys_information_type_id' -value $infoTypes[$col.informationType]
            }
            Update-Classification -cmd $cmd -name 'sys_sensitivity_label_name' -value $col.sensitivityLabel
            if ([string]::IsNullOrEmpty($col.sensitivityLabel)) {
                Update-Classification -cmd $cmd -name 'sys_sensitivity_label_id'
            }
            else {
                Update-Classification -cmd $cmd -name 'sys_sensitivity_label_id' -value $sensitivityLabels[$col.sensitivityLabel]
            }
        }
        else {
            if (-Not [string]::IsNullOrEmpty($col.InformationType)) {
                try {
                    $cmd.CommandType = [System.Data.CommandType]::StoredProcedure
                    $cmd.Parameters["@value"].Value = $infoTypes[$col.informationType]
                    $cmd.Parameters["@name"].Value = 'sys_information_type_id'
                    $cmd.CommandText = "sys.sp_addextendedproperty"
                    $cmd.ExecuteNonQuery()

                    $cmd.Parameters["@value"].Value = $col.informationType
                    $cmd.Parameters["@name"].Value = 'sys_information_type_name'
                    $cmd.CommandText = "sys.sp_addextendedproperty"
                    $cmd.ExecuteNonQuery()
                }
                catch {
                    Write-Host $_.Exception.Message
                }
            }

            if (-Not [string]::IsNullOrEmpty($col.SensitivityLabel)) {
                try {
                    $cmd.CommandType = [System.Data.CommandType]::StoredProcedure
                    $cmd.Parameters["@value"].Value = $sensitivityLabels[$col.sensitivityLabel]
                    $cmd.Parameters["@name"].Value = 'sys_sensitivity_label_id'
                    $cmd.CommandText = "sys.sp_addextendedproperty"
                    $cmd.ExecuteNonQuery()

                    $cmd.Parameters["@value"].Value = $col.sensitivityLabel
                    $cmd.Parameters["@name"].Value = 'sys_sensitivity_label_name'
                    $cmd.CommandText = "sys.sp_addextendedproperty"
                    $cmd.ExecuteNonQuery()
                }
                catch {
                    Write-Host $_.Exception.Message
                }
            }
        }
    }
    $connection.Close()
}

<#
.SYNOPSIS
  Enables authorization using Active Directory groups and users.
.PARAMETER fullAccessActiveDirectoryUserOrGroup
  Active Directory user or group that will be granted full access to the Data Catalog.
.EXAMPLE
  Import-Module .\RedgateDataCatalog.psm1
  Use-Classification -ClassificationAuthToken "auth-token"
  Enable-Authorization -fullAccessActiveDirectoryUserOrGroup "SqlDataCatalog-FullAccess"
#>
function Enable-Authorization {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [string] $fullAccessActiveDirectoryUserOrGroup
    )

    $url = "api/permissions"
    $body = @{
        ActiveDirectoryPrincipal = $fullAccessActiveDirectoryUserOrGroup
		Role = 1
    } | ConvertTo-Json
    Invoke-ApiCall -Uri $url -Method PUT -Body $body
}

Export-ModuleMember -Function Use-Classification
Export-ModuleMember -Function Add-RegisteredSqlServerInstance
Export-ModuleMember -Function Update-RegisteredSqlServerInstance
Export-ModuleMember -Function Get-Columns
Export-ModuleMember -Function Update-ColumnTags
Export-ModuleMember -Function Import-ColumnsTags
Export-ModuleMember -Function Copy-DatabaseClassification
Export-ModuleMember -Function Export-ClassificationCsv
Export-ModuleMember -Function Export-ClassificationExtendedProperties
Export-ModuleMember -Function Enable-Authorization
