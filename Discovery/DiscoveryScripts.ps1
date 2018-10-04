
# 
Measure-Command -Expression {
Find-DbaInstance -DiscoveryType All -DomainController rg-dc1.red-gate.com| Format-Table
} | Select-Object Minutes, Seconds, Milliseconds

