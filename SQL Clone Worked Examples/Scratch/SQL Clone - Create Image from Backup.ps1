# Script to create a new SQL Clone data image from a backup file

$SQLCloneServer= "http://rm-win10-sql201.testnet.red-gate.com:14145"
$SQLCloneAgent = "rm-iclone1"

Connect-SqlClone -ServerUrl $myUrl

$SourceDatabase = 'Forex'
$BackupFolder = 'E:\SQL\MSSQL12.MSSQLSERVER\MSSQL\Backup'

if (!(Test-Path ($BackupFolder)))
  {
    write-host 'Backup folder not found. Exiting.'
    break
  }

# Get the latest backup file for our database (striped backups would be more complex)
$BackupFiles = Get-ChildItem -Path $BackupFolder  |
    Where-Object -FilterScript { $_.Name.Substring(0,$SourceDatabase.Length) -eq $SourceDatabase}  | # My backup files always start with the database name
    Sort-Object -Property LastWriteTime  |    
    Select-Object -Last 1 # I only want the most recent file for this database to be used

$BackupFileName = $BackupFile.Name

#Start a timer
$elapsed = [System.Diagnostics.Stopwatch]::StartNew()

"Started at {0}, creating data image for database ""{1}"" from backup file ""{2}""" -f $(get-date) , $SourceDatabase , $BackupFileName

$DataImageName = $SourceDatabase + "_" + (Get-Date -Format "yyyyMMdd") # Prepare a name for the data image, with a timestamp
$ImageDestination = Get-SqlCloneImageLocation -Path '\\is-filestore02.testnet.red-gate.com\rm-iclone\RM\SQL Clone Beta Images' # Point to the file share we want to use to store the image
$CloneBackupLocation = Get-SqlCloneBackupLocation -Path $BackupFolder # Point to the backup folder we want to work with (this was 'registered' with SQL Clone when I used the UI above)

$NewImage = New-SqlCloneImage -Name $DataImageName -BackupLocation $CloneBackupLocation -BackupFileName $BackupFileName -Destination $ImageDestination | Wait-SqlCloneOperation # Create the data image and wait for completion

"Total Elapsed Time: {0}" -f $($elapsed.Elapsed.ToString())  
