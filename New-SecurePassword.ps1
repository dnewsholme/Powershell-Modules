<#

.SYNOPSIS
Creates a new random password up to 128 Chars long.

.DESCRIPTION
Creates a new random password up to 128 Chars long.

.PARAMETER number
The length of the password to be generated. It defaults to 8

.EXAMPLE
New-RandomComplexPassword 12

.NOTES
Daryl Bizsley 2015

#>

Function New-RandomComplexPassword (){
    param ( [int]$Length = 8 )
    #Usage: New-RandomComplexPassword 12
    $Assembly = Add-Type -AssemblyName System.Web
    $RandomComplexPassword = [System.Web.Security.Membership]::GeneratePassword($Length,2)
    Write-Output $RandomComplexPassword
}
