Clear-Host
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
#User to search for
$USERNAME = "buildagent"
#Declare LocalUser Object
$ObjLocalUser = $null
Try {
    Write-Verbose "Searching for $($USERNAME) in LocalUser DataBase"
    $ObjLocalUser = Get-LocalUser $USERNAME
    Write-Verbose "User $($USERNAME) was found"
    }
Catch [Microsoft.PowerShell.Commands.UserNotFoundException] {
    "User $($USERNAME) was not found" | Write-Warning
    }
Catch {
    "An unspecifed error occured" | Write-Error
    Exit # Stop Powershell!
    }
#Create the user if it was not found (Example)
If (!$ObjLocalUser) {
    Write-Verbose "Creating User $($USERNAME)" #(Example)
    $Password = ConvertTo-SecureString -String "vmPassw0rd!" -AsPlainText -Force
    #$secpasswd = Read-Host -AsSecureString
    #New-ADuser -Name 'johnd' -GivenName'John' -Surname 'Doe' -DisplayName 'John Doe' -AccountPassword $secpasswd
    New-LocalUser "buildagent" -Password $Password -FullName "Azure DevOps Build" -Description "dev.azure.com/ArtemTkachenko" -AccountNeverExpires -PasswordNeverExpires -UserMayNotChangePassword
        Add-LocalGroupMember -Group "Administrators" -Member "buildagent"
        Add-LocalGroupMember -Group "Remote Desktop Users" -Member "buildagent"
        Add-LocalGroupMember -Group "Remote Management Users" -Member "buildagent"
        Add-LocalGroupMember -Group "IIS_IUSRS" -Member "buildagent"
    }