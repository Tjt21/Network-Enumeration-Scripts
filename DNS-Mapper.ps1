# Author: Thomas Thibaut
# Date: 03/22/2019
# Version: 1.0
# Desc: Automates nslookups across the supplied IP range. 

# Parameters
Param(
    [String[]]$NetworkCIDR, # Network address in CIDR notation. Multiple arguments can be supplied using commas. Required.
    [int]$SleepTime, # In milliseconds. Recommended.
    [Bool]$FoundRecordsOnly # Return only found records. Optional.
)

# If no network address provided, end script.
if ( -not ($NetworkCIDR)) {
    Throw "You must supply a value for -NetworkCIDR. 
    This value should represent the NETWORK address of a given subnet. 
    Do not use a host or broadcast address. You can also supply multiple ranges using commas. 
    For example, 192.168.0.0/24, 172.26.0.0/23"
}

# Iterate through provided networks
ForEach ($Network in $NetworkCIDR) {

    # Regex for IP String
    $RegexForIP = "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/(3[0-2]|[1-2][0-9]|[0-9]))$"
    if ($Network -notmatch $RegexForIP) {
        Throw "IP Address not in valid CIDR format"
    }

    # Split IP and Subnet Mask
    $IPAddressLength = 32
    $IP = $Network.Split("/")[0]
    $NetworkBits = [int]$Network.Split("/")[1]
    $HostBits = $IPAddressLength - $NetworkBits

    # Identify octet of interest and determine number of networks to sweep.
    $OctetOfInterest = [math]::Floor($NetworkBits / 8)
    $OctetOfInterestIterations = [math]::Pow(2, 8 - $NetworkBits % 8)

    # Determine number of times to iterate through each subnet.
    if ($NetworkBits -le 8) {
        $FirstOctetIterations = [math]::Pow(2, 8 - $NetworkBits)
        $SecondOctetIterations = 256
        $ThirdOctetIterations = 256
        $FourthOctetIterations = 256
    } elseif ($NetworkBits -gt 8 -and $NetworkBits -le 16) {
        $FirstOctetIterations = 1
        $SecondOctetIterations = [math]::Pow(2, 16 - $NetworkBits)
        $ThirdOctetIterations = 256 
        $FourthOctetIterations = 256
    } elseif ($NetworkBits -gt 16 -and $NetworkBits -le 24) {
        $FirstOctetIterations = 1
        $SecondOctetIterations = 1
        $ThirdOctetIterations = [math]::Pow(2, 24 - $NetworkBits)
        $FourthOctetIterations = 256
    } elseif ($NetworkBits -gt 24) {
        $FirstOctetIterations = 1
        $SecondOctetIterations = 1
        $ThirdOctetIterations = 1
        $FourthOctetIterations = [math]::Pow(2, $HostBits)
    }

    # First Octet 
    for($i = 0; $i -lt $FirstOctetIterations; $i++) {

        # Increment value in octet.
        $FirstOctet = [int]($IP.Split(".")[0]) + $i

        # If value exceeds IP range, break.
        if ($FirstOctet -gt 255) {
                    break
        }

        # Second Octet
        for($j = 0; $j -lt $SecondOctetIterations; $j++) {
        
            # Increment value in octet.
            $SecondOctet = [int]($IP.Split(".")[1]) + $j
        
            # If value exceeds IP range, break.
            if ($SecondOctet -gt 255) {
                    break
                }

            #  Third Octet
            for($k = 0; $k -lt $ThirdOctetIterations; $k++) {

                # Increment value in octet.
                $ThirdOctet = [int]($IP.Split(".")[2]) + $k

                # If value exceeds IP range, break.
                if ($ThirdOctet -gt 255) {
                    break
                }

                # Fourth Octet
                for($l = 0; $l -lt $FourthOctetIterations; $l++) {
      
                    # If value exceeds IP range, break.
                    if ($FourthOctet -gt 255) {
                        break
                    }
                
                    # Increment value in octet.
                    $FourthOctet = [int]($IP.Split(".")[3]) + $l
                
                    # Parse Current Iteration of IP
                    $CurrentIP = [String]$FirstOctet + "." + $SecondOctet + "." + $ThirdOctet + "." + $FourthOctet
                
                    # Resolve hostname from IP address
                    $HostRecord = Resolve-DnsName -Name $CurrentIP -DnsOnly -ErrorAction SilentlyContinue

                    # Write Output. Can be redirected to file using '>'
                    if ($HostRecord -ne $null) {
                        Write-Output "$CurrentIP,$($HostRecord.NameHost)"
                    } else {
                        # If the -FoundRecordsOnly flag is set. Do not write this output.
                        # Otherwise, write N/A
                        if ($FoundRecordsOnly -eq $false) {
                            Write-Output "$CurrentIP,N/A"
                        }
                    }

                    # Give that DNS Server a break
	                Start-Sleep -Milliseconds $SleepTime
                }
            }
        }
    }
}
