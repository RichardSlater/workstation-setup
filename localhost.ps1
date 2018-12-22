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
  "vagrant"
  "packer"
  "terraform"
  "gcloudsdk"
  "poshgit"
  "firacode"
)

$gpgBinRoot = "C:\Program Files\Git\usr\bin\"
$gbgBinExecutablesToRemove = @(
  "gpg.exe"
  "ssh.exe"
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

    foreach ($File in $gbgBinExecutablesToRemove) {
      File "Remove$File"
      {
          Ensure = "Absent"
          DestinationPath = "$gpgBinRoot\$File"
      }
    }
  }
}

WorkstationConfig

Start-DscConfiguration .\WorkstationConfig -wait -Verbose -force
