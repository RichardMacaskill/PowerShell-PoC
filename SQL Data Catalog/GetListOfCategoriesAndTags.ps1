
$ServerRootUrl = 'http://rm-win10-sql201.testnet.red-gate.com:15156'
$AuthToken = 'NTE3NjA0OTQ0NjE0Nzg1MDI0Ojc5NzViY2YwLTAyOGUtNGU4My1hZjY4LTJkNWE0ZmI4MmNlMw=='

$AddUrl = "$ServerRootUrl/api/tagCategories"

$Headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$Headers.Add("Authorization", "Bearer $AuthToken")

$Taxonomy = Invoke-RestMethod -Uri $AddUrl `
    -Headers $Headers `
    -Method Get `
    -AllowUnencryptedAuthentication 

$Taxonomy | Format-Table

