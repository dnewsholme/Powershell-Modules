<#

.SYNOPSIS
Scans a file and optionally will email report of infected files.

.DESCRIPTION


.PARAMETER File
Full Path to file to be scanned.

.PARAMETER MetascanServer
IP or hostname of the metascan server

.PARAMETER MailServer
Mailserver hostname or IP Address

.PARAMETER SenderAddress
Sender email address

.PARAMETER RecipientAddress
Recipient email addresss

.EXAMPLE
Request-MetaScan -file C:\temp\file.txt -metascanserver 192.168.49.10

.EXAMPLE
Request-MetaScan -file C:\temp\file.txt -metascanserver 192.168.49.10 -email -mailserver someserver -senderaddress metascan@domain.com -recipientaddress alerts@domain.com

.NOTES
Daryl Bizsley 2015

#>

function Request-Metascan {
    Param(
        [Parameter(Mandatory=$True,Position=1)][string]$file,
        $MetaScanServer,
        $mailserver,
        $senderaddress,
        $recipientaddress,
        [switch]$email

        )

        $css = 'h1 {
            margin-left: auto;
            margin-right: auto;
            text-transform: uppercase;
            text-align: center;
            font-size: 40pt;
            font-weight: bold;
        }

        h2 {
            margin-left: auto;
            margin-right: auto;
            text-transform: capitalize;
            text-align: center;
            font-family: "Segoe UI";
            font-size: 14pt;
            font-weight: bold;
        }

        description {
            text-transform: uppercase;
            margin-left: auto;
            margin-right: auto;
            text-align: center;
            font-family: "tahoma";
            font-weight: normal;
            font-size: 24pt;
            color:#2f2f2f;
        }

        servertype {
            text-transform: uppercase;
            margin-left: auto;
            margin-right: auto;
            text-align: center;
            font-family: "tahoma";
            font-weight: normal;
            font-size: 24pt;
            color:#2f2f2f;
        }


        update {
            margin-left: auto;
            margin-right: auto;
            text-align: center;
            font-family: "tahoma";
            font-weight: lighter;
            font-size: 10pt;
            color:#2f2f2f;
        }

        img {
            float: left;
            margin-left: 5em;
        }

        body {
            margin-left: auto;
            margin-right: auto;
            text-align: center;
            font-family: "Segoe UI";
            font-weight: lighter;
            font-size: 10pt;
            color:#2f2f2f;
            background-color: white;
        }

        table {
            margin-left: auto;
            margin-right: auto;
            border-width: 1px;
            border-style: solid;
            border-color: #2f2f2f;
            border-collapse: collapse;
        }

        th {
            font-family: "Segoe UI";
            font-weight: lighter;
            color: white;
            text-transform: capitalize;
            margin-left: auto;
            margin-right: auto;
            border-width: 1px;
            border-style: solid;
            border-color: #2f2f2f;
            background-color: #d32f2f;
        }

        td {
            margin-left: auto;
            margin-right: auto;
            border-width: 1px;
            border-style: solid;
            border-color: #2f2f2f;
            background-color: white;
        }

        '
    $filename = (get-item $file).Name
    $parms = @{
    "Method" = "Post"
    "uri" = ('http://{0}:8008/metascan_rest/file' -f $MetaScanServer)
    }
    #Send file to be scanned.
    $request = Invoke-RestMethod @parms -Headers @{"filename" = ($filename)} -body $file
    #Retrieve Result
    $result = Invoke-RestMethod -Uri ('http://{0}:8008/metascan_rest/file/{1}' -f $MetaScanServer,$request.data_id)
    while (($result.scan_results).progress_percentage -ne 100){
        $result =     $result = Invoke-RestMethod -Uri ('http://{0}:8008/metascan_rest/file/{1}' -f $MetaScanServer,$request.data_id)
    }
    if (($result.scan_results).scan_all_result_a -ne "Clean"){
      Write-Output "File Clean"
    }

    Else {
      Write-output "File Infected removing file"
      Remove-Item -Path (get-item $file) -Force
      #Create Object for email output
      if($email){
            $scanresults = New-Object PSObject
            $scanresults | add-member -MemberType NoteProperty -Name FileName -Value ($result.file_info).display_name
            $scanresults | add-member -MemberType NoteProperty -Name FileSize -Value ($result.file_info).file_size
            $scanresults | add-member -MemberType NoteProperty -Name FileInfo -Value ($result.file_info).file_type_description
            $scanresults | add-member -MemberType NoteProperty -Name ScanResult -Value ($result.scan_results).scan_all_result_a
            $scanresults | add-member -MemberType NoteProperty -Name FileSource -Value ($result.source)
    
    
            #Send Email Alert
            $html =  convertto-html -head "<style>$css</style>" -Title "Infected Files Found" -body ("<p>Review files at http://{0}:8008/management/quarantine</p>" -f $MetaScanServer) 
            $html += $scanresults | ConvertTo-Html
            $pass = ConvertTo-SecureString "whatever" -asplaintext -force
            $creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "NT AUTHORITY\ANONYMOUS LOGON", $pass
            $html | out-file $env:TEMP\1.html
            [string]$html = Get-Content $env:TEMP\1.html
            Send-MailMessage -from $senderaddress -to $recipientaddress -SmtpServer $MailServer -Subject "Infected File Detected" -bodyashtml $html -port 25 -credential $creds
        }
    }

}
