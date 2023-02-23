param(
$Port,
$ProcessId
)

if(!$ProcessId -and !$Port)
{
    Write-Host "No Port or ProcessId given"
}

if($ProcessId -and $Port)
{
    Write-Host "Port and ProcessId are mutually exlusive"
}

if($Port)
{
    $ProcessId = (Get-NetTCPConnection -LocalPort $Port).OwningProcess
}

(Get-CimInstance WIN32_SERVICE | Where-Object{ $_.ProcessId -eq $ProcessId }).DisplayName