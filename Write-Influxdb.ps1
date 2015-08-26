<#

.SYNOPSIS
Writes datapoints to a influxdb server

.DESCRIPTION
Writes datapoints to a influxdb server in Json format

.PARAMETER influxserver
Servername which hosts the influxdb instance

.PARAMETER port
Influxdb port number. This is normally 8086

.PARAMETER db
Influxdb database to write to

.PARAMETER User
Username for user with rights to influxdb

.PARAMETER Password
Password for user with rights to influxdb

.PARAMETER Hostname
Hostname of the device the metric relates to.

.PARAMETER Metricname
Name of the metric which will be displayed after the hostname

.PARAMETER Datapoint
Value to be entered into influxdb

.EXAMPLE
Write-Influxdb -influxserver influx01 -influxdb db -influxuser admin -influxpassword admin -hostname server01 -metricname tomcat_memory_free -datapoint 1024

.NOTES


#>

function Write-Influxdb {
    param(
        $influxserver,
        $db,
        $port,
        $user,
        $password,
        $hostname = $env:computername,
        $metricname,
        $datapoint
        )
    #Form the url to call
    $influxdburl = 'http://{0}:{1}/db/{2}/series?u={3}&p={4}' -f $influxserver,$port,$db,$user,$Password
    #Writes data points to influxdb
    $json = ('[("name":"{0}.{1}","columns":["value"],"points":[[{2}]])]' -f $hostname,$metric,$datavalue) -replace '\(','{' -replace '\)','}'
    try {
        Invoke-RestMethod -Uri $influxdburl -ContentType "application/json" -Method Post -Body $json -erroraction stop
    }
    Catch {"Writing to influxdb server failed."}
    return "OK"
}
