<#

.SYNOPSIS
Downloads a file from a Content Delivery Network.

.DESCRIPTION
Downloads a 10MB file from a Content Delivery Network and outputs the speed in Mbps.

.EXAMPLE
New-Speedtest

.NOTES
Daryl Bizsley 2015

#>
Function Measure-NetworkSpeed{
    "{0:N2} Mbit/sec" -f ((10/(Measure-Command {Invoke-WebRequest 'http://client.akamai.com/install/test-objects/10MB.bin'|Out-Null}).TotalSeconds)*8)
}
