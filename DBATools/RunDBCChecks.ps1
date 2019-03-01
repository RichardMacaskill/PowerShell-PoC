import-module "C:\Program Files\WindowsPowerShell\Modules\Pester"
 "C:\Program Files\WindowsPowerShell\Modules\PSFramework"
import-module "C:\Program Files\WindowsPowerShell\Modules\dbachecks"
# Set the configuration of dbachecks
#Set-DbcConfig -Name agent.failsafeoperator -Value 'DB eAlert'
Set-DbcConfig -Name domain.name -Value 'testnet.red-gate.com'
Set-DbcConfig -Name app.computername -Value @('rm-iclone1','rm-iclone2')
Set-DbcConfig -Name policy.backup.fullmaxdays -Value 7
Set-DbcConfig -Name policy.backup.diffmaxhours -Value 24
Set-DbcConfig -Name policy.backup.logmaxminutes -Value 15
Set-DbcConfig -Name policy.dbownershould -Value 'sa'
Set-DbcConfig -Name policy.validdbowner  -Value 'sa'
#Set-DbcConfig -Name agent.dbaoperatorname -Value 'DB eAlert'

# Time to execute against my CMS system
Invoke-DbcCheck -SqlInstance (Get-DbaRegisteredServer -SqlInstance 'pdm-ltrichardm\dev' -IncludeSelf) -ExcludeCheck TestLastBackup,TestLastBackupVerifyOnly -PassThru| Out-GridView
Start-DbcPowerBi