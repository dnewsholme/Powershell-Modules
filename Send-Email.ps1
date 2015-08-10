<#

.SYNOPSIS
Checks all files in a specified path for files older than the specified amount of days, then deletes them and emails a report.

.DESCRIPTION
Checks all files in a specified path for files older than the specified amount of days, then deletes them and emails a report.

.PARAMETER Path 
Folder path. Should be enclosed in quotation marks.

.PARAMETER MaxAge
Number of days after which as file should be deleted.

.PARAMETER MailServer
SMTP server address

.PARAMETER RecipientAddress
Recipient email

.PARAMETER SenderAddress
Sender email address

.PARAMETER MailCredential
Credentials for mailserver for sender address. If none are specified anonymous credentials will be used.

.EXAMPLE
Remove-OldFiles -Path "C:\temp\" -MaxAge 30 -mailserver mail.server.com -recipientaddress "someone@domain.com" -senderaddress "filedeletion@domain.com"

.NOTES


#>


function Remove-OldFiles {

    param(
        $Path,
        $MaxAge,
        $mailserver,
        $recipientaddress,
        $senderaddress,
        $mailcredential
        )
        #REGION BEGIN
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
            font-size: 18pt;
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
        #REGION END
        $files = get-childitem -recurse $path | where {$_.LastWriteTime -lt ((get-date).adddays(-$MaxAge))}
        if ($files -ne $null){ 
            $files | % {remove-item $_.FullName} -Confirm:$false
        
        $html =  convertto-html -head "<style>$css</style>" -Title "Deleted Files for $path" -body "<h1>Deleted Files for $path</h1>"
        $html +=  $files | select FullName,LastWriteTime | convertto-html}
        ELSE {$html = convertto-html -Body "No Files older than $maxage days"}        
        $html | out-file $env:TEMP\1.html
        [string]$html = Get-Content $env:TEMP\1.html
        #Setup Anonymous credentials to pass to mail cmdlet.

        $pass = ConvertTo-SecureString "whatever" -asplaintext -force
        $creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "NT AUTHORITY\ANONYMOUS LOGON", $pass
        Send-Mail -From $senderaddress -To $recipientaddress -SmtpServer $MailServer -Subject "File Deletions for $path" -bodyashtml $html -port 25 -Credential $creds
}

<#

.SYNOPSIS
Sends a email with support for anonymous authentication

.DESCRIPTION
Sends a email with support for anonymous authentication

.PARAMETER MailServer
The SMTP Server

.PARAMETER SenderAddress
Address to send from

.PARAMETER RecipientAddress
Address to send to

.PARAMETER Subject
Subject for the email

.PARAMETER Body
Body as plaintext

.PARAMETER Bodyashtml
Body in html format

.PARAMETER MailCredential
Mailserver credentials, if not specified use anonymous authentication

.EXAMPLE


.NOTES
Daryl Bizsley 2015

#>
function Send-Mail {
    [CmdletBinding()]
    param(
    [Parameter(ValueFromPipeline=$True)]$body,
    [Parameter(ValueFromPipeline=$True)]$bodyashtml,
    $mailserver,
    $recipientaddress,
    $senderaddress,
    $subject,
    $port,
    $mailcredential
    )
        if(!($mailcredential)){
            $pass = ConvertTo-SecureString "whatever" -asplaintext -force
            $creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "NT AUTHORITY\ANONYMOUS LOGON", $pass
        }
        ELSE {$creds = $mailcredential}
        if ($bodyashtml){
            send-mailmessage -From $senderaddress -To $recipientaddress -SmtpServer $MailServer -Subject $subject -bodyashtml $bodyashtml -port $port -Credential $creds
        }
        else {
            send-mailmessage -From $senderaddress -To $recipientaddress -SmtpServer $MailServer -Subject $subject -body $body -port $port -Credential $creds
            }
}
