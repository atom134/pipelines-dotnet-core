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

    # method 2
# https://weblog.west-wind.com/posts/2016/Jun/23/Use-Powershell-to-bind-SSL-Certificates-to-an-IIS-Host-Header-Site
$hostname="test.west-wind.com"
$iisSite="Default Web Site"

    # method 3
# https://stackoverflow.com/questions/32390097/powershell-set-ssl-certificate-on-https-binding#
$siteName = 'mywebsite'
$dnsName = 'www.mywebsite.ru'

# create the ssl certificate
$newCert = New-SelfSignedCertificate -DnsName $dnsName -CertStoreLocation cert:\LocalMachine\My

# get the web binding of the site
$binding = Get-WebBinding -Name $siteName -Protocol "https"

# set the ssl certificate
$binding.AddSslCertificate($newCert.GetCertHashString(), "my")

    # method 4
# https://weblog.west-wind.com/posts/2016/Jun/23/Use-Powershell-to-bind-SSL-Certificates-to-an-IIS-Host-Header-Site
$hostname = "test.west-wind.com"
$iisSite = "Default Web Site"
$machine = "LocalMachine"

if ($args[0]) 
{     
    $hostname = $args[0]
}
if($args[1])
{
    $iisSite = $args[1]
}
if ($args[2])
{
    $machine = $args[2]
}
if ($args[3])
{
    $cert = $args[3]
}
"Host Name: " + $hostname
"Site Name: " + $iisSite
"  Machine: " + $machine
if (-not $cert) {
    # Create a certificate
    & "C:\Program Files (x86)\Microsoft SDKs\Windows\v7.1A\Bin\x64\makecert" -r -pe -n "CN=${hostname}" -b 06/01/2016 -e 06/01/2020 -eku 1.3.6.1.5.5.7.3.1 -ss my -sr localMachine  -sky exchange  -sp "Microsoft RSA SChannel Cryptographic Provider" -sy 12

    dir cert:\localmachine\my
    $cert = (Get-ChildItem cert:\LocalMachine\My | where-object { $_.Subject -like "*$hostname*" } | Select-Object -First 1).Thumbprint
    $cert
}
"Cert Hash: " + $cert

# http.sys mapping of ip/hostheader to cert
$guid = [guid]::NewGuid().ToString("B")
netsh http add sslcert hostnameport="${hostname}:443" certhash=$cert certstorename=MY appid="$guid"

# iis site mapping ip/hostheader/port to cert - also maps certificate if it exists
# for the particular ip/port/hostheader combo
New-WebBinding -name $iisSite -Protocol https  -HostHeader $hostname -Port 443 -SslFlags 1

# netsh http delete sslcert hostnameport="${hostname}:443"
# netsh http show sslcert



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


