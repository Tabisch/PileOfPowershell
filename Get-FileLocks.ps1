Param(
[String[]]
$FileOrFolderPaths
)

$validFiles = @()

$validFiles += $FileOrFolderPaths | ForEach-Object{

    IF((Test-Path -Path $_)) {
          return $_
    }

}

Write-Host "Dateien:"
Write-host $validFiles

$lockedFilesRaw = openfiles /query /fo csv
$lockedFilesRaw[3] = '"ProcessId","ProcessName","Path"'
$lockedFiles = $lockedFilesRaw[3..($lockedFilesRaw.count-7)] | ConvertFrom-Csv

$locks = $lockedFiles | Where-Object{ $validFiles -contains $_.Path }

return $locks