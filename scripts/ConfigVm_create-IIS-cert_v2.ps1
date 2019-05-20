if ($PSVersionTable.PSVersion.Major -lt 3) {
    Write-Host -Object "##vso[task.logissue type=warning;] Powershell version that is used is 2 or lower, but only versions that grater or equal 3 are supported."
}
else {
    if (!(Get-Module -Name WebAdministration -ListAvailable)) {
        Write-Host -Object "##vso[task.logissue type=warning;] Script requires WebAdministration Powershell module to be installed. Further script execution will be skipped."
        Return
    }
    Import-Module -Name WebAdministration
    
    $app_cert = Get-ChildItem -Path "Cert:\LocalMachine\My" | Where-Object -FilterScript { $_.Subject -eq "CN=$(CertificateSubject)" }
    $port_binding = Get-WebBinding -Port $(HTTPsBindingPort)
    if ($port_binding) {
        $app_port_binding = $port_binding | Where-Object -FilterScript { $_.ItemXPath -match "\@name\=\'$(SiteName)\'" }
        if (!$app_port_binding) {
            Write-Host -Object "##vso[task.logissue type=warning;] Port binding exists on port '$(HTTPsBindingPort)' for site other than '$(SiteName)'. Please, choose free appropriate tcp port that is not used by HTTP\HTTPs binding of any site and run script again. Further script execution will be skipped."
        }
        else {
            $app_https_binding = $app_port_binding | Where-Object -FilterScript { $_.protocol -eq "https" }
            if ($app_https_binding) {
                if ($app_cert) {
                    $app_https_binding_with_cert = $app_https_binding | Where-Object -FilterScript { $_.certificateHash -eq $app_cert.Thumbprint }
                    if ($app_https_binding_with_cert) {
                        Write-Host -Object "##vso[task.logissue type=warning;] HTTPs binding for site '$(SiteName)' on port '$(HTTPsBindingPort)' with certificate with Subject '$(CertificateSubject)' already exists."
                        Return
                    }
                }
                Write-Host -Object "##vso[task.logissue type=warning;] HTTPs binding exists for site '$(SiteName)' on port '$(HTTPsBindingPort)' with certificate with Subject other than '$(CertificateSubject)'. Please, choose free appropriate tcp port that is not used by any site and run script again. Further script execution will be skipped."
            }
            else {
                Write-Host -Object "##vso[task.logissue type=warning;] HTTP binding exists for site '$(SiteName)' on port '$(HTTPsBindingPort)'. Please, choose free appropriate tcp port that is not used by any site and run script again. Further script execution will be skipped."
            }
        }
    }
    else {
        if ($app_cert) {
            New-WebBinding -Name $(SiteName) -Protocol https -Port $(HTTPsBindingPort)
            $app_cert | New-Item -Path (Join-Path -Path 'IIS:\SslBindings' -ChildPath "0.0.0.0!$(HTTPsBindingPort)")
        }
        else {
            $Windows_OS_Version = [System.Environment]::OSVersion.Version
            if ($Windows_OS_Version -gt [version]6.1 -or "$($Windows_OS_Version.Major)`.$($Windows_OS_Version.Minor)" -match "^10\.") {
                $app_cert = New-SelfSignedCertificate -Subject $(CertificateSubject)
                New-WebBinding -Name $(SiteName) -Protocol https -Port $(HTTPsBindingPort)
                $app_cert | New-Item -Path (Join-Path -Path 'IIS:\SslBindings' -ChildPath "0.0.0.0!$(HTTPsBindingPort)")
            }
            else {
                Write-Host -Object "##vso[task.logissue type=warning;] Script does not support generation of self-signed certificate for Windows versions older than Windows Server 2012. Please, use custom function written by Vadims Podans from https://gallery.technet.microsoft.com/scriptcenter/Self-signed-certificate-5920a7c6"
            }
        }
    }
}