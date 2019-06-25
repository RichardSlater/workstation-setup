# Ansible Role Terraform

Installs terraform from https://www.terraform.io/downloads.html

## Requirements

On MacOS brew must be installed.

## Internal variables

Name                   | Comment
---                    | ---
terraform_version      | The version that should be installed
terraform_install_dir  | Installation directory
terraform_download_url | URL to the terraform zip file
terraform_dep_packages | Dependency packages

## Dependencies

There are no role dependencies.

## Example Usage

For MacOS
```yaml
- hosts: terra_hosts
  vars:
    terraform_version: "0.9.6"

  roles:
    - terraform
```

For Linux
```yaml
- hosts: terra_hosts
  become: true
  vars:
    terraform_version: "0.9.6"

  roles:
    - terraform
```
