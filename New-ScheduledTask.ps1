<#

.SYNOPSIS
Create a new scheduled task

.PARAMETER TaskName
Name of task to be created

.PARAMETER SourceScript
File location of the script file you wish to create a task for. This script will then make a copy of it in the destination you specify. This should be a full file path
EG \\server\share\script.ps1

.PARAMETER ScriptDestination
Where on the machine you would like to store the script to be run. This must be a folder.

.PARAMETER ScriptName
Name of script. For example filecopier.ps1

.PARAMETER Username
Username the scheduled Task should run as.

.PARAMETER Password
Password for that user

.PARAMETER Time
Time the script should run. EG 04:00

.PARAMETER Schedule
How often the task should run.

.EXAMPLE
New-ScheduledTask -Taskname Test -ScriptDestination "C:\Scripts" -ScriptName Test.ps1 -SourceScript "\\537210-pdapi12\packages\" -Username 'contoso\testuser' -Password 'test1234' -Time '04:00' -Schedule 'Daily'


.NOTES
Daryl Bizsley 2015


#>


function New-ScheduledTask([String]$TaskName, [String]$SourceScript, [String]$ScriptDestination, [String]$ScriptName, [String]$Username, [String]$password, [String]$Time, [ValidateSet('MINUTE', 'HOURLY', 'DAILY', 'WEEKLY', 'MONTHLY', 'ONCE', 'ONSTART', 'ONLOGON', 'ONIDLE', 'ONEVENT')][string]$Schedule ){
    ####Check if scheduled task already installed
    $tasks = $null
    $tasks = schtasks /query /tn $Taskname
    if ($tasks -eq $null){
        $password = $Scheduledtaskpass
        ###Create Scheduled Task to Run###
        Copy-Item "$SourceScript" "$Scriptdir\$ScriptName" -Confirm:$false
        $text = "C:\windows\system32\windowspowershell\v1.0\powershell.exe -ExecutionPolicy unrestricted -file $Scriptdir\$ScriptName"
        $TaskName = $Taskname
        $TaskRun = $text 
        #create task now
        schtasks.exe /create /sc $Schedule /ru $Username /rp $password /tn $Taskname /tr $TaskRun /st $Time
        write-Output "Scheduled task successfully set up"
        }
    Else {write-Output "skipping scheduled task already present"}

}
