Write-host "Simulování nepovolených přístupů"
 $arrUsers = @(
     "AtaBlogUser1"
     "AtaBlogUser2"
     "AtaBlogUser3"
     "AtaBlogUser4"
     "AtaBlogUser5"
 )

 $arrUsers | ForEach-Object {
     $securePassword = ConvertTo-SecureString "AtA810GRu13Z%%" -AsPlainText -Force 
     $storedCredential = New-Object System.Management.Automation.PSCredential($_, $securePassword)
     Start-Process -FilePath PowerShell -Credential $storedCredential
 }

 $i = 0
 Do {
     $securePassword = ConvertTo-SecureString "AtA810GRu13Z%%" -AsPlainText -Force 
     $storedCredential = New-Object System.Management.Automation.PSCredential("AtaBlogUser", $securePassword)
     Start-Process -FilePath PowerShell -Credential $storedCredential
     $i++
 } Until ($i -eq 30)
