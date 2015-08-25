function Get-TomcatStatus{
    param(
        $tomcatserver = "localhost",
        $tomcatport = 8080,
        $tomcatuser,
        $tomcatpassword
    )
    #Get Credentials into the right format
    $tomcatpassword = ConvertTo-SecureString -string $tomcatpassword -asplaintext -force
    $cred = New-object -TypeName System.Management.Automation.PSCredential -argumentlist ($tomcatuser,$tomcatpassword)

    #Invoke the restinterface 
    $TomcatStats = Invoke-RestMethod -Uri http://$tomcatserver:$tomcatport/manager/status?XML=true -Credential $cred
    
    $threads = $TomcatStats.GetElementsByTagName("threadInfo") | ? {$_.currentThreadCount -ne 0}
    
    $Memory = $TomcatStats.GetElementsByTagName("memory") 
    
    $requestInfo = $TomcatStats.GetElementsByTagName("requestInfo") | ? {$_.bytessent -ne 0}

    #Populate output object
    $Output = New-object PsObject
    #Memory
    $output | add-member -type noteproperty -name "Memory_Used" -Value $memory.total
    $output | add-member -type noteproperty -name "Memory_free" -Value $memory.free
    $output | add-member -type noteproperty -name "Memory_Max" -Value $memory.max
    #threads
    $output | add-member -type noteproperty -name "Current_Threads_busy" -Value $threads.currentThreadsBusy
    $output | add-member -type noteproperty -name "Current_Thread_Count" -Value $threads.currentThreadCount
    $output | add-member -type noteproperty -name "Max_Threads" -Value $threads.MaxThreads
    #requestInfo
    $output | add-member -type noteproperty -name "Request_Max_ProcessingTime_ms" -Value $requestInfo.maxTime
    $output | add-member -type noteproperty -name "Request_Count" -Value $requestInfo.requestcount
    $output | add-member -type noteproperty -name "ProcessingTime_total_s" -Value $requestInfo.processingTime

    Return $output
}
