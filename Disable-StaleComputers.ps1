<#

.SYNOPSIS
Moves and disables stale computer accounts.

.Description
Moves computers older than set days into lost + Found and then disables the account.

.PARAMETER Credential
Pass stored credentials.

.PARAMETER daysago
How many days ago is the threshold for last password set.

.EXAMPLE
Disable-StaleComputers -credential $cred -daysago 90

.NOTES
Daryl Bizsley 2015

#>

function Disable-StaleComputers{
    param(
        $Credential,
        $daysago
    )
    $domain = ($env:USERDNSDOMAIN).split(".")
    $domainprefix = $domain[0]
    $domainsuffix = $domain[1]

    $90daysago = (get-date).AddDays(-$daysago)
    $stalecomputers = Get-ADComputer -Filter {PasswordLastSet -lt $90daysago} -Properties PasswordlastSet
    if ($Credential){
        $stalecomputers |  Move-ADObject -TargetPath "CN=LostAndFound,DC=$domainprefix,DC=$domainsuffix" -Credential $Credential
        $stalecomputers | Disable-ADAccount -$Credential
    }
    else {
        $stalecomputers |  Move-ADObject -TargetPath "CN=LostAndFound,DC=$domainprefix,DC=$domainsuffix" -Credential $Credential
        $stalecomputers | Disable-ADAccount -$Credential
    }

    $stalecomputers | Write-Output
}
