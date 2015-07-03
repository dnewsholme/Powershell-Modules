<#

.SYNOPSIS
A command to quickly Zip an file and encrypt it.

.DESCRIPTION
A command to quickly Zip an file and encrypt it.

.PARAMETER FilestoZip
Filename or foldername to add to archive

.PARAMETER Outputfilename
The filename for the zip to be created as

.PARAMETER Password
A String to be used as a password to encrypt the file

.PARAMETER CompressionType
Value to set as extension. 


.EXAMPLE
New-EncryptedZip  -filestozip "C:\file.txt" -outputfilename test.zip -password Pa$$word -CompressionType 'zip'

.NOTES
@Author Daryl Bizsley 2015
Last Edit 07/04/2015


#>





function New-EncryptedZip ([string]$filestozip, [string]$outputfilename, [string]$password, [ValidateSet('7z','zip','gzip','bzip2','tar','iso','udf')][string]$CompressionType){
    $basedir =  get-location #Get Run Dir
    $7zipbinary = "C:\Program Files\7-Zip\7z.exe" #7-Zip default binary location
    $7zipbinary64 = "C:\program files(x86)\7-Zip\7z.exe" #32 bit 7 Zip on x64 system
    if (test-path $7zipbinary) {$7zipbinary = $7zipbinary} #set location if binary is found
    elseif (test-path $7zipbinary64) {$7zipbinary = $7zipbinary64} #set to program files x86 if found
    else {
           $error | out-file "$basedir\error.log" -append
            throw "7zip binary not found"
            write-host "Attempting install of 7zip" | out-file "$basedir\error.log" -append
            #installing chocolatey package manager
            powershell.exe -NoProfile -ExecutionPolicy unrestricted -Command "'iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))'' && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
            #installing 7-zip
            start-process choco -arguments "install 7zip"
    } 
    if(test-path $outputfilename) {remove-item $outputfilename} #Delete file if it already exists
    $args = "a -t$CompressionType $outputfilename $filestozip -p $password" #Set 7 zip command line arguements 
    $process = start-process $7zipbinary -ArguementList $args -wait -passthru -windowstyle "Hidden"
    if (!(($process.HasExited -eq $true) -and($process.ExitCode -eq 0)))
    {
        $error | out-file "$basedir\error.log" -append
        throw "Zip file creation error with $outputfilename"
    }
}
