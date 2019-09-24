function Read-DataCatalogColumns {
    <#
    .SYNOPSIS
        Returns column metadata from Redgate SQL Data Catalog API
    .DESCRIPTION
        This function take a directory parameter and then parses all files found for specified values and replaces them with a generic value so that the log file 
        can be shared with an audience that is not permitted to see sensitive data (database names, server names, IP addresses, etc)
        
    .EXAMPLE
        Read-DataCatalogColumns '', ''
        All files found in the specified directory will be parsed for values found in a lookup list and replaced with generated, generic values
    .INPUTS
        A valid local directory unc
    .OUTPUTS
        a MaskedValues.txt file is created giving the data owner a mapping reference between the sensitive value and the mask value that has been used
    .NOTES
        All target files are altered
        TODO:: 
            Add a -copy switch to allow the source file to remain untouched. Until then, the assumption is that we are working on a copy of the original anyway
    #>
    [CmdletBinding()]
    param(
        # Specifies a SQL Instance.
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "FQDN of SQL Instance.")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript()]
        [string[]]$TargetInstance
    )
    param(
        # Specifies a SQL Instance.
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Name of SQL Database.")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript()]
        [string[]]$TargetDatabase
    )

    # replacing sensitive values in a log file with generic descriptive values

    # $Secrets is a 3 column array - the sensitive value and the value type are entered by the data owner
    begin {
        $MaskValues = "C:\temp\MaskValues.txt" # created by this script - doesnt need to be created before the script is executed
        $SecretsFile = "C:\temp\SensitiveStrings.txt" # the source of the sensitive content - this file needs to exist
        $Secrets = @()

        # check the secrets file exists, if not create a template example
        if (!(Test-Path $SecretsFile)) {
            Write-Verbose "No Secrets file found. Template secrets file created at $SecretsFile"
            $Template = @('ItemName, ItemType, ItemMask')
            $Template += @('MyServer, Server,')
            $Template += @('AdminAccount, Account,')
            $Template += @('IP.Add.rr.ess, IP,')
            $Template += @('BusinessSystem, SystemName,')
            $Template += @("`r`n**** DELETE THESE LINES. ****`r`nSample sensitive strings file.`r`nenter your confidential data for each item type.`r`ncopy rows to allow for more than one of any type.`r`n leave the Mask column empty.`r`n Be sure to leave a trailing comma on each line.`r`n****DELETE THESE LINES.****")

            $Template | Out-File $SecretsFile

            Write-Warning "No secrets file found to apply masks to sensitive content. A sample file has been created at $SecretsFile. Please edit this file and enter your sensitive values that need masking."
        }
        else {
            $Secrets = Import-Csv $SecretsFile
            Write-Verbose "Secrets file imported"
        }

        $x = 1
        foreach ($Secret in $Secrets) {
            Write-Verbose "Setting Mask value for $Secret"
            switch ($Secret.ItemType) {
                "Server" { $Secret.Mask = "Server$x" }
                "Account" { $Secret.Mask = "Account$x" }
                "IP" { $Secret.Mask = "192.168.0.IP$x" } 
                "System" { $Secret.Mask = "System$x" }
                "URL" { $Secret.Mask = "URL$x" }
                "Database" { $Secret.Mask = "Database$x" }
                #"ToBeDefined" { $Secret.Mask = "Value$x" }
                default {Write-Warning "Found item type $($Secret.ItemType) in the SensitiveStrings file which has no mask algorithm. Please edit the function to provide a suitable mask"}
            }
            $x++
        }
    }
    get-process {
        # record the translation from sensitive value to mask value so that data owner can infer correct place to carry out advice/instruction after sensitive log has been reviewed
        $Secrets | Out-File $MaskValues
        Write-Verbose "Mask to Secret settings set in $MaskValues"
        # read content of files and replace sensitive strings with generic mask values

        foreach ($File in Get-ChildItem $TargetFolder) {
            $Replace = $null
            $Content = get-content -path $File.FullName
            foreach ($Secret in $Secrets | Where-Object Mask) {
                Write-Verbose $Secret | Select-Object ItemName, Mask
                # first iteration through the file we need to use the $Content variable, after that subsequent changes are made in the $Replace variable
                if (!($Replace)) {
                    $Replace = $content -Replace ($($Secret.ItemName), $($Secret.Mask))
                }
                else {
                    $Replace = $Replace -Replace ($($Secret.ItemName), $($Secret.Mask))   
                }        
            }
            set-content $file.FullName -value $Replace -Force
        }
    }

    end {}
}