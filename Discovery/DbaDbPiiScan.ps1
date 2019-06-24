
$params =  @{
    SqlInstance     =   "rm-iclone1.testnet.red-gate.com"
    SqlCredential   =   "RedgateDLM"
    Database        =   "StackOverflow2010"
    SampleCount     =    5
    PatternsFile    =   "/Users/richard.macaskill/Dev/Masking and Config Scripts/pii-patterns.json"
}

Invoke-DbaDbPiiScan @params | Format-Table
