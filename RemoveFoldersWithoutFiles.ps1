Param(
$Path
)

#Removes all folders not containing files

while($true)
{
    $LeereOrdner = Get-ChildItem -Path $Path -Directory -Recurse | Where-Object{$_.PSIsContainer -eq $True} | Where-Object{$_.GetFileSystemInfos().Count -eq 0}

    if($LeereOrdner.Length -eq 0)
    {
        Write-Host Removed all empty Folders
        break
    }

    $LeereOrdner  | Remove-Item
}
