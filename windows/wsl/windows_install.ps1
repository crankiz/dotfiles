# Stup WSL2 

## Enable WSL and VirtualMachinePlatform features
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

## Download and install the Linux kernel update package
$wslUpdateInstallerUrl = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
$downloadFolderPath = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path
$wslUpdateInstallerFilePath = "$downloadFolderPath/wsl_update_x64.msi"
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($wslUpdateInstallerUrl, $wslUpdateInstallerFilePath)
Start-Process -Filepath "$wslUpdateInstallerFilePath"

## Set WSL default version to 2
wsl --set-default-version 2
wsl --install -d Ubuntu

# Setup winget

## Install winget
Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe

## Copy setting
$wingetSettingPath = $env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json
Copy-Item -Path .\winget\settings.json -Destination $wingetSettingPath

# Import winget packages
winget import --import-file .\winget\winget.json --accept-package-agreements --accept-source-agreements --disable-interactivity

# Setup Windows terminal

## Download windows terminal config
$wtSettingPath = "%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\RoamingState\profiles.json"
Copy-Item -Path .\terminal\settings.json -Destination $wtSettingPath

