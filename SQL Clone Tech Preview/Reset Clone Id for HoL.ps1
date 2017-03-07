param($idPrefix = 'HandsOnLabs')
# Note that cookies must also be cleared for it to count as a new intercom user on next refresh
$dateTime = (Get-Date -format "HH:mm dd-MM-yyyy")
$random = [guid]::NewGuid().ToString().Substring(0,4)
$newId = "$idPrefix $random $dateTime"
$newEmail = "$idPrefix-$random@red-gate.com"
$regPath = 'HKLM:\SOFTWARE\Red Gate\SQL Clone'
Set-ItemProperty -Path $regPath -Name InstallId -Value $newId
Set-ItemProperty -Path $regPath -Name Email -Value $newEmail
#Stop-Service -DisplayName "Redgate SQL Clone"
#Start-Service -DisplayName "Redgate SQL Clone"