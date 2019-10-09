#config
$dataCatalogServer = "http://rm-win10-sql201.testnet.red-gate.com:15156"
$dataCatalogAuthToken = "NTM2OTUxMTYyNzA4OTUxMDQwOmRiNjIyYWMxLWI1NDYtNDQzNi04OTE2LWQ1MzkxNGIzYzI5MQ=="

#retrieve modules from data catalog api
Invoke-WebRequest -Uri "$dataCatalogServer/powershell" -OutFile "datacatalog.psm1" -Headers @{"Authorization" = "Bearer $dataCatalogAuthToken" }
 
#import data catalog modules
Import-Module .\datacatalog.psm1 -Force
Import-Module .\DataMasker.psm1 -Force   

# local config
$instanceName = 'rm-iclone1.testnet.red-gate.com'
$databaseName = 'StackoverFlow2010'
$inputMaskingSetPath = "\\rm-iclone1\Masking Set Files\Shell\StackOverflow2010 Automation.DMSMaskSet"
$outputMaskingSetPath = "\\rm-iclone1\Masking Set Files\Generated\StackOverflow2010 Generated.DMSMaskSet"

# connect to your SQL Data Catalog instance - you'll need to generate an auth token in the UI
Connect-SqlDataCatalog  -ClassificationAuthToken $dataCatalogAuthToken -ServerUrl $dataCatalogServer

$maskingDataSetTagCategoryId = ((Get-ClassificationTaxonomy).TagCategories | Where-Object { $_.Name -eq "Masking Data Set" }).id
Write-Output "Getting columns"

$allColumns = Get-ClassificationColumn -instanceName $instanceName -databaseName $databaseName

# Filter on sensitivity label text match for GDPR 
#$maskableColumns = $allColumns | Where-Object { $_.sensitivityLabel -like "*GDPR*" }

#$allColumns = $maskableColumns
  
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
                             Write-Output "Generating masking xml for column $column in table $table."
                            #construct info for each classified column by modifying a template, to add to this table"s substitution rule
                            $columnXml = Format-ColumnInfo -MaskingSet $maskingSet -Schema $schema -Table $table -Column $column
                        
                            
                            #if we can find a data set to use, add it to the column 
                            #and add the column to the substitution rule
                            $dataSetXml = Get-DataSet -DataSetLabel $dataSetLabel
                            if($dataSetXml){
                                $substitutionRuleXml = Add-ColumnToSubstitutionRule -SubstitutionRule $substitutionRuleXml -Column $columnXml -DataSet $dataSetXml
                                $haveFoundColumnsWithDataSets = $true
                            } else {
                                Write-Output "Data set $dataSetLabel doesn't exist for column $schema.$table.$column. Skipping."
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

Write-Output "Masking set generated as $outputMaskingSetPath\n" 
Get-ChildItem $outputMaskingSetPath