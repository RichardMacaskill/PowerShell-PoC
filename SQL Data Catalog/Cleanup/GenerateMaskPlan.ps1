function Get-MaskObj {
    Param ($column, $mask)
    # Make the JSON for an individual mask on a single column
    $maskBlob = $mask.PSObject.Copy()
    $id = [guid]::NewGuid()
    $maskBlob | Add-Member id $id
    $maskBlob | Add-Member synchronised false -Force
    $maskBlob | Add-Member name "$($column.schemaName).$($column.tableName).$($column.columnName)"
    return @{
        mask    = $maskBlob
        columns = @($column)
    }
}

# File containing a list of columns with their corresponding tag
$columns = Get-Content -Raw "taggedColumns.json" | ConvertFrom-Json

# File containing a mask for each tag
$tags = Get-Content -Raw "tagMasks.json" | ConvertFrom-Json

$masks = @()
foreach ($col in $columns) {
    $maskBlob = $tags."$($col.Tag)"
    $masks += Get-MaskObj $col.column $maskBlob
} 
$maskplan = @{
    version          = 1
    masks            = $masks
    customTableLinks = @()
}

ConvertTo-Json -Depth 100 $maskplan | Set-Content -Path "C:\Users\richard.macaskill\Documents\Data Masker(SqlServer)\Masking Sets\actual.maskplan"