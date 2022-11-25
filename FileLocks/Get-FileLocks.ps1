Param(
[String[]]
$Paths
)

$validPaths = @()

$validPaths += $Paths | ForEach-Object{

    IF((Test-Path -Path $_)) {
          return $_
    }

}

$lockedFilesRaw = openfiles /query /fo csv
$lockedFilesRaw[3] = '"ProcessId","ProcessName","Path"'
$lockedFiles = $lockedFilesRaw[3..($lockedFilesRaw.count-7)] | ConvertFrom-Csv

$locks = $lockedFiles | Where-Object{ $validPaths -contains $_.Path }

return $locks