#
# Script to create n copies of a SQL Clone image in a single destinataion
#
Clear-Host
$myUrl = "http://rm-win10-sql201.testnet.red-gate.com:14145"
$myLocalAgent = "RM-WIN10-SQL201"
$myLocalInstance = ""

# connect to SQL Clone server (using current credentials)
Connect-SqlClone -ServerUrl $myUrl
Get-SqlCloneMachine 