param(
$ProcessId
)

if(!$ProcessId)
{
    $ProcessId  = Read-Host "PID"
}

Get-CimInstance WIN32_SERVICE | Where-Object{ $_.ProcessId -eq $pid } | fl *