# Install Active Directory Domain Services
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

# Create a new domain in a new forest


$Params = @{
    DomainName = Mstile.se
    DomainNetbiosName = $Mstile.se.Split('.')[0]
    SafeModeAdministratorPassword = (ConvertTo-SecureString -AsPlainText "Taklaggare90" -Force)
    CreateDnsDelegation = $false
    DatabasePath = 'C:\Windows\NTDS'
    DomainMode = 'WinThreshold'
    ForestMode = 'WinThreshold'
    InstallDns = $true
    LogPath = 'C:\Windows\NTDS'
    NoRebootOnCompletion = $false
    SysvolPath = 'C:\Windows\SYSVOL'
    Force = $true
    }
Install-ADDSForest @Params
