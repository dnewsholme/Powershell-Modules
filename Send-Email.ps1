<#

.SYNOPSIS
A command to send an email.

.DESCRIPTION
A command to send a email using a specified server.

.PARAMETER MailServer
SMTP Hostname

.PARAMETER emailto
The Recipient Address

.PARAMETER emailfrom
The sender address

.PARAMETER subject
Subject name

.PARAMETER mailattachment
Attachment to be sent.

.EXAMPLE
Send-Mail -mailserver mail.domain.com -emailto someone@domain.com -emailfrom mailer@domain.com -emailbody "test" -subject Test -mailattachment "C:\file.txt"

.NOTES
@Author Daryl Bizsley 2015
Last Edit 27/3/2015

#>
function Send-Mail {
    [CmdletBinding()]
    param(
    [Parameter(ValueFromPipeline=$True)][string]$emailbody,
    [string]$mailserver,
    [string]$emailto,
    [string]$subject,
    [string]$emailfrom,
    [string]$mailattachment)
    $ErrorActionPreference = "silentlycontinue"
    $sender = $emailfrom
    $recipient = $emailto
    $mailserver = $mailserver
    $subject = $subject
    $body = $emailbody
    $msg = new-object System.Net.Mail.MailMessage $sender, $recipient, $subject, $body
    $attachment = new-object System.Net.Mail.Attachment $mailattachment
    $msg.CC.Add($CC)
    # Uncomment to send BCC
    # $msg.BCC.Add($BCC)
    $msg.Attachments.Add($attachment)
    $client = new-object System.Net.Mail.SmtpClient $mailserver
    #$client.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
    $client.Send($msg)
    $attachment.Dispose()
}
