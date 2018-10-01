Install-Module -Name cChoco

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
)

Configuration WorkstationConfig
{
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
  }
}

WorkstationConfig

Start-DscConfiguration .\WorkstationConfig -wait -Verbose -force
