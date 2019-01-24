#Install-Module ImportExcel
<# The ImportExcel module is maintained by PowerShell MVP Doug Finke @dfinke on twitter #>
CD C:\temp\Excel
,(Import-Excel -Path \SysTables_AdventureWorks2014.xlsx) |
Write-SqlTableData -ServerInstance localhost\SQL2017 -Database BlankDB -SchemaName Excel -TableName MyNewTable_fromExcel -Force
,(Import-Excel -Path C:\temp\Excel\SysColumns_AdventureWorks2014.xlsx) |
Write-SqlTableData -ServerInstance localhost\SQL2017 -Database BlankDB -SchemaName Excel -TableName MyOtherNewTable_fromExcel -Force
Dir -Filter *.xlsx |
foreach {
        ,(Import-Excel -Path $_.Name) | 
        Write-SqlTableData -ServerInstance localhost\SQL2017 -DatabaseName BlankDB -SchemaName Excel -TableName $_.BaseName -Force
    }



Coll