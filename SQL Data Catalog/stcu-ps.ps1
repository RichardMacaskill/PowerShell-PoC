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

function Import-ExtendedPropertyClassifications {
    param(
        [Parameter(Mandatory = $true)] $ClassificationServer,
        [Parameter(Mandatory = $true)] $ClassificationAuthToken,        
        [Parameter(ValueFromPipeline)] [string] $instance,
        [Parameter(ValueFromPipeline)] [string] $database
    )

    Use-Classification -ClassificationServer $ClassificationServer -ClassificationAuthToken $ClassificationAuthToken
    $columns = Get-Columns -instanceName $instance -databaseName $database

    $sensitivityLabelLookup = @{
      "1866ca45-1973-4c28-9d12-04d407f147ad" = "Public";
      "684a0db2-d514-49d8-8c0c-df84a7b083eb" = "General";
      "331F0B13-76B5-2F1B-A77B-DEF5A73C73C2" = "Confidential";
      "989ADC05-3F3F-0588-A635-F475B994915B" = "Confidential - GDPR";
      "b82ce05b-60a9-4cf3-8a8a-d6a0bb76e903" = "Highly Confidential";
      "3302ae7f-b8ac-46bc-97f8-378828781efd" = "Highly Confidential - GDPR";
    }

    $sensitivityLabelQuery = "select 
	    sys.columns.name AS column_name,
	    sys.tables.name AS table_name,
	    sys.schemas.name AS schema_name,
	    sys.extended_properties.value AS ep_value
     from 
    sys.extended_properties 
    JOIN sys.columns 
    ON sys.columns.object_id = sys.extended_properties.major_id AND sys.columns.column_id = sys.extended_properties.minor_id
    JOIN sys.tables
    ON sys.tables.object_id = sys.extended_properties.major_id
    JOIN sys.schemas
    ON sys.schemas.schema_id = sys.tables.schema_id
    WHERE sys.extended_properties.name = 'sys_sensitivity_label_id'"

    $sensitivityLabelQueryResult = Invoke-Sqlcmd -Query $sensitivityLabelQuery -ServerInstance $instance -Database $database

    $sensitivityLabelQueryResult | ForEach-Object -Process {
        $resultColumn = $_
        $column = $columns | Where { ($_.schemaName -eq $resultColumn.schema_name) -and  ($_.tableName -eq $resultColumn.table_name) -and ($_.columnName -eq $resultColumn.column_name) } | Select -First 1
        $tag = $sensitivityLabelLookup[$resultColumn.ep_value]
        $column | Update-ColumnTag -category "Sensitivity" -tags @($tag)
    }
    
    $informationTypeLookup = @{
      "8A462631-4130-0A31-9A52-C6A9CA125F92" = "Banking";
      "5C503E21-22C6-81FA-620B-F369B8EC38D1" = "Contact Info";
      "C64ABA7B-3A3E-95B6-535D-3BC535DA5A59" = "Credentials";
      "D22FA6E9-5EE4-3BDE-4C2B-A409604C4646" = "Credit Card";
      "3DE7CC52-710D-4E96-7E20-4D5188D2590C" = "Date Of Birth";
      "C44193E1-0E58-4B2A-9001-F7D6E7BC1373" = "Financial";
      "6E2C5B18-97CF-3073-27AB-F12F87493DA7" = "Health";
      "57845286-7598-22F5-9659-15B24AEB125E" = "Name";
      "6F5A11A7-08B1-19C3-59E5-8C89CF4F8444" = "National ID";
      "B40AD280-0F6A-6CA8-11BA-2F1A08651FCF" = "Networking";
      "D936EC2C-04A4-9CF7-44C2-378A96456C61" = "SSN";
      "9C5B4809-0CCC-0637-6547-91A6F8BB609D" = "Other";
    }

    $informationTypeQuery = "select 
	    sys.columns.name AS column_name,
	    sys.tables.name AS table_name,
	    sys.schemas.name AS schema_name,
	    sys.extended_properties.value AS ep_value
     from 
    sys.extended_properties 
    JOIN sys.columns 
    ON sys.columns.object_id = sys.extended_properties.major_id AND sys.columns.column_id = sys.extended_properties.minor_id
    JOIN sys.tables
    ON sys.tables.object_id = sys.extended_properties.major_id
    JOIN sys.schemas
    ON sys.schemas.schema_id = sys.tables.schema_id
    WHERE sys.extended_properties.name = 'sys_information_type_id'"

    $informationTypeQueryResult = Invoke-Sqlcmd -Query $informationTypeQuery -ServerInstance $instance -Database $database

    $informationTypeQueryResult | ForEach-Object -Process {
        $resultColumn = $_
        $column = $columns | Where { ($_.schemaName -eq $resultColumn.schema_name) -and  ($_.tableName -eq $resultColumn.table_name) -and ($_.columnName -eq $resultColumn.column_name) } | Select -First 1
        $tag = $informationTypeLookup[$resultColumn.ep_value]
        $column | Update-ColumnTag -category "Information Type" -tags @($tag)
    }
}

Import-ExtendedPropertyClassifications -ClassificationServer "" -ClassificationAuthToken "" -instance "" -database ""