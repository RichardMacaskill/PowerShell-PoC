#config

$dataCatalogAuthToken = "NTM2OTUxMTYyNzA4OTUxMDQwOmRiNjIyYWMxLWI1NDYtNDQzNi04OTE2LWQ1MzkxNGIzYzI5MQ=="
$instanceName = 'rm-iclone3.testnet.red-gate.com'
$databaseName = 'Masking_SG_OLAP_DATA_20180304'
$inputMaskingSetPath = '/Users/richard.macaskill/Dev/Masking and Config Scripts/GC_Olap_Data_Auto.DMSMaskSet'
 #'C:\Users\richard.macaskill\Documents\Data Masker(SqlServer)\Masking Sets\GC_Olap_Data_Auto.DMSMaskSet'
$outputMaskingSetPath = '/Users/richard.macaskill/Dev/Masking and Config Scripts/output 3.DMSMaskSet' 
#'C:\Users\richard.macaskill\Documents\Data Masker(SqlServer)\Masking Sets\GC_Olap_Data_Generated v2.DMSMaskSet'

#load data from catalog and data masker file   
Import-Module .\DataCatalogWithTagCategories.psm1 -Force
Import-Module .\DataMasker.psm1 -Force

Use-Classification -ClassificationAuthToken $dataCatalogAuthToken 

$maskingDataSetTagCategoryId = (Get-TagCategories)["GCMasked"].Id
Write-Output "Getting columns"
$allColumns = Get-Columns -instanceName $instanceName -databaseName $databaseName

$maskableColumns = $allColumns | Where-Object {$_.tags.name -like "*Masked *" } # 722
$specificMaskableColumns = $maskableColumns | Where-Object {$_.tags.name  -notcontains  "Masked TBD"} #173

$allColumns = $specificMaskableColumns

Write-Output "Finished getting columns"
[xml]$maskingSet = Get-Content -Path $inputMaskingSetPath

$nextRuleNumber = 1 + (Get-HighestRuleId -MaskingSet $maskingSet)

#iterate through schemas -> tables -> columns
$schemas = $allColumns | Select-Object -ExpandProperty schemaName -Unique
foreach($schema in $schemas){
    if(-not (Test-ControllerExists -MaskingSet $maskingSet -Schema $schema)){
        Write-Output "No controller found for Catalog schema $schema. Skipping."
    } else{
        #all rules for this schema will need to know the controller's serialized id
        $controllerSerializedId = Format-ControllerSerializedId -MaskingSet $maskingSet -Schema $schema
            
        $tables = $allColumns | Where-Object {$_.schemaName -like $schema} | Select-Object -ExpandProperty tableName -Unique
        foreach($table in $tables){
            if(-not (Test-TableExists -MaskingSet $maskingSet -Schema $schema -Table $table)){
                Write-Output "Table $table not found in schema $schema. Skipping."
            } else {
                $haveFoundColumnsWithDataSets = $false
                
                #use one substitution rule per table, constructed by modifying a template  
                $substitutionRuleXml = Format-SubstitutionRule -RuleBlock 1 -RuleNumber $nextRuleNumber -SerializedParentRuleId $controllerSerializedId -Table $table -Description "Substitution rule for $table"
                
                $columns = $allColumns | Where-Object {$_.schemaName -like $schema -and $_.tableName -like $table} | Select-Object -ExpandProperty columnName -Unique
                foreach($column in $columns){
                    if(-not (Test-ColumnExists -MaskingSet $maskingSet -Schema $schema -Table $table -Column $column)){
                        Write-Output "Column $column not found in table $schema.$table. Skipping."
                    } else {
                        #update the column's plan type & comments in the controller based on sensitivity level
                        $sensitivity = $allColumns | Where-Object {$_.schemaName -like $schema -and $_.tableName -like $table -and $_.columnName -like $column} | Select-Object -ExpandProperty sensitivityLabel -First 1
                        $maskingSet = Update-PlanInformation -MaskingSet $maskingSet -Schema $schema -Table $table -Column $column -Sensitivity $sensitivity

                        #add the column to a masking rule if a data set label has been selected
                        $dataSetLabel = $allColumns | Where-Object {$_.schemaName -like $schema -and $_.tableName -like $table -and $_.columnName -like $column} | Select-Object -ExpandProperty tags | Where-Object {$_.categoryId -eq $maskingDataSetTagCategoryId} | Select-Object -ExpandProperty name
                        if($dataSetLabel){
                            #construct info for each classified column by modifying a template, to add to this table's substitution rule
                            $columnXml = Format-ColumnInfo -MaskingSet $maskingSet -Schema $schema -Table $table -Column $column
                        
                            #if we can find a data set to use, add it to the column 
                            #and add the column to the substitution rule
                            $dataSetXml = Get-DataSet -DataSetLabel $dataSetLabel
                            if($dataSetXml){
                                $substitutionRuleXml = Add-ColumnToSubstitutionRule -SubstitutionRule $substitutionRuleXml -Column $columnXml -DataSet $dataSetXml
                                $haveFoundColumnsWithDataSets = $true
                            } else {
                               # Write-Output "Data set $dataSetLabel doesn't exist for column $schema.$table.$column. Skipping."
                            }
                        }
                    }
                }

                if($haveFoundColumnsWithDataSets){
                    $maskingSet = Add-RuleToMaskingSet -MaskingSet $maskingSet -Rule $substitutionRuleXml
                    $nextRuleNumber++
                }
            }
        }
    }
}

$maskingSet.Save($outputMaskingSetPath)