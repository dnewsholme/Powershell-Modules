```PowerShell
<#

.SYNOPSIS
Quickly check for differences in files by the MD5 hash.

.DESCRIPTION
Quickly check for differences in files by the MD5 hash.

.PARAMETER Sourcedirectory
This should be the source directory to compare fromt.

.PARAMETER Comparisondirectory
This should be the local directory to compare against.

.EXAMPLE
compare-directories -sourcedirectory "\\server\share\folder" -comparisondirectory "C:\folder\"


.NOTES
@Author Daryl Bizsley 2015
Last Edit 27/3/2015

#>

function Compare-Directories{
    [CmdletBinding()]
    param(
        [string]$sourcedirectory,
        [string]$comparisondirectory
    )
        #Get Hashes of source
        $sourcehashes =  get-childitem $sourcedirectory |% {@{$_.Name = (Get-FileHash $_.FullName).hash}}
        #Get Hashes of others
        $comparisonhashes = get-childitem $comparisondirectory |% {@{$_.Name = (Get-FileHash $_.FullName).hash}}
    
    
        #compare and show non-matching files as output
        $results = Compare-Object $sourcehashes $comparisonhashes
        $results.InputObject
}
```
