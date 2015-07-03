<#

.SYNOPSIS
Test if a port is listening on a remote computer

.DESCRIPTION
Test if a port is listening on a remote computer
Returns true or false.

.PARAMETER ComputerName
Computername

.PARAMETER IP
IP Address. Optional

.PARAMETER Port
Port number

.PARAMETER Protocol
Protocol

.EXAMPLE
test-port -computername server1 -port 25 -protocol TCP

.NOTES
Daryl Bizsley 2015

#>


function Test-Port
{
    Param(
        [parameter(ParameterSetName='ComputerName', Position=0)]
        [string]
        $ComputerName,

        [parameter(ParameterSetName='IP', Position=0)]
        [System.Net.IPAddress]
        $IPAddress,

        [parameter(Mandatory=$true , Position=1)]
        [int]
        $Port,

        [parameter(Mandatory=$true, Position=2)]
        [ValidateSet("TCP", "UDP")]
        [string]
        $Protocol
        )

    $RemoteServer = If ([string]::IsNullOrEmpty($ComputerName)) {$IPAddress} Else {$ComputerName};

    If ($Protocol -eq 'TCP')
    {
        $test = New-Object System.Net.Sockets.TcpClient;
        Try
        {
            #Write-Host "Connecting to "$RemoteServer":"$Port" (TCP)..";
            $test.Connect($RemoteServer, $Port);
            Write-Output $True;
        }
        Catch
        {
            Write-Output $False;
        }
        Finally
        {
            $test.Dispose();
        }
    }

    If ($Protocol -eq 'UDP')
    {
        Write-Host "UDP port test functionality currently not available."
    }
}
