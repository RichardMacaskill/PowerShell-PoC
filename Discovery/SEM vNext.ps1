    <#
        .SYNOPSIS
            Enumerates and adds SQL server instances to SQL Estate Manager-vNext using the web API.

        .DESCRIPTION
            This function either accepts a SQL server instance FQDN, or enumerates and adds SQL server FQDNs to SQL Estate Manager-vNext using the web API.

        .PARAMETER mode
            String, either 'domain' to discover all SQL instances on the domain, 'local' to discover all SQL locally running SQL instances, or 'singleHost' to specify the intent to only add a single host by its FQDN.

        .PARAMETER instanceFqdn
            String representing the FQDN of a SQL server instance. Only aplicable when the mode parameter is set to 'singleHost'.

        .EXAMPLE
            .\add_sql_server_instance_to_inventory.ps1 -mode singleHost -instanceFqdn dev-joshuar.red-gate.com\SQL2017

            Adding a specific instance of a SQL server by its FQDN (remote machine & instance name).
        
        .EXAMPLE
            .\add_sql_server_instance_to_inventory.ps1 -mode domain
            
            Enumerating all instances on a network and adding them: Note that this strategy may take a considerable amount of time for larger networks.

        .EXAMPLE
            .\add_sql_server_instance_to_inventory.ps1 -mode local

            Enumerating all instances on the local machine and adding them.

        
    #>

    Param(
        [string]$instanceFqdn,
        [string]$mode
      )
      
      function addInstanceRequest($instanceFqdn) {
          $addUrl = 'http://localhost:15156/api/instances'
          $postData = @{
              InstanceFqdn=$instanceFqdn
          }
          $postJson = $postData | ConvertTo-Json
      
          try {
              $response = Invoke-RestMethod -Uri $addUrl -UseDefaultCredential -Method Post -Body $postJson -ContentType 'application/json'
              Write-Host "The command completed successfully."
          } catch {
              $responseCode = $_.Exception.Response.StatusCode.value__ 
              if ($responseCode -eq 417) {
                  Write-Host "The application encountered an error connecting to the database."
              } elseif ($responseCode -eq 409) {        
                  Write-Host "A name conflict occured when adding this instance. Please check if it has already been added."
              } else {
                  Write-Host "Unhandled response code:" $responseCode
              }
          }
      }
      
      function discoverHosts() {
          $output = ''
          if($mode -eq "local") {
              $output = Find-DbaInstance -ComputerName $env:computername | Select ComputerName,InstanceName
          } else {
              $output = Find-DbaInstance -DiscoveryType Domain | Select ComputerName,InstanceName
          }
          
          foreach ($line in $output) {
              if ($line.InstanceName.ToLower() -eq "mssqlserver" -Or $line.InstanceName.ToLower() -eq "default") {
                  $foundInstanceFqdn = $line.ComputerName
              } else {
                  $foundInstanceFqdn = ($line.ComputerName + "\" + $line.InstanceName).ToLower()
              }
              Write-Host "Adding instance:" $foundInstanceFqdn
              addInstanceRequest($foundInstanceFqdn)
          }
      }
      
      if (-Not (Get-Module -ListAvailable -Name dbatools)) {
          Install-Module dbatools
      }
      if ($mode -eq "singleHost") {
          if (!$instanceFqdn) {
              $instanceFqdn = Read-Host -Prompt 'Input server connection string'
          }
          addInstanceRequest($instanceFqdn)
      } elseif ($mode -eq "domain" -Or $mode -eq "local") {
          discoverHosts
      } else {
          Get-Help $MyInvocation.MyCommand.Definition  -Detailed
      }