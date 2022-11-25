Param(
[String]
$Path
)

return @(.\Get-FileLocks.ps1 -Paths (Get-ChildItem -Path $Path -Recurse).FullName | Sort-Object -Property * -Unique)