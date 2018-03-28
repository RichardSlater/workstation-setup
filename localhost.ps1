Install-Module -Name cChoco

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
    cChocoPackageInstallerSet cliPackages {
      Ensure = 'Present'
      Name = @(
        "jq"
        "7zip"
        "sysinternals"
        "docker"
        "ruby"
        "nodejs.install"
      )
      DependsOn = "[cChocoInstaller]installChoco"
    }
  }
}

WorkstationConfig

Start-DscConfiguration .\WorkstationConfig -wait -Verbose -force
