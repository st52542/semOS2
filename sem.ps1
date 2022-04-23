<#
.SYNOPSIS
Compare input file and actual info PC
.DESCRIPTION
Compare CSV file with actual PC info. This info get from Get-ComputerInfo and systeminfo
.PARAMETER Path
Path to CSV file
.EXAMPLE
.\semOS2\sem.ps1 .\semOS2\sourceData.csv
.NOTES
Created by JN & DŠ
#>
# pro vypsani helpu po zadani get-help .\...
# pro argument
$pathFile = $args[0]
# import CSV
# diky excelu jsem vymazal vsechny ciselne hodnoty 
# dale je potreba vyresit co delat pokud v nazvu promenne je () - zatim jsem vypustil
$csvImported = Import-Csv $pathFile -Delimiter ";"
# info z Get-ComputerInfo
$infoActualPCCMPInfo = Get-ComputerInfo
$infoActualPCSystenInfo = systeminfo
[bool] $itsOK = $false
# -eq porovnava stringy
# porovnani importovanych dat
foreach ($info in $csvImported){
    if(($info.WindowsProductName -eq $infoActualPCCMPInfo.WindowsProductName) -and
    ($info.WindowsVersion -eq $infoActualPCCMPInfo.WindowsVersion) -and
    ($info.BiosManufacturer -eq $infoActualPCCMPInfo.BiosManufacturer) -and
    ($info.CsDNSHostName -eq $infoActualPCCMPInfo.CsDNSHostName) -and
    ($info.CsDomain -eq $infoActualPCCMPInfo.CsDomain) -and
    ($info.OsTotalVisibleMemorySize -eq $infoActualPCCMPInfo.OsTotalVisibleMemorySize) -and
    ($info.OsArchitecture -eq $infoActualPCCMPInfo.OsArchitecture)){
        $itsOK = $true
    }
}
if($itsOK){
    Write-Host "pocitac" $infoActualPCCMPInfo.CsDNSHostName "byl nalezen a je v poradku"
}else{
    Write-Host "pocitac" $infoActualPCCMPInfo.CsDNSHostName "nebyl nalezen a nebo neni v poradku"
}