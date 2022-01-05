Param(
$Path
)

#Removes all folders not containing files
#Loops until every Folder Contains atleast one file

while($true)
{
    $emptyFolders = Get-ChildItem -Path $Path -Directory -Recurse | Where-Object{$_.PSIsContainer -eq $True} | Where-Object{$_.GetFileSystemInfos().Count -eq 0}

    if($emptyFolders.Length -eq 0)
    {
        Write-Host "Removed all empty Folders"
        break
    }

    $emptyFolders  | Remove-Item
}
