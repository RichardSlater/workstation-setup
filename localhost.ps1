$VerbosePreference = "SilentlyContinue"
Install-Module -Name cChoco -Force

# Avoid The WS-Management service cannot process the request. The computed response
# packet size (1769346) exceeds the maximum envelope size that is allowed
Set-WSManInstance -ValueSet @{MaxEnvelopeSizekb = "2048"} -ResourceURI winrm/config

$PackagesToInstall = @(
  "jq"
  "7zip"
  "sysinternals"
  "docker"
  "ruby"
  "nodejs.install"
  "python2"
  "golang"
  "gpg4win"
  "keybase"
  "inkscape"
  "paint.net"
  "virtualbox"
  "azure-cli"
  "charles4"
  "linqpad"
  "beyondcompare"
  "balsamiqmockups3"
  "kubernetes-cli"
  "minikube"
  "kubernetes-helm"
  "vagrant"
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
)

$gpgBinRoot = "C:\Program Files\Git\usr\bin\"
$gbgBinExecutablesToRemove = @(
  "gpg.exe"
  "ssh.exe"
)

Configuration WorkstationConfig
{
  Import-DscResource -ModuleName PSDesiredStateConfiguration
  Import-DscResource -Module cChoco
  Node "localhost" {
    LocalConfigurationManager {
        DebugMode = 'ForceModuleImport'
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
  }
}

WorkstationConfig

Start-DscConfiguration .\WorkstationConfig -wait -Verbose -force
