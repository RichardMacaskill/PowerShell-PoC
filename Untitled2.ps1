
# Script to create a new SQL Clone data image from a backup file
$SourceDatabase = 'StackOverflow'
$BackupFolder = 'E:\SQL\MSSQL12.MSSQLSERVER\MSSQL\Backup'

if (!(Test-Path ($BackupFolder)))
  {
    write-host 'Backup folder not found. Exiting.'
    break
  }

$BckLatestDate = Get-ChildItem -Path $BckPath  |
  Sort-Object -Property LastWriteTime |
  Select-Object -Last 1
  $BckLatestSet = Get-ChildItem -Path $BckPath  |
  Where-Object -FilterScript {
    $_.LastWriteTime -gt ($BckLatestDate.LastWriteTime).AddSeconds(-2)
  } |
  Sort-Object -Property Name 

$RestoreArray = @()
  foreach ($bkup in $BckLatestSet)
  {
    $RestoreArray += $bkup.FullName
  }

#Start a timer
$elapsed = [System.Diagnostics.Stopwatch]::StartNew()
"Started at {0}, removing {1} clones for image ""{2}""" -f $(get-date) , $clones.Count , $image.Name

$clones | foreach { # note - '{' needs to be on same line as 'foreach' !
    $_ | Remove-SqlClone | Wait-SqlCloneOperation
    "Removed clone ""{0}""" -f $_.Name ;
                    };

"Total Elapsed Time: {0}" -f $($elapsed.Elapsed.ToString())



  $NewImage = New-SqlCloneImage -Name $SourceDatabase -BackupLocation $BackupFolder -BackupFileName $BackupFileName