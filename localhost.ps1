#Requires -RunAsAdministrator

$VerbosePreference = "SilentlyContinue"

# Avoid WSMan Firewall Rule warnings 
Set-NetConnectionProfile -InterfaceAlias vEthernet* -NetworkCategory Private

# Avoid The WS-Management service cannot process the request. The computed response
# packet size (1769346) exceeds the maximum envelope size that is allowed
Set-WSManInstance -ValueSet @{MaxEnvelopeSizekb = "4096"} -ResourceURI winrm/config

$PackagesToInstall = @(
  "dropbox"
  "googlechrome"
  "vscode"
  "jq"
  "7zip"
  "sysinternals"
  "ruby"
  "nodejs.install"
  "python2"
  "golang"
  "gpg4win"
  "inkscape"
  "azure-cli"
  "charles4"
  "linqpad"
  "packer"
  "terraform"
  "gcloudsdk"
  "poshgit"
  "firacode"
  "keepass"
  "keepass-yet-another-favicon-downloader"
  "keepass-plugin-qrcodegen"
  "audacity"
  "audacity-lame"
  "audacity-ffmpeg"
  "openshot"
  "blender"
  "utorrent"
  "grammarly"
  "franz"
  "zoom"
  "evernote"
  "slack"
  "docker-desktop"
  "jdk8"
  "stardock-fences"
  "androidstudio"
)

$gpgBinRoot = "C:\Program Files\Git\usr\bin\"
$gbgBinExecutablesToRemove = @(
  "gpg.exe"
  "ssh.exe"
)

$publicDesktopShortcuts = Get-ChildItem C:\Users\Public\Desktop -Filter *.lnk
$personalDesktopShortcuts = Get-ChildItem ([System.Environment]::GetFolderPath('Desktop')) -Filter *.lnk

$vsCodeSettings = Join-Path $PSScriptRoot "vscode/settings.json"
$conEmuSettings = Join-Path $PSScriptRoot "profile/ConEmu.xml"

Configuration WorkstationConfig
{
  Import-DscResource -ModuleName PSDesiredStateConfiguration
  Import-DscResource -Module xComputerManagement
  Import-DscResource -Module cChoco
  Import-DscResource -ModuleName GraniResource
  Import-DscResource -ModuleName DSCR_AppxPackage

  Node "localhost" {
    LocalConfigurationManager {
      DebugMode = 'ForceModuleImport'
    }

    xComputer NewNameAndWorkgroup 
    { 
      Name          = "AML0184"
      WorkGroupName = "AMIDO" 
    } 

    cChocoInstaller installChoco {
      InstallDir = "c:\choco"
    }

    foreach ($Package in $PackagesToInstall) {
      cChocoPackageInstaller "install$Package"
      {
         Ensure = 'Present'
         Name = $Package
         AutoUpgrade = $True
         DependsOn = '[cChocoInstaller]installChoco'
      }
    }

    foreach ($File in $gbgBinExecutablesToRemove) {
      File "Remove$File"
      {
          Ensure = 'Absent'
          DestinationPath = "$gpgBinRoot\$File"
      }
    }

    cAppxPackageSet AllUsersPackages {
      Ensure = 'Absent'
      Name = "king.com.CandyCrushSaga", "king.com.CandyCrushFriends"
    }

    # only works for admin user
    Registry ShowFileExtensions {
      Ensure = "Present"
      Key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
      ValueName = "HideFileExt"
      ValueData = "0"
      ValueType = "Dword"
    }

    if ($publicDesktopShortcuts) {
      foreach ($File in $publicDesktopShortcuts.FullName) {
        File "Remove$File"
        {
            Ensure = 'Absent'
            DestinationPath = "$File"
        }
      }
    }

    if ($personalDesktopShortcuts) {
      foreach ($File in $personalDesktopShortcuts.FullName) {
        File "Remove$File"
        {
          Ensure = 'Absent'
          DestinationPath = "$File"
        }
      }
    }

    File SourceDirectory {
      Type = 'Directory'
      DestinationPath = 'C:\source'
      Ensure = "Present"
    }

    File AmidoSourceDirectory {
      Type = 'Directory'
      DestinationPath = 'C:\source\amido'
      Ensure = "Present"
    }

    File PersonalSourceDirectory {
      Type = 'Directory'
      DestinationPath = 'C:\source\richardslater'
      Ensure = "Present"
    }

    Service SSHAgent
    {
      Name        = "ssh-agent"
      StartupType = "Automatic"
      State       = "Running"
    }

    # we skip this if we are running off removable media
    if ($vsCodeSettings.ToLowerInvariant().StartsWith("c:")) {
      $appData = [System.Environment]::GetFolderPath('ApplicationData')
      $vsCodeSettingsTarget = Join-Path $appData "Code\User\settings.json"
      File RemoveUncontrolledVSCodeSettings
      {
          Ensure = 'Absent'
          DestinationPath = $vsCodeSettingsTarget
      }
      cSymbolicLink VSCodeSettings
      {
          DestinationPath = $vsCodeSettingsTarget
          SourcePath = $vsCodeSettings
          Ensure = "Present"
      }
    }

    $sshDirectory = Join-Path $env:USERPROFILE '.ssh\'
    $dropBoxSSHFolder = Join-Path $env:USERPROFILE 'Dropbox (Personal)\SSH\'

    File RemoveUncontrolledSSHDirectory
    {
        Ensure = 'Absent'
        DestinationPath = $sshDirectory
    }

    cSymbolicLink SSHFolder
    {
        DestinationPath = $sshDirectory
        SourcePath = $dropBoxSSHFolder
        Ensure = "Present"
    }

    if ($conEmuSettings.ToLowerInvariant().StartsWith("c:")) {
      $appData = [System.Environment]::GetFolderPath('ApplicationData')
      $conEmuSettingsTarget = Join-Path $appData "ConEmu.xml"
      File RemoveUncontrolledConEmuSettings
      {
          Ensure = 'Absent'
          DestinationPath = $conEmuSettingsTarget
      }
      cSymbolicLink ConEmuSettings
      {
          DestinationPath = $conEmuSettingsTarget
          SourcePath = $conEmuSettings
          Ensure = "Present"
      }
    }
  }
}

WorkstationConfig

Start-DscConfiguration .\WorkstationConfig -wait -Verbose -force
