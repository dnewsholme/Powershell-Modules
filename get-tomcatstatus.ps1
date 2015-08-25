function Get-TomcatStatus{
    param(
        [ValidateSet("http","https")]$protocol,  
        $tomcatserver = "localhost",
        $tomcatport = 8080,
        [PSCredential]$Credential
    )

    #Invoke the restinterface 
    try { 
        $TomcatStats = Invoke-RestMethod -Uri ('{0}://{1}:{2}/manager/status?XML=true' -f $protocol,$tomcatserver,$tomcatport) -Credential $Credential -ErrorAction Stop
    }
    catch [System.Net.WebException]{
        return "Unable to connect to host"
        break
    }

    $threads = $TomcatStats.GetElementsByTagName("threadInfo") 
    
    $Memory = $TomcatStats.GetElementsByTagName("memory") 
    
    $requestInfo = $TomcatStats.GetElementsByTagName("requestInfo")
    
    #Populate output object
    $Output = New-object PsObject

    $parms = @{
        Type = "noteproperty"
    }
    #Memory
    $output | add-member @parms -name "Memory_Used" -Value $memory.total
    $output | add-member @parms -name "Memory_free" -Value $memory.free
    $output | add-member @parms -name "Memory_Max" -Value $memory.max
    #threads
    $output | add-member @parms -name "Current_Threads_busy" -Value $threads.currentThreadsBusy
    $output | add-member @parms -name "Current_Thread_Count" -Value $threads.currentThreadCount
    $output | add-member @parms -name "Max_Threads" -Value $threads.MaxThreads
    #requestInfo
    $output | add-member @parms -name "Request_Max_ProcessingTime_ms" -Value $requestInfo.maxTime
    $output | add-member @parms -name "Request_Count" -Value $requestInfo.requestcount
    $output | add-member @parms -name "ProcessingTime_total_s" -Value $requestInfo.processingTime

    Return $output
}
