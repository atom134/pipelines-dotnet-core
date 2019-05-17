<#
.SYNOPSIS
Check of existed certificate on App (IIS), if not present - create new Self Signed SSL Certificate
#>

###############################################################
# create new cert
###############################################################
    # method 1
$cert = New-SelfSignedCertificate -certstorelocation cert:\localmachine\my -dnsname testcert.petri.com
$paswd = ConvertTo-SecureString -String ‘passw0rd!’ -Force -AsPlainText
$path = 'cert:\localMachine\my\' + $cert.thumbprint Export-PfxCertificate -cert $path -FilePath c:\temp\cert.pfx -Password $paswd
    # create new cert (method 2)
New-SelfSignedCertificate -DnsName "10.6.218.193", "ecsc00a04d1c.epam.com" -CertStoreLocation "cert:\LocalMachine\My"


###############################################################
# test trusted level to crated cert
###############################################################
# trust check - method 1
    # https://blogs.technet.microsoft.com/scotts-it-blog/2014/12/30/working-with-certificates-in-powershell/
Get-ChildItem cert:\LocalMachine\CA | Where-Object subject -eq 'CN=Root Agency'
# trust check - method 2
    # https://docs.microsoft.com/en-us/powershell/module/pkiclient/test-certificate?view=win10-ps
Get-ChildItem -Path Cert:\localMachine\My | Test-Certificate -Policy SSL -DNSName "dns=ecsc00a04d1c.epam.com"


###############################################################
# search
###############################################################
    # view all cert
Get-ChildItem -Path Cert: -Recurse
    # view only local
Get-ChildItem -Path Cert:\localMachine\My -Recurse
    # view filter by thumbprint
Get-ChildItem -Path Cert:\LocalMachine\TrustedPublisher | Where-Object {$_.Thumbprint -eq "880072B24604182824C19E088B4C269DE3885CE0"}