#Requires -RunAsAdministrator

Param(
$Pcname
)

function Get-Info
{
    Get-ComputerInfo | Select-Object CsName,CsManufacturer,CsModel,CsProcessors,@{Name = "RAM (GB)"; Expression = {([Math]::Round(($_.CsTotalPhysicalMemory / 1024 / 1024 / 1024),0))}},WindowsInstallDateFromRegistry,OsUptime | fl
    
    Get-CimInstance win32_physicalmemory | Format-Table Manufacturer,Banklabel,Configuredclockspeed,Devicelocator,Capacity,Serialnumber -autosize
    Get-Volume | ft -autosize
    Get-PhysicalDisk | ft -autosize
}

if($Pcname)
{
    Invoke-Command -ScriptBlock ${function:Get-Info} -ComputerName $Pcname
}
else
{
    Get-Info
}