$SQLCloneServer= "http://rm-win10-sql201.testnet.red-gate.com:14145"

Connect-SqlClone -ServerUrl $SQLCloneServer


Get-SqlCloneMachine -Name 'RM-ICLONE2' | Remove-SqlCloneMachine 
