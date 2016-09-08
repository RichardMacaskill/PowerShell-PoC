$elapsed = [ System.Diagnostics.Stopwatch]::StartNew()
"Started at {0}" -f $( get-date)

# Connect my profile and start my VM
# This was created by running Login-AzureRMAccount
# then Save-AzureRmProfile -Path C:\dev\PowerShell\azureprofile.json

Select-AzureRmProfile -Path "C:\dev\PowerShell\azureprofile.json"

Start-AzureRmVM -ResourceGroupName "ForexDevLab-SQL-VM-Dev5-150194" -Name "SQL-VM-Dev5" #took 1 minute

"Total Elapsed Time: {0}" -f $( $elapsed.Elapsed.ToString())

# Connect a PS Session to the VM without checking certs
$so = New-PSSessionOption -SkipCNCheck
$s = New-PSSession  -ComputerName 'sql-vm-dev5.westeurope.cloudapp.azure.com' -Port 5986 -Credential Cas -UseSSL -SessionOption $so
Enter-PSSession -Session $s


# How much disk space do I have?
Get-PSDrive C 

# What Clones are there now?
Show-InstantCloneClones | ft

# Create new clones from the Azure FS data image repository
$Snapshot = 'StackOverflow'
$ClonePrefix = '_StackOverflow_Clone_'
$Count = 1

$elapsed = [ System.Diagnostics.Stopwatch]::StartNew()

for ($i =1; $i -le $Count; $i++)
{
New-InstantCloneClone -SnapshotName $Snapshot -NewDatabaseName $ClonePrefix$i
"Created clone {0}" -f $i;
};

"Total Elapsed Time: {0}" -f $( $elapsed.Elapsed.ToString())

Show-InstantCloneClones | Select CloneDatabase , `
CloneTime,SizeInMegabytes , SnapshotSizeInMegabytes   | ft

Show-InstantCloneSnapshots

Invoke-Sqlcmd -Query "SELECT name, physical_name AS current_file_location FROM `
sys.master_files WHERE physical_name like '%SQL CLone%';" -ServerInstance "SQL-VM-Dev4"  

Invoke-Sqlcmd -Query "SELECT top 100 DisplayName, CreationDate, AboutMe  from _StackOverflow_Clone_0.dbo.Users;" -ServerInstance "SQL-VM-Dev4" | ft 

$UpdateSQL = "DECLARE @NextId INT;DECLARE @loop INT;SELECT @loop = 0;WHILE @loop < 1000 BEGIN `
SELECT @NextId = MAX(Id) +1 FROM _StackOverflow_Clone_0.dbo.Posts; PRINT 'Next Id is ' + CONVERT(VARCHAR(10),@NextId); `
INSERT INTO _StackOverflow_Clone_0.dbo.Posts         ( Id  ,Body        ,ClosedDate        ,CommentCount        ,CommunityOwnedDate        ,CreationDate        ,FavoriteCount        ,LastActivityDate        ,LastEditDate        ,LastEditorDisplayName        ,LastEditorUserId        ,OwnerUserId        ,ParentId        ,PostTypeId        ,Score        ,Tags        ,Title        ,ViewCount        ) `
VALUES ( @NextId  ,N'How can I learn SQL please?'  ,null  ,0  ,GETDATE()  ,GETDATE()  ,0,GETDATE()  ,GETDATE()  ,N''  ,0  ,0  ,0  ,0  ,0  ,N''  ,N''  ,0  ); `
SELECT @loop	=	@loop + 1; 		END        ;"

Invoke-Sqlcmd -Query $UpdateSQL -ServerInstance "SQL-VM-Dev4" ;

Invoke-Sqlcmd -Query "SELECT * FROM _StackOverflow_Clone_0.dbo.Posts WHERE Id >= (SELECT MAX(Id) FROM _StackOverflow_Clone_0.dbo.Posts) - 2000;	" -ServerInstance "SQL-VM-Dev4" | ft 

# Clear up
for ($i =1; $i -le $Count; $i++)
{
Remove-InstantCloneClone -CloneName $ClonePrefix$i 
"Removed clone {0}" -f $i
};



Exit-PSSession

Stop-AzureRmVM -ResourceGroupName "ForexDevLab-SQL-VM-Dev5-150194" -Name "SQL-VM-Dev5" -Force #took 1 minute
 
