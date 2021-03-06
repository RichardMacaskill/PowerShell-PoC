function Shutdown-Start-ARM-VMs-Parallel {

    Param(

        [Parameter(Mandatory=$true)]
        [String]
        $ResourceGroupName,

        [Parameter(Mandatory=$true)]
        [Boolean]
        $Shutdown

    )
            
            
    $vms = Get-AzureRmVM -ResourceGroupName $ResourceGroupName;
            
    Foreach -Parallel ( $vm in $vms ) {
                        
        if ( $Shutdown ) {

            Write-Output "Stopping $($vm.Name)";              
            Stop-AzureRmVm -Name $vm.Name -ResourceGroupName $ResourceGroupName -Force;

        }

        else {

            Write-Output "Starting $($vm.Name)";                
            Start-AzureRmVm -Name $vm.Name -ResourceGroupName $ResourceGroupName;

        }

    }

}
