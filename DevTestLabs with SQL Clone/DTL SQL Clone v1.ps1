.\Utils\Shutdown-Start-ARM-VMs-Parallel.ps1

$elapsed = [ System.Diagnostics.Stopwatch]::StartNew()
"Started at {0}" -f $( get-date)

# Connect my profile and start my VM
# This was created by running Login-AzureRMAccount
# then Save-AzureRmProfile -Path C:\dev\PowerShell\azureprofile.json

Select-AzureRmProfile -Path "C:\dev\PowerShell\azureprofile.json"

Start-AzureRmVM -ResourceGroupName "clone-enabled-lab3264679188000" -Name "VM-SQLClone1"  
Start-AzureRmVM -ResourceGroupName "clone-enabled-lab3264679188000" -Name "VM-Dev1"
Start-AzureRmVM -ResourceGroupName "clone-enabled-lab3264679188000" -Name "VM-Dev2"

"Total Elapsed Time: {0}" -f $( $elapsed.Elapsed.ToString())