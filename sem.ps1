﻿<#
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
# cesta k logovacimu file
$Logfile = ".\log.txt"
# prihlasovaci udaje k mailu
$Username = "testnnpda";
# sem zadej heslo co mas na fb ... kvuli nechtene pristupu
$Password = "*******";
# info z Get-ComputerInfo
Write-Host "ziskavani informaci z PC"
$infoActualPCCMPInfo = Get-ComputerInfo
Write-Host "ziskavani podrobnejsich informaci z PC"
$infoActualPCSystenInfo = systeminfo
[bool] $itsOK = $false
# -eq porovnava stringy
# porovnani importovanych dat
Write-Host "zacina kontrola zadanych informaci"
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
# logovani v local PC
function Write-Log
{
Param ([string]$LogString)
    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $LogMessage = "$Stamp $LogString"
    Add-content $LogFile -value $LogMessage
}
# odeslani mailu
function Send-ToEmail([string]$email, [string]$problemLog){

    $message = new-object Net.Mail.MailMessage;
    $message.From = "testnnpda@gmail.com";
    $message.To.Add($email);
    $message.Subject = "Hlaseni o chybe";
    $message.Body = $problemLog + $infoActualPCCMPInfo.CsDNSHostName

    $smtp = new-object Net.Mail.SmtpClient("smtp.gmail.com", "587");
    $smtp.EnableSSL = $true;
    $smtp.Credentials = New-Object System.Net.NetworkCredential($Username, $Password);
    $smtp.send($message);
    write-host "Byl odeslan email";
 }

if($itsOK){
    Write-Host "pocitac" $infoActualPCCMPInfo.CsDNSHostName "byl nalezen a je v poradku"
    Write-Log "Vse v poradku"
}else{
    Write-Host "pocitac" $infoActualPCCMPInfo.CsDNSHostName "nebyl nalezen a nebo neni v poradku"
    Write-Log "Byl nalezen problem"
    Send-ToEmail  -email "testnnpda@gmail.com" -problemLog "Byl nalezen problem s PC";
}



