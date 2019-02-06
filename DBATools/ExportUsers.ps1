Import-Module dbatools
Import-Module SqlServer
Export-sqlUser -SqlInstance "rm-iclone1.testnet.red-gate.com" -Database "Forex" -Path C:\temp\forex-users.sql