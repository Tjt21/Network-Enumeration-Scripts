# Network-Enumeration-Scripts
Tools and Scripts used to gather network data

## DNS-Mapper
Powershell Script that enumerates all host records (A and PTR) in a provided network. The network must be provided in CIDR notation, and multiple networks can be supplied to the script, using commas as a delimiter.

**Options:**

$NetworkCIDR - String[] - The network address
$SleepTime - int - Time to wait between queries (in milliseconds)
$FoundRecordsOnly - Boolean - Returns only IPs with A or PTR records

**Usage:** 

.\DNS-Mapper.ps1 -NetworkCIDR 192.168.0.0/24 -SleepTime 50 -FoundRecordsOnly $True

**File Redirection:**

Since this script uses the Write-Output functionality of PowerShell, the output can be redirected and piped into other scripts.

`.\DNS-Mapper.ps1 192.168.0.0/24 > output.txt` 

**Examples:**

Gathers only the hostnames of found hosts

`.\HostRecordEnumerator.ps1 -NetworkCIDR 10.32.0.0/24 -SleepTime 50 -FoundRecordsOnly $true | ForEach-Object { $_.Split(",")[1] }`
