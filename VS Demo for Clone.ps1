# check we can connect
Invoke-Sqlcmd -Query "SELECT TOP 1 * FROM ForexAppBuild.dbo.ExchangeRate;" -ServerInstance ".\Dev"
# update for CrazyRates
Invoke-Sqlcmd -Query "UPDATE ForexAppBuild.dbo.ExchangeRate SET OutrightRate = OutrightRate * 10000 WHERE ISO='EUR';" -ServerInstance ".\Dev"
# save CrazyRates snapshot
Save-InstantCloneSnapshot -PutInSharedFolder -DatabaseName ForexAppBuild -SnapshotName CrazyRates
# check it's there
Show-InstantCloneSnapshots | ft
# clean up
Remove-InstantCloneSnapshot -SnapshotName CrazyRates
# clean up app db after breaking
Remove-InstantCloneClone -CloneName ForexAppBuild -Verbose