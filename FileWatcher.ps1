Param(
[parameter(Mandatory=$true)]
$MailFrom,
[parameter(Mandatory=$true)]
$MailTo,
$MailServer = "outlook.bauer-gmbh.org",
[parameter(Mandatory=$true)]
$Path,
$HeadLineText = "Neue Dateien in Ordner `"$($Path)`"<br><br>",
$MailSubject = "Es wurden neue Aufträge erstellt"
)

$PreviousFolderStateFile = "$($PSScriptRoot)\$($Path -replace '[^a-zA-Z0-9]', '').txt"

$allFiles = Get-ChildItem -Path $Path
$PreviousFolderState = Get-Content -Path $PreviousFolderStateFile -Encoding UTF8

if($PreviousFolderState -eq $null)
{
    $PreviousFolderState = ""
}

$MailMessageBody = ""

foreach($file in $allFiles)
{
    if(!$PreviousFolderState.Contains($file.FullName))
    {
        $MailMessageBody += "{0}: `"{1}`" <br>" -f $file.Name,$file.FullName
    }
}

if($MailMessageBody -ne "")
{
    $MailMessageBody = $HeadLineText + $MailMessageBody
    Send-MailMessage -From $MailFrom -To $MailTo -Subject $MailSubject -SmtpServer $MailServer -Body $MailMessageBody -BodyAsHtml -Encoding utf8
}

$allFiles.FullName | Out-File -FilePath $PreviousFolderStateFile -Encoding utf8