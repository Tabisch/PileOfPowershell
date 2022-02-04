param(
[parameter(Mandatory=$true)]
[string[]]
$paths
)

Function Replace-Text{
    Param(
    [String]$path
    )

    $files = Get-ChildItem -Path $path -Recurse -Filter "*.xls"

    Write-host "Get-ChildItem completet"

    foreach($file in $files)
    {
        Write-Host "Loading $($file.FullName)"

        $lastwrite = $file.LastWriteTime
     
        $FileContent = Get-Content -Path $file.FullName

        $FileContent = $FileContent.Replace("OldText","NewText")

        Write-Host "Setting Content for $($file.FullName)"

        $FileContent | Set-Content -Path $file.FullName

        $file.LastWriteTime = $lastwrite
    }
}

foreach($path in $paths)
{
    Write-host $path
    Replace-Text -Pfad $path
}
