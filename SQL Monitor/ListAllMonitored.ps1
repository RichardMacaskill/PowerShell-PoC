using module .\RedgateSQM.psm1
Import-Module .\RedgateSQM.psm1
Initialize -AuthToken "Mjo5MDUxZmMxYS00Yzk5LTQzZjMtOWQwZS1kNDJmNmIwMjgyMDg="

$baseMonitors = Get-BaseMonitors

foreach ($baseMonitor in $baseMonitors) {
    Write-Output "Base monitor: $($baseMonitor.Name)"
}

$standaloneMachines = Get-StandaloneMachines

foreach ($standaloneMachine in $standaloneMachines) {
    Write-Output "Standalone Machine: $($standaloneMachine.Name)"

    $instances = Get-InstancesForMachine $standaloneMachine
    
    foreach ($instance in $instances) {
        Write-Output "`tInstance: $($instance.Name)"
        
        $databases = Get-DatabasesForInstance $instance

        foreach ($database in $databases) {
            Write-Output "`t`tDatabase: $($database.Name)"
        }
        
        $jobs = Get-JobsForInstance $instance

        foreach ($job in $jobs) {
            Write-Output "`t`tJob: $($job.Name)"
        }
    }

    $disks = Get-DisksForMachine $standaloneMachine

    foreach ($disk in $disks) {
        Write-Output "`tDisk: $($disk.Name)"
    }
}


$clusters = Get-Clusters

foreach ($cluster in $clusters) {
    Write-Output "Cluster: $($cluster.Name)"

    $machines = Get-MachinesForCluster $cluster
    foreach ($machine in $machines) {
        Write-Output "`tMachine: $($machine.Name)"
        
        $instances = Get-InstancesForMachine $machine
    
        foreach ($instance in $instances) {
            Write-Output "`tInstance: $($instance.Name)"
        
            $databases = Get-DatabasesForInstance $instance

            foreach ($database in $databases) {
                Write-Output "`t`tDatabase: $($database.Name)"
            }

            $jobs = Get-JobsForInstance $instance

            foreach ($job in $jobs) {
                Write-Output "`t`tJob: $($job.Name)"
            }
        }

        $disks = Get-DisksForMachine $machine

        foreach ($disk in $disks) {
            Write-Output "`tDisk: $($disk.Name)"
        }
        
        $clusterInstances = Get-InstancesForCluster $cluster
        
        foreach ($clusterInstance in $clusterInstances) {
            Write-Output "`tInstance: $($clusterInstance.Name)"
        
            $databases = Get-DatabasesForInstance $clusterInstance

            foreach ($database in $databases) {
                Write-Output "`t`tDatabase: $($database.Name)"
            }

            $jobs = Get-JobsForInstance $clusterInstance

            foreach ($job in $jobs) {
                Write-Output "`t`tJob: $($job.Name)"
            }
        }
    }
    
    $availabilityGroups = Get-AvailabilityGroupsForCluster $cluster
    foreach ($availabilityGroup in $availabilityGroups) {
        Write-Output "`tAvailability Group: $($availabilityGroup.Name)"
    }
}


$azureSqlServers = Get-AzureSqlServers

foreach ($azureSqlServer in $azureSqlServers) {
    Write-Output "Azure SQL Server: $($azureSqlServer.Name)"
    
    $azureSqlDatabases = Get-DatabasesForAzureSqlServer $azureSqlServer

    foreach ($azureSqlDatabase in $azureSqlDatabases) {
        Write-Output "`tAzure SQL Database: $($azureSqlDatabase.Name)"
    }
    
    $azureElasticPools = Get-ElasticPoolsForAzureSqlServer $azureSqlServer

    foreach ($azureElasticPool in $azureElasticPools) {
        Write-Output "`tAzure Elastic Pool: $($azureElasticPool.Name)"
    }
}
