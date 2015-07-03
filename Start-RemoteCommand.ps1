<#

.SYNOPSIS
A command to quickly set up a remote connection to 1 or many servers and run a command.

.DESCRIPTION
A command to quickly set up a remote connection to 1 or many servers and run a command. 

.PARAMETER ServerName
Servers in the hostname format

.PARAMETER Command
This contains the command you would like to execute
All Commands must be enclosed in "" any strings must be enclosed with ''.
.PARAMETER Credential
Credentials to connect to specified server.

.EXAMPLE
This would get the hostname of all servers
Start-RemoteCommand -command "hostname"

.EXAMPLE
If you would like to run multiple commands such as getting the hostname then run another command you must use the backtick and new line `n
Start-RemoteCommand -command "hostname `n get-item 'C:\Program Files\Lowell Group\Lowell.Synergy.2.5.0\Lowell.Synergy.UI.exe' | select LastwriteTime"

.NOTES
@Author Daryl Bizsley 2015
Last Edit 27/3/2015

#>
function Start-RemoteCommand{
  [CmdletBinding()]
  param(
    [Parameter(ValueFromPipeline=$True)]$ServerName,
    $Credential,
    [String]$command
    )
    
    $array = @() # Intialise the output array
    $parms = @{'ErrorAction'='Continue'}
    if ($Credential) {$parms.add('Credential', $Credential)} # If Credential is specified add to command else don't use.
    if (!($servername)) {exit}
    $ServerName | % {
        $parms.remove('ComputerName') # If ServerName is set then clear it.
        $parms.remove('Name')
        $parms.add('ComputerName',$_) # If ServerName is set then add to list of parameters
        $parms.add('Name',$_)# If ServerName is set then set name of session to ComputerName
        $Error.Clear()
        $ps = New-PSSession @Parms #Uses splat table to pass parameters
        if (($Error.count) -eq "0"){
            $array += Invoke-Command -Session $ps -ScriptBlock {powershell.exe -command $args[0] } -ArgumentList $command
            }
        Else {
              $Server = $_.Name
              $array += "$server is unreachable/offline"
              }
    return $array # Return the collected data
    }
}
