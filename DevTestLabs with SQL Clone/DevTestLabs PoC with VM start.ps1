# dot source the invoke-parallel function 
. "C:\Dev\Git\PowerShell-PoC\Utils\PowerShell\Invoke-Parallel.ps1"

$elapsed = [ System.Diagnostics.Stopwatch]::StartNew()
"Started at {0}" -f $( get-date)

# Connect my profile and start my VM
# This was created by running Login-AzureRMAccount
# then Save-AzureRmProfile -Path C:\dev\PowerShell\azureprofile.json

Select-AzureRmProfile -Path "C:\dev\PowerShell\azureprofile.json"

#Start-AzureRmVM -ResourceGroupName "RG-Clone" -Name "SQL-VM-Dev4"
# clonelab1327002761000
$VMs = Get-AzureRmVM
$VMs    |   Format-Table
$VMs | Invoke-Parallel -ImportVariables -ScriptBlock {
    Start-AzureRmVM -ResourceGroupName $_.ResourceGroupName -Name $_.Name
}

"Total Elapsed Time: {0}" -f $( $elapsed.Elapsed.ToString())


$VMs | Invoke-Parallel -ImportVariables -ScriptBlock {
    Stop-AzureRmVM -ResourceGroupName $_.ResourceGroupName -Name $_.Name 

}

# Connect a PS Session to the VM

Enter-PSSession -ComputerName 'clonelab1327002761000.westeurope.cloudapp.azure.com' -Port 62584 -Credential cas -UseSSL

# Create new clones from the Azure FS data image repository

$Snapshot = 'StackOverflow'
$ClonePrefix = '_SO_Clone_'
$Count = 5


for ($i =0; $i -lt $Count; $i++)
{
New-InstantCloneClone -SnapshotName $Snapshot -NewDatabaseName $ClonePrefix$i
"Created clone {0}" -f $i;
};
Show-InstantCloneClones | Select CloneDatabase , `
CloneTime,SizeInMegabytes , SnapshotSizeInMegabytes   | ft

#Show-InstantCloneSnapshots

Invoke-Sqlcmd -Query "SELECT name, physical_name AS current_file_location FROM `
sys.master_files WHERE physical_name like '%SQL CLone%';" -ServerInstance "SQL-VM-Dev4"  

Invoke-Sqlcmd -Query "SELECT top 100 DisplayName, CreationDate, AboutMe  from _SO_Clone_0.dbo.Users;" -ServerInstance "SQL-VM-Dev4" | ft 

$UpdateSQL = "DECLARE @NextId INT;DECLARE @loop INT;SELECT @loop = 0;WHILE @loop < 1000 BEGIN `
SELECT @NextId = MAX(Id) +1 FROM _SO_Clone_0.dbo.Posts; PRINT 'Next Id is ' + CONVERT(VARCHAR(10),@NextId); `
INSERT INTO _SO_Clone_0.dbo.Posts         ( Id  ,Body        ,ClosedDate        ,CommentCount        ,CommunityOwnedDate        ,CreationDate        ,FavoriteCount        ,LastActivityDate        ,LastEditDate        ,LastEditorDisplayName        ,LastEditorUserId        ,OwnerUserId        ,ParentId        ,PostTypeId        ,Score        ,Tags        ,Title        ,ViewCount        ) `
VALUES ( @NextId  ,N'How can I learn SQL please?'  ,null  ,0  ,GETDATE()  ,GETDATE()  ,0,GETDATE()  ,GETDATE()  ,N''  ,0  ,0  ,0  ,0  ,0  ,N''  ,N''  ,0  ); `
SELECT @loop	=	@loop + 1; 		END        ;"

Invoke-Sqlcmd -Query $UpdateSQL -ServerInstance "SQL-VM-Dev4" ;

Invoke-Sqlcmd -Query "SELECT * FROM _SO_Clone_0.dbo.Posts WHERE Id >= (SELECT MAX(Id) FROM _SO_Clone_0.dbo.Posts) - 2000;	" -ServerInstance "SQL-VM-Dev4" | ft 

# Clear up

for ($i =0; $i -lt $Count; $i++)
{
Remove-InstantCloneClone -CloneName $ClonePrefix$i
"Removed clone {0}" -f $i
};



Exit-PSSession

Stop-AzureRmVM -ResourceGroupName "SQL-VM-Dev41528789210" -Name "SQL-VM-Dev4" -Force #took 1 minute
 
