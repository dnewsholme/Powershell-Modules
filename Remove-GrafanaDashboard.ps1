<#

.SYNOPSIS
Deletes a dashboard from grafana

.DESCRIPTION


.PARAMETER grafanaserver
The hostname of the server running grafana

.PARAMETER apikey
Your grafana api key

.PARAMETER dashboard
Dashboard name as it appears in the grafana url

.EXAMPLE

Delete-GrafanaDashboard -grafanaserver grafana -apikey "eyJrIjoiM2xubUVlRkoxZGNuM2gyQ1VQWDdiTzNaUzEyV3paZDQiLCJuIjoiYWRtaW4iLCJpZCI6Mn0=" -dashboard home

.NOTES
Daryl Bizsley 2015

#>


function Remove-GrafanaDashboard{
    param(
    $grafanaserver,
    $apikey,
    $dashboard
    )
        Invoke-RestMethod -Method Delete -Uri (http://{0}/api/dashboards/db/{1} -f $grafanaserver,$dashboard) -Headers @{"Authorization" = " Bearer $apikey"}

}
