$cmsServer = "pdm-ltrichardm\dev"

#Waiting for this to get added to dbatools.io
#(Get-DbaRegisteredServerGroup -SqlInstance $cmsServer -ExcludeGroup $ExcludeGroup).name | sort-object -Unique
$groups = ((Get-DbaRegisteredServersStore -SqlInstance $cmsServer).DatabaseEngineServerGroup.ServerGroups).name | `
    #Where-Object {$PSItem -notin ($ExcludeGroup | where Tags -eq $null).name} |
    Sort-Object -Unique     

    $groups |    
    ForEach-Object {
        $groupName = $PSItem
 
        # Get the list of SQL instances from the CMS sever, except those that are excluded
        $sqlinstances = Get-DbaRegisteredServer -SqlInstance $cmsServer -Group $groupName | 
            where name -NotIn ($ExcludeServer | where Tag -eq $null ).name    
 
        $tags | ForEach-Object {
            $tag = $PSItem
 
            $obj =  [pscustomobject]@{            
                ServerGroup = $groupName
                NumServers = $sqlinstances.Count
                Tag = $tag
                InvokeStartTime = Get-Date
                InvokeCompleteTime = $null
                WriteResultsTime = $null
                TestExecution = $null
                InvokeDuration = $null
                ResultsDuration = $null
                PassedCount       = $null
                FailedCount       = $null
                SkippedCount      = $null
                PendingCount      = $null
                InconclusiveCount = $null               
            }
             
            $results = Invoke-DbcCheck -SqlInstance $sqlinstances -tags $tag -PassThru -Show Fails
            $obj.TestExecution     = $results.time
            $obj.PassedCount       = $results.PassedCount      
            $obj.FailedCount       = $results.FailedCount      
            $obj.SkippedCount      = $results.SkippedCount     
            $obj.PendingCount      = $results.PendingCount     
            $obj.InconclusiveCount = $results.InconclusiveCount
 
            $obj.InvokeCompleteTime = Get-Date
 
            $results | Update-DbcPowerBiDataSource -Enviornment $groupName -Append -Path $PowerBiDataPath
            $obj.WriteResultsTime = Get-Date      
 
            $obj.InvokeDuration = New-TimeSpan -Start $obj.InvokeStartTime -End $obj.InvokeCompleteTime
            $obj.ResultsDuration = New-TimeSpan -Start $obj.InvokeCompleteTime -End $obj.WriteResultsTime 
 
            $timeData += $obj       
        } # $tags | ForEach-Object               
} # $groups | ForEach-Object
 
$timeData |
    Select-Object ServerGroup, NumServers, tag, InvokeDuration,  TestExecution, ResultsDuration |
    ft -AutoSize