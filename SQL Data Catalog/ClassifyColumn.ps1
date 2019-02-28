function Use-Classification {
    param(
        [Parameter(Mandatory = $true)] $ClassificationServer,
        [Parameter(Mandatory = $true)] $ClassificationAuthToken
    )

    $classificationURL = 'http://' + $ClassificationServer + ':15156/'
    $authHeader = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $authHeader.Add("Authorization", "Bearer $ClassificationAuthToken")

    $Script:ClassificationURL = $classificationURL
    $Script:ClassificationAuthHeader = $authHeader

    $Script:allTagCategories = Get-TagCategory
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


function Get-TagCategory {
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


function Get-Instance {
    $url = $ClassificationURL + "api/instances"
    $instances = Invoke-RestMethod -Uri $url -Method Get -Headers $ClassificationAuthHeader

    $hash = @{}

    foreach ($instance in $instances) {
        $hash.Add($instance.instance.name, $instance.instance.id)
    }
    return  $hash
}


function Get-Database {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)] [string] $instanceId
    )
    $url = $ClassificationURL + "api/instances/" + $instanceId + "/databases"
    Write-Host $url
    $databases = Invoke-RestMethod -Uri $url -Method Get -Headers $ClassificationAuthHeader

    $hash = @{}

    foreach ($database in $databases) {
        $tables = Get-Table -instanceId $instanceId -databaseName $database.database.name
        $hash.Add($database.Database.name, $tables)
    }
    return  $hash
}


function Get-Table {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)] [string] $instanceId,
        [Parameter(ValueFromPipeline)] [string] $databaseName
    )
    $url = $ClassificationURL + "api/instances/" + $instanceId + "/databases/" + $databaseName + "/tables"
    $tables = Invoke-RestMethod -Uri $url -Method Get -Headers $ClassificationAuthHeader

    return  Get-HashResult -array $tables -key 'tablename' -value 'tableid'
}


function Get-Columns {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)] [string] $instanceName,
        [Parameter(ValueFromPipeline)] [string] $databaseName
    )
    $columnCount = 200
    $totalColumns = 0
    $columnsResultArray = @()

    $instances = Get-Instance
    $instanceId = $instances[$instanceName]
    Do {
        $url = $ClassificationURL +
        "api/instances/" + $instanceId +
        "/databases/" + $databaseName +
        "/columns?skip=" + $columnsResultArray.Count + "&take=" + $columnCount #+ $([int]::MaxValue)
        $columnResult = Invoke-RestMethod -Uri $url -Method Get -Headers $ClassificationAuthHeader
        $totalColumns = $columnResult.TotalClassifiedColumnsCount

        foreach ($classifiedColumn in $columnResult.ClassifiedColumns) {
            $classifiedColumn | Add-Member NoteProperty 'InstanceId' $instanceId
            $classifiedColumn | Add-Member NoteProperty 'DatabaseName' $databaseName
            $columnsResultArray += $classifiedColumn
        }
    }
    Until ($columnsResultArray.Count -ge $totalColumns)
    return  $columnsResultArray
}


function Get-ColumnTag {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)] [object] $column
    )

    $url = $ClassificationURL +
    "api/instances/" + $column.instanceId +
    "/databases/" + $column.databaseName +
    "/schemas/" + $column.schemaName +
    "/tables/" + $column.tableName +
    "/columns/" + $column.columnName +
    "/tags"

    return Invoke-RestMethod -Uri $url  -ContentType "application/json" -Method GET -Headers $ClassificationAuthHeader
}


function Update-ColumnTag {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)] [object] $column,
        [Parameter(Mandatory = $true)] [string] $category,
        [string[]] $tags,
        [switch] $forceUpdate
    )

    process {
        $columnTags = $column | Get-ColumnTag
        $columnTagIds = $columnTags.Tags

        $tagCategory = $allTagCategories[$category]     

        $tagIds = New-Object System.Collections.ArrayList(,@( $columnTagIds | ForEach-Object {$_.id} ))

        if ($tagCategory.IsMultiValued -eq $true) {   
            # clear tag category for multi tag         
            if($forceUpdate) {
                foreach($tagIdToRemove in $tagCategory.Tags.Values) {
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
                    if($forceUpdate) {
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


        $url = $ClassificationURL +
        "api/instances/" + $column.instanceId +
        "/databases/" + $column.databaseName +
        "/schemas/" + $column.schemaName +
        "/tables/" + $column.tableName +
        "/columns/" + $column.columnName +
        "/tags"
        $body = @{
            TagIds = $tagIds.ToArray()
        }
        $body = $body | ConvertTo-Json;
        Invoke-RestMethod -Uri $url  -ContentType "application/json" -Method PUT -Headers $ClassificationAuthHeader -Body $body
    }
}

<#
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

    Import-Module .\ClassifyColumn.ps1
    Use-Classification -ClassificationServer "fqdn-server-name" -ClassificationAuthToken "auth-token"
    $allColumns = Get-Columns -instanceName "sqlserver\sql2016" -databaseName "WideWorldImporters"

    $emailColumns  = $allColumns | Where-Object {$_.ColumnName -like "email"}
    $emailColumns | Update-ColumnTag -category "Sensitivity" -tags @("Confidential - GDPR")
    $emailColumns | Update-ColumnTag -category "Information Type" -tags @("Contact Info")

    $peopleTableColumns = $allColumns | Where-Object {$_.SchemaName -eq "Application" -and $_.TableName -eq "People" }
    $peopleTableColumns | Update-ColumnTag -category "Sensitivity" -tags @("Confidential - GDPR")
    $peopleTableColumns | Update-ColumnTag -category "Information Type" -tags @("Contact Info")
#>
