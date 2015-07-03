<#

.SYNOPSIS
Retrieves a devices external ip address.

.DESCRIPTION
Retrieves a device's IP Address from ifconfig.me
Requires Powershell 3.0 for invoke-webrequest.

.EXAMPLE
Get-ExternalIP

.NOTES
Daryl Bizsley 2015

#>

function Get-ExternalIP {
(Invoke-WebRequest ifconfig.me/ip).Content
}
