$fileLocks = @()

$count = 0

$Error.Clear()

while($true)
{
    $count++

    Write-Host "Run:" $count

    $fileLocks += @(.\Get-FileLocksDirectory.ps1 -Path "D:\")

    $fileLocks += @($fileLocks | Sort-Object -Property * -Unique)

    if($Error)
    {
        Write-Host $Error
        break
    }

    $fileLocks | ConvertTo-Csv | Out-File fileLocks.txt
}