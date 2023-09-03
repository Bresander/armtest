# Promote the server to a domain controller
$DomainName = "bresander.se"
$SafeModeAdministratorPassword = ConvertTo-SecureString -String "YourPassword" -AsPlainText -Force
Install-ADDSForest -DomainName $DomainName -SafeModeAdministratorPassword $SafeModeAdministratorPassword

# Reboot the server
Restart-Computer -Force

# Configuration complete
Write-Host "Active Directory and DNS installation completed. The server will now reboot."
