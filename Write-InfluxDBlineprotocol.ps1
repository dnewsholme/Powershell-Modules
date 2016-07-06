<#

.SYNOPSIS
Writes a datapoint to an influxdb server v0.9+ using the line protocol over http api.

.DESCRIPTION
A cmdlet to allow output of data to influxdb for graphing.

.PARAMETER influxserver
The server name or IP of the influxdb server.

.PARAMETER db
The influxdb database to write the data to.

.PARAMETER port
Port of the influxdb server, normally 8086

.PARAMETER user
Username for authentication

.PARAMETER password
Password of the user

.PARAMETER tags
Extra tags to be applied. Should be in the format region=eu-west1. 
Multiple tags can be used but must be seperated by commas eg. region=eu-west1,datacenter=london

.PARAMETER hostname
Hostname the datapoint relates to.

.PARAMETER metricname
Name of the metric you are writing.

.PARAMETER datapoint
The Value of the data.

.EXAMPLE
Write-influxdb -influxserver influxdb.local -db default -port 8086 -user admin -password admin -tags "region=eu-west1,datacenter=london" -hostname server01 -metricname load_5 -value 3


.NOTES
Daryl Bizsley 2016

#>



Function Write-Influxdb {
    param(
        $influxserver,
        $db,
        $port,
        $user,
        $password,
        $tags,
        $hostname = $env:computername,
        $metricname,
        $datapoint
    )
    $error.Clear()
    $passwordAsSecureString = ConvertTo-SecureString "$password" -AsPlainText -Force
    $cred = new-object System.Management.Automation.PSCredential ("$user", $passwordAsSecureString)
    if ($tags){
        try{
            $request = Invoke-WebRequest ('http://{0}:{1}/write?db={2}' -f $influxserver,$port,$db ) -Method post -body ('{0},host={1},{2} value={3}' -f $metricname,$hostname,$tags,$datapoint) -Credential $cred
            }

        catch{
               $error[0].Exception
            }
    }
    ELSE{
        try{
            $request = Invoke-WebRequest ('http://{0}:{1}/write?db={2}' -f $influxserver,$port,$db ) -Method post -body ('{0},host={1} value={2}' -f $metricname,$hostname,$datapoint) -Credential $cred
            }

        catch{
               $error[0].Exception
            }
    }

    if ($request.StatusCode -eq 204){
        
    }
    else {
        write-output $request.body
    }
}
