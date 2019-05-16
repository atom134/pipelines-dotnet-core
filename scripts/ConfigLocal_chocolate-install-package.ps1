# get access system and install package
Set-ExecutionPolicy Bypass -Scope Process -Force
	# Set-ExecutionPolicy Unrestricted -force			#uncomment if have some issues
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# GUI upgrade manager
choco upgrade -y chocolateygui 

# envirments

<#	VM
choco upgrade -y powershell
choco upgrade -y 7zip.install
choco upgrade -y notepadplusplus.install
#>

<#	local computer
# system
choco upgrade -y powershell
choco upgrade -y 7zip.install
choco upgrade -y dotnet4.6.1
choco upgrade -y hwinfo
choco upgrade -y wpd
choco upgrade -y fiddler
choco upgrade -y javaruntime
choco upgrade -y jre8
choco upgrade -y sysinternals
choco upgrade -y curl
choco upgrade -y sql-server-management-studio
choco upgrade -y procexp
choco upgrade -y wireshark

# files
choco upgrade -y totalcommander
choco upgrade -y windirstat

# office
choco upgrade -y notepadplusplus.install
choco upgrade -y vscode

# media
choco upgrade -y winamp
choco upgrade -y k-litecodecpackfull
choco upgrade -y vlc

# storage
choco upgrade -y partitionwizard
choco upgrade -y crystaldiskmark

# browser
choco upgrade -y firefox
choco upgrade -y googlechrome

# chat
choco upgrade -y skype
choco upgrade -y viber

# network
choco upgrade -y putty.install
choco upgrade -y winscp
#>