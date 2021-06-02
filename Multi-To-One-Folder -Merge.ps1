param(
    [parameter(Mandatory=$true)]
    [String[]]
    $Quellen,
    [String]
    [parameter(Mandatory=$true)]
    $Ziel,
    [String[]]
    $IncludeFilter,
    [String[]]
    $ExcludeFilter,
    [String]
    $IndividualprogrammePrefix = $null,
    [String]
    $IndividualprogrammeSuffix = $null
)

if(!$IncludeFilter)
{
    $IncludeFilter = "*.*"
}

$zielemail = "Suedlohn.HOTFOLDER.Maschinenprogramme@bauer-suedlohn.com"
$mailserver = "outlook.bauer-gmbh.org"

$global:maximumthreadnumber = 8

$global:INDIVIDUALPROGRAMMEOrdnernamePattern = "*_INDIVIDUALPROGRAMME"

$global:fehlerzustand = $false
$global:logliste = @()
$logpfad = "C:\_Skripte\Maschinenprogramme_in_HOT-Folder_Log\"

$Kopierjobname = ($Ziel.Split('\'))[($Ziel.Split('\')).Length - 1] + " " + (Get-Date -Format "yyyy.MM.dd HH.mm.ss") + ".log"

function Copy
{
    param
    (
       [parameter(Mandatory=$true)]
       [String[]]
       $Quellen,
       [String]
       [parameter(Mandatory=$true)]
       $Ziel,
       [String[]]
       $IncludeFilter,
       [String[]]
       $ExcludeFilter
    )

    foreach($Quelle in $Quellen)
    {
        $ArgumentList = "`"$($Quelle)`"", "`"$($Ziel)`"" ,"/xo" ,"/xx","/s" ,"/z" ,"/log+:`"$($logpfad)$($Kopierjobname)`""

        foreach($Include in $IncludeFilter)
        {
            $ArgumentList += " $($Include)"
        }

        if($ExcludeFilter)
        {
            foreach($Exclude in $ExcludeFilter)
            {
               $ArgumentList += " /xf $($Exclude)"
            }
        }

        $process = Start-Process "robocopy.exe" -ArgumentList $ArgumentList -NoNewWindow -PassThru -Wait
        $process.WaitForExit()

        if($process.ExitCode -ge 8)
        {
            $global:fehlerzustand = $true
            $global:logliste += "$($logpfad)$($Kopierjobname)"
        }
    }
 
    if($global:fehlerzustand -eq $false)
    {
        Remove-Item "$($logpfad)$($Kopierjobname)"
    }
}

function Delete
{
    param
    (
       [parameter(Mandatory=$true)]
       [String]
       $Ziel,
       [parameter(Mandatory=$true)]
       [String[]]
       $Quellen,
       [String[]]
       $IncludeFilter,
       [String[]]
       $ExcludeFilter
    )

    $Error.Clear()

    $Zieldateien = Get-ChildItem -Path $Ziel -Recurse

    $Quelldateien = @()

    foreach($Quelle in $Quellen)
    {
        $Quelldateien += @(Get-ChildItem -Path $Quelle -Recurse)
    }

    if($Error)
    {
        Write-Host $Error
        return
    }

    foreach($Compare in (Compare-Object -ReferenceObject $Zieldateien -DifferenceObject $Quelldateien -Property Name -PassThru))
    {
        if($Compare.SideIndicator -eq "<=")
        {
            Write-Host "Entferne $($Compare.FullName)"
            Remove-Item $Compare.FullName -Confirm:$false -Recurse
        }
    }
}

function Rename-Individualfiles
{
    param(
    [parameter(Mandatory=$true)]
    [String[]]
    $Quellen,
    [String]
    $Prefix,
    [String]
    $Suffix
)
	foreach($Pfad in $Quellen)
    {
        if($Pfad -notlike "$($INDIVIDUALPROGRAMMEOrdnernamePattern)")
        {
            Write-Host "Überspringe $($Pfad)"
            continue
        }

        foreach($i in Get-ChildItem -Path "$($Pfad)\*" -Recurse)
        {
            if($Prefix)
            {
                if($i -is [System.IO.FileInfo] -and $i.BaseName -notlike "$($Prefix)*")
                {
                    Write-Host "Bennene um $($i.FullName) -> $($Prefix)$($i.BaseName)$($i.Extension)"
                    Rename-Item -Path $i.FullName -NewName "$($Prefix)$($i.BaseName)$($i.Extension)"
                }
            }
            
            if($Suffix)
            {
                if($i -is [System.IO.FileInfo] -and $i.BaseName -notlike "*$($Suffix)")
                {
                    Write-Host "Bennene um $($i.FullName) -> $($i.BaseName)$($Suffix)$($i.Extension)"
                    Rename-Item -Path $i.FullName -NewName "$($i.BaseName)$($Suffix)$($i.Extension)"
                }
            }
        }
    }
}

function Sync
{
    param
    (
       [parameter(Mandatory=$true)]
       [String]
       $Ziel,
       [parameter(Mandatory=$true)]
       [String[]]
       $Quellen,
       [String[]]
       $IncludeFilter,
       [String[]]
       $ExcludeFilter
    )

    Copy -Quellen $Quellen -Ziel $Ziel -IncludeFilter $IncludeFilter -ExcludeFilter $ExcludeFilter

    Delete -Quellen $Quellen -Ziel $Ziel -IncludeFilter $IncludeFilter -ExcludeFilter $ExcludeFilter
}

if(!(Test-Path -Path $logpfad))
{
    New-Item -Path $logpfad -ItemType "directory"
}

Rename-Individualfiles -Quellen $Quellen -Prefix $IndividualprogrammePrefix -Suffix $IndividualprogrammeSuffix

Sync -Quellen $Quellen -Ziel $Ziel -IncludeFilter $IncludeFilter -ExcludeFilter $ExcludeFilter

if($global:fehlerzustand  -eq $true)
{
    $global:logliste = $global:logliste | Select-Object -Unique
    Send-MailMessage -To $zielemail -From $zielemail -SmtpServer $mailserver -Subject "Fehler beim Copy nach $($Kopierjobname)" -UseSsl -Attachments $global:logliste
}