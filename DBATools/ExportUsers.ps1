
Import-Module dbatools
Export-DbaUser -SqlInstance "rm-iclone1.testnet.red-gate.com" -Database "Forex" -Path C:\temp\forex-users.sql