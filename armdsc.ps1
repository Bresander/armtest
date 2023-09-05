$ComputerName = "$env:Computername" 
$Password = "Katteniskogen123" 
$DomainName = "V32.se"
###Encrypt Passwords###  
$Cred = ConvertTo-SecureString -String $Password -Force -AsPlainText  
$DomainCreds = New-Object System.Management.Automation.PSCredential ("$(($DomainName -split '\.')[0])\Administrator", $Cred)  
$DSRMpassword = New-Object System.Management.Automation.PSCredential ('No UserName', $Cred)    
Install-Module -name xActiveDirectory
Install-Module -name PsdesiredStateConfiguration
Install-Module -name xNetworking

configuration CreateADPDC{




Import-DscResource -ModuleName xActiveDirectory,xNetworking,PSDesiredStateConfiguration
$Interface=Get-NetAdapter|Where Name -Like "Ethernet*"|Select-Object -First 1
$InterfaceAlias=$($Interface.Name)

Node localhost
{
    LocalConfigurationManager
    {
        RebootNodeIfNeeded = $true
    }

    WindowsFeature DNS
    {
        Ensure = "Present"
        Name = "DNS"
    }

    Script EnableDNSDiags
    {
  	    SetScript = {
            Set-DnsServerDiagnostics -All $true
            Write-Verbose -Verbose "Enabling DNS client diagnostics"
        }
        GetScript =  { @{} }
        TestScript = { $false }
        DependsOn = "[WindowsFeature]DNS"
    }

    WindowsFeature DnsTools
    {
        Ensure = "Present"
        Name = "RSAT-DNS-Server"
        DependsOn = "[WindowsFeature]DNS"
    }

    xDnsServerAddress DnsServerAddress
    {
        Address        = '127.0.0.1'
        InterfaceAlias = $InterfaceAlias
        AddressFamily  = 'IPv4'
        DependsOn = "[WindowsFeature]DNS"
    }


    WindowsFeature ADDSInstall
    {
        Ensure = "Present"
        Name = "AD-Domain-Services"
        DependsOn="[WindowsFeature]DNS"
    }

    WindowsFeature ADDSTools
    {
        Ensure = "Present"
        Name = "RSAT-ADDS-Tools"
        DependsOn = "[WindowsFeature]ADDSInstall"
    }

    WindowsFeature ADAdminCenter
    {
        Ensure = "Present"
        Name = "RSAT-AD-AdminCenter"
        DependsOn = "[WindowsFeature]ADDSTools"
    }

    xADDomain FirstDS
    {
        DomainName = $DomainName
        DomainAdministratorCredential = $DomainCreds
        SafemodeAdministratorPassword = $DomainCreds
        DatabasePath = "C:\NTDS"
        LogPath = "C:\NTDS"
        SysvolPath = "C:\SYSVOL"
        DependsOn = @("[WindowsFeature]ADDSInstall")#"[xDisk]ADDataDisk"
    }

   
}
}




$AllowPlainText = @{
    AllNodes = @(
        @{
            NodeName                    = 'localhost'
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser = $true 

        }
    )
}      
CreateADPDC -ConfigurationData $AllowPlainText -OutputPath C:\conf\ADDS_Conf -verbose