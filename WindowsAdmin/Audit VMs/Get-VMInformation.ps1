Import-Module "C:\Program Files\Microsoft System Center 2012\Virtual Machine Manager\bin\psModules\virtualmachinemanager\virtualmachinemanager.psd1"

$CLUSTERNAME = Get-VMHostCluster -Name "CLUSTERNAME"
$EF01HOSTS = Get-VMHost -VMHostCluster $CLUSTERNAME
$EF01 = $EF01HOSTS | %{Get-VM -VMHost $_}
Set-Content C:\Temp\VirtualMachines.csv "Name,Status,MemoryType,MaximumMemory,MiniumMemory,CurrentMemory,VirtualProcessors,TotalHDDSpace"

$EF01 | %{
    $Name = $_.ComputerNameString
    $Status = $_.Status
    $Dynamic = $_.DynamicMemoryEnabled
    if ($Dynamic -eq "True")
    {
        $MemoryType = "Dynamic"
        $MaxMem = $_.DynamicMemoryMaximumMB
        $MinMem = $_.DynamicMemoryMinimumMB
        $CurrMem = $_.MemoryAssignedMB
    }
    else
    {
        $MemoryType = "Static"
        $MaxMem = $_.MemoryAssignedMB
        $MinMem = $_.MemoryAssignedMB
        $CurrMem = $_.MemoryAssignedMB
    }

    $CPUs = $_.CPUCount
    $VHDs = Get-SCVirtualHardDisk -VM $_
    $TotalSize = 0
    Foreach ($VHD in $VHDs)
    {
        $TotalSize += [math]::Round(($VHD.MaximumSize / 1024 / 1024), [midpointrounding]::AwayFromZero)
    }

    Add-Content C:\temp\VirtualMachines.csv "$Name,$Status,$MemoryType,$MaxMem,$MinMem,$CurrMem,$CPUs,$TotalSize"
}