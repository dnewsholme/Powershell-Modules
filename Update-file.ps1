<#

.SYNOPSIS
This will check for a file update and replace the original if a newer version exists. It will Optionally Restart a service too.


.DESCRIPTION
This will check for a file update and replace the original if a newer version exists. It will Optionally Restart a service too.

.PARAMETER LocalFile
Full path of the local file to check.

.PARAMETER RepositoryFile
Full path of the remote file to check.

.EXAMPLE
Update-file -localfile 'C:\folder\file.exe' -Repositoryfile '\\someshare\folder\file.exe' -servicename tomcat7

.NOTES
Daryl Bizsley 2015

#>

function Update-File{
    param(
        [string]$LocalFile,
        [string]$RepositoryFile,
        )

    $localhash = (get-filehash $localFile).hash
    $repositoryhash = (get-filehash $repositoryfile).hash
    if ($localhash -ne $repositroyhash) {
        copy-item $repositoryfile $localfile -force -confirm:$false
        }
        
    }
