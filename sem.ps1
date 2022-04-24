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

Write-Host "Kontrola neoprávněných přístupů"

#Tenhle kód vypíše všechny přihlášení a odhlášení z počítače za posledních 7 dní, nutné pustit jako administrátor, protože sahá do security logu
$logs = get-eventlog system -ComputerName $env:COMPUTERNAME -source Microsoft-Windows-Winlogon -After (Get-Date).AddDays(-7);
$res = @();ForEach ($log in $logs) {
    if($log.instanceid -eq 7001) {
        $type = "Logon"
    } Elseif ($log.instanceid -eq 7002){
    $type="Logoff"
    } Else {
    Continue
    }

    $res += New-Object PSObject -Property
    @{Time = $log.TimeWritten;
    "Event" = $type;
    User = (New-Object System.Security.Principal.SecurityIdentifier $Log.ReplacementStrings[1]).Translate([System.Security.Principal.NTAccount])
    }
};

$res

 #Vypíše posledních 10 záznamů z logu security pro přihalšovací akce
 #Nutné předtím pustit script failedLogon.ps1 pro nasimulování neoprávněných vstupů
$securityEvents = Get-WinEvent -FilterHashtable @{LogName='Security';ID=4625} -MaxEvents 10

Write-Output $securityEvents
#zapsání security logu do souboru 
$date = (get-date).adddays(-1)
get-eventlog security |
where {$_.timewritten -gt $date} |
out-file c:\security.txt

Write-host "Log uložen do souboru security.txt"
Write-host "Kontrola neoprávněných přístupů dokončena"

