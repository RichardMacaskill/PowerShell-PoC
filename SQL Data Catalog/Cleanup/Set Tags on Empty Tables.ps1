<#
    Script to tag all empty tables as general/not used
    Created: 2018-11-28
    Author: Josh Smith
#>
$dataCatalog = 'luchalibris.stcu.local' # Read-Host -Prompt 'Please enter the FQDN for the Data Catalog server.'
$dataCatalog = 'http://' + $dataCatalog + ':15156/'
$sqlinstance = '' #Read-Host -Prompt 'Please enter the SQL instance for the database to classify.'
$database = 'Forex' #Read-Host =-Prompt 'Please enter the database name.'
<#*************************************************************************************#>
$AuthToken = 'NTE5MjM2NjY4MzgxNzI0NjcyOjFlNTQzZmVhLTc1ZTYtNDY5NC05OTk3LTJhZTRhZjNlZThkNA=='
$Headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$Headers.Add("Authorization", "Bearer $AuthToken")
$instanceid = $null
$qry = "WITH results
AS ( SELECT   SCHEMA_NAME(sOBJ.schema_id) + '.' AS [SchemaName]
            , sOBJ.[name] AS [TableName]
            , SUM(sPTN.[rows]) AS [RowCount]
     FROM     sys.objects AS sOBJ
              INNER JOIN sys.partitions AS sPTN ON sOBJ.object_id = sPTN.object_id
     WHERE    sOBJ.[type] = 'U'
              AND sOBJ.is_ms_shipped = 0x0
              AND index_id < 2 -- 0:Heap, 1:Clustered
     GROUP BY sOBJ.[schema_id]
            , sOBJ.[name] )
SELECT   r.SchemaName + r.TableName AS [TableName]
FROM     results r
WHERE    r.[RowCount] = 0
         AND r.TableName NOT IN (   SELECT [name]
                                    FROM   sys.tables
                                    WHERE  type <> 'U' )
ORDER BY [TableName];"
$tableList = Invoke-DbaQuery -SqlInstance $sqlinstance -Database $database -Query $qry 
$cmd = $DataCatalog + 'api/tagcategories'
$categories = Invoke-RestMethod -Uri $cmd -Headers $Headers
<#
    grab the ids/catID for the following items 
        "informationtype\other"
        "sensitivity\general"
        "Internal Data\Unused" <== this is our specific classification for columns in tables that are empty
#>
<#  
    find the tag ids for the tags we will be applying from various categories. If the table is
    empty we will assume it is 'other' and 'general.' A second script can be run from time
    to time to ensure that unused data columns/tables are in fact empty.    
#>
foreach($c in $categories)
{
    if ($c.name -eq 'Information Type')
    {
        foreach($t in $c.tags)
        {
            if ($t.name -eq 'Other')
            {
                $it_id = 0 + $t.id
            }
        }
    }
    elseif ($c.name -eq 'Sensitivity')
    {
        foreach($t in $c.tags)
        {
            if ($t.name -eq 'General')
            {
                $sens_id = 0 + $t.id
            }
        }
    }
    <# cusotmize any other categories/tags that need to be added here: #>
    elseif($c.name -eq 'Internal Data')
    {
        foreach($t in $c.tags)
        {
            if ($t.name -eq 'Unused')
            {
                $unused_id = 0 + $t.id
            }
        }
    }
}
$postObj = @{ tagids = @($it_id, $sens_id, $unused_id)}
$postJson = $postObj | ConvertTo-Json
$cmd = $DataCatalog + "api/instances"
$instances = Invoke-RestMethod -Uri $cmd -Headers $Headers
foreach ($i in $instances)
{
    if ($i.instance.name.ToUpper() -eq $sqlinstance.ToUpper())
    {
        $instanceid = $i.instance.id
    }
}
if ($instanceid -eq $null)
{
    Write-Host 'Instance not found!'
    Break
}
<# for each empty table in the database we will do the following:
        Set InformationType to 'Other'
        Set Sensitivity to 'General'
        Set Internal Data to 'Not Used'
#>
foreach ($t in $tableList)
{
    $tableName = $t.TableName.Substring($t.TableName.IndexOf('.') + 1, $t.TableName.Length - ($t.TableName.IndexOf('.')+ 1))
    $schemaName = $t.TableName.substring(0, $t.TableName.IndexOf('.'))
    Write-Host "Modifying tags for columns on $schemaName.$tableName..."
    # return columns for the table
    $cmd = $DataCatalog + "api/instances/$instanceid/databases/$database/columns?tableNamesWithSchemas=" + $t.TableName + "&tableskip=0&take=200" 
    $columns = Invoke-RestMethod -Uri $cmd -Headers $Headers
    # for each column we want to set the tags to our defaults (other, general, unused)
    foreach ($c in $columns.classifiedColumns)
    {
        $columnName = $c.columnName
        Write-Host "Modifying $columnName..."
        $cmd = 'api/instances/' + $instanceid + '/databases/' + $database + '/schemas/' + $schemaName + '/'
        $cmd = $cmd + '/tables/' + $tableName + '/columns/' + $columnName + '/tags'
        #apply the tag
        $cmd = $dataCatalog + $cmd
        Invoke-RestMethod -Uri $cmd -Headers $Headers `
            -Method Post -Body $postJson -ContentType 'application/json'
        #$postJson
        #just test the first column for now and exit
        break
    }
}
#>
#$result = Invoke-RestMethod -Uri $cmd -UseDefaultCredentials -Body $result -ContentType 'application/json'
#ConvertTo-Json $result
#create a model
<#
$hash = @{id = 'ASTRING'
          categoryid = 'ANOTHERSTRING'; tagids = @('YETANOTHERSTRING', 'STRINGARRAY') }
#>
#$catModel = @{ tagids}