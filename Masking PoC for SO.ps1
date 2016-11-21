$elapsed = [System.Diagnostics.Stopwatch]::StartNew()
"Started at {0}" -f $(get-date)

# Store an adjusted clone as a new Data Image

Save-InstantCloneSnapshot -DatabaseName _SO_Clone1 -SnapshotName StackOverflowMasked -PutInSharedFolder 

"Time to store new Data Image: {0}" -f $($elapsed.Elapsed.ToString())

$elapsed = [System.Diagnostics.Stopwatch]::StartNew()

# Create new Clone
New-InstantCloneClone -NewDatabaseName _SO_Clone1_Masked -SnapshotName StackOverflowMasked

"Done - time to create new Clone: {0}" -f $($elapsed.Elapsed.ToString())

#Remove-InstantCloneClone -CloneName _SO_Clone1_Masked
#New-InstantCloneClone -NewDatabaseName _SO_Clone1_Sanitized -SnapshotName StackOverflow_Sanitised_Snap_20160629
#Remove-InstantCloneClone -CloneName _SO_Clone1_Sanitized
