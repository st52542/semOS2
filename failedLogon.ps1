#Define 5 usernames to record as logon failures.
 $arrUsers = @(
     "AtaBlogUser1"
     "AtaBlogUser2"
     "AtaBlogUser3"
     "AtaBlogUser4"
     "AtaBlogUser5"
 )
 #Loop through usernames using ForEach-Object to generate a logon failure for each one.
 $arrUsers | ForEach-Object {
     $securePassword = ConvertTo-SecureString "AtA810GRu13Z%%" -AsPlainText -Force 
     $storedCredential = New-Object System.Management.Automation.PSCredential($_, $securePassword)
     Start-Process -FilePath PowerShell -Credential $storedCredential
 }
 #Generate 30 logon failures for user AtaBlogUser.
 $i = 0
 Do {
     $securePassword = ConvertTo-SecureString "AtA810GRu13Z%%" -AsPlainText -Force 
     $storedCredential = New-Object System.Management.Automation.PSCredential("AtaBlogUser", $securePassword)
     Start-Process -FilePath PowerShell -Credential $storedCredential
     $i++
 } Until ($i -eq 30)