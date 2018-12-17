<#
    Script to tag all empty tables as general/not used. $authToken should be replaced with
    a token generated from the appropriate data catalog intallation.

    Created: 2018-11-28

    Author: Josh Smith

#>

#$dataCatalog = Read-Host -Prompt 'Please enter the FQDN for the Data Catalog server.'
$dataCatalog =  'http://rm-win10-sql201.testnet.red-gate.com:15156/' #'http://' + $dataCatalog + ':15156/'
$sqlinstance = 'rm-iclone1.testnet.red-gate.com' #Read-Host -Prompt 'Please enter the SQL instance for the database to classify.'
$database = 'AdventureWorks2012' # Read-Host =-Prompt 'Please enter the database name.'

<#*************************************************$p************************************#>
$AuthToken = 'NTE3NjA0OTQ0NjE0Nzg1MDI0Ojc5NzViY2YwLTAyOGUtNGU4My1hZjY4LTJkNWE0ZmI4MmNlMw=='
$Headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$Headers.Add("Authorization", "Bearer $AuthToken")

$instanceid = $null
$qry = "WITH results
AS ( SELECT   SCHEMA_NAME(o.schema_id) + '.' AS [SchemaName]
            , o.[name] AS [TableName]
            , SUM(p.[rows]) AS [RowCount]
     FROM     sys.objects AS o
              INNER JOIN sys.partitions AS p ON o.object_id = p.object_id
     WHERE    o.[type] = 'U'
              AND o.is_ms_shipped = 0x0
              AND index_id < 2 -- 0:Heap, 1:Clustered
     GROUP BY o.[schema_id]
            , o.[name] )
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
                $it_id = $t.id
            }
        }
    }
    elseif ($c.name -eq 'Sensitivity')
    {
        foreach($t in $c.tags)
        {
            if ($t.name -eq 'General')
            {
                $sens_id = $t.id
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
                $unused_id = $t.id
            }
        }
    }
}

$postObj = @{tagids = @($it_id, $sens_id)}

if ($null -ne $unused_id) { $postObj.tagids += $unused_id} 

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
        $cmd = 'api/instances/' + $instanceid + '/databases/' + $database + '/schemas/' + $schemaName 
        $cmd = $cmd + '/tables/' + $tableName + '/columns/' + $columnName + '/tags'

        #apply the tag
        $cmd = $dataCatalog + $cmd
        Invoke-RestMethod -Uri $cmd -Headers $Headers `
            -Method Put -Body $postJson -ContentType 'application/json' 

    }
}