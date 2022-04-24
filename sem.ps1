﻿<#
.SYNOPSIS
Compare input file and actual info PC. Check the log on and log of on actual computer and save security log into security.txt file.
.DESCRIPTION
Compare CSV file with actual PC info. This info get from Get-ComputerInfo and systeminfo.
Check log on and log off on current computer for last 7 days and write it to the output. Saves the  last 24 hour security log into the file.
.PARAMETER Path
Path to CSV file
.EXAMPLE
.\semOS2\sem.ps1 .\semOS2\sourceData.csv
.NOTES
Created by JN & DŠ
#>
$pathFile = $args[0]
$csvImported = Import-Csv $pathFile -Delimiter ";"
$Logfile = ".\log.txt"
$Username = "testnnpda";
$Password = "Nnpda123";

function Write-Log{
Param ([string]$LogString)
    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $LogMessage = "$Stamp $LogString"
    Add-content $LogFile -value $LogMessage
}

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


Write-Host "ziskavani informaci z PC"
$infoActualPCCMPInfo = Get-ComputerInfo
Write-Host "ziskavani podrobnejsich informaci z PC"
$infoActualPCSystenInfo = systeminfo

[bool] $itsOK = $false

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



if($itsOK){
    Write-Host "pocitac" $infoActualPCCMPInfo.CsDNSHostName "byl nalezen a je v poradku"
    Write-Log "Vse v poradku"
}else{
    Write-Host "pocitac" $infoActualPCCMPInfo.CsDNSHostName "nebyl nalezen a nebo neni v poradku"
    Write-Log "Byl nalezen problem"
    Send-ToEmail  -email "testnnpda@gmail.com" -problemLog "Byl nalezen problem s PC";
}

Write-Host "Kontrola neoprávněných přístupů"

$logs = get-eventlog system -ComputerName $env:COMPUTERNAME -source Microsoft-Windows-Winlogon -After (Get-Date).AddDays(-7);
$res = @();ForEach ($log in $logs) {
    if($log.instanceid -eq 7001) {
        $type = "Logon"
    } Elseif ($log.instanceid -eq 7002){
    $type="Logoff"
    } Else {
    Continue
    }

    $res += New-Object PSObject -Property @{Time = $log.TimeWritten;
    "Event" = $type;
    User = (New-Object System.Security.Principal.SecurityIdentifier $Log.ReplacementStrings[1]).Translate([System.Security.Principal.NTAccount])
    }
};

$res

$date = (get-date).adddays(-1)
get-eventlog security |
where {$_.timewritten -gt $date} |
out-file .\security.txt

#poslat email , že byl proveden security check 
Write-host "Log uložen do souboru security.txt"
Write-host "Kontrola neoprávněných přístupů dokončena"

