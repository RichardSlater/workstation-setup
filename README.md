# Workstation Configuration

This Desired State Configuration is designed to configure a single workstation with various development tools I use on a day to day basis.   In it's current form it is just managing a small subset of the software I use however will eventually be used to setup a workstation from scratch.

## Initial Setup

The DSC depends upon the [cChoco][cchoco] package which can be installed as follows:

    Install-Module -Name cChoco

  [cchoco]: https://www.powershellgallery.com/packages/cChoco

Both the above command and the execution of desired state configuration must be executed as an administrator!
