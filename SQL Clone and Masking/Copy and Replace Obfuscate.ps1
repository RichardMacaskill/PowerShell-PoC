# set an alias for the SQL Data Generator command line application
Set-Alias SQLDataGenerator 'C:\Program Files (x86)\Red Gate\SQL Data Generator 3\SQLDataGenerator.exe' -Scope Script

$projectFilePath = 'Z:\Project Work\Data masker using datagen\'
$projectFile = 'StackOverflow Obfuscate.sqlgen'

"Started at {0}" -f $(get-date)
$elapsed = [System.Diagnostics.Stopwatch]::StartNew()

SQLDataGenerator /project:"$projectFilePath\$projectFile" 

"Done - time to populate database: {0}" -f $($elapsed.Elapsed.ToString())


