# tf-lock-fun

A project to experiment with Terraform state locking mechanisms and highlight potential issues and solutions.

## Challenge

There is a case where we can experience an error related to Terraform state locking when the private registry is updated between a plan and apply in a Workspace Run.

![](images/error.png)

### Prerequisites

We can use the [taskfile](https://taskfile.dev/) in this repo and [tfx](https://tfx.rocks/) to reproduce the issue.

### Reproduce

The following steps can be followed to reproduce the issue:

- Upload Public GPG Key to the Registry.
  - `task pr:upload-gpg-key`
- Create a Provider in the Registry, name: "random".
  - `task pr:create`
- Create a Version of the "random" provider, version: "3.7.2", with a SHA256SUMS file that includes platforms for Linux/Darwin & amd64/arm64 platforms.
  - `task pr:create:select`
- Upload Provider Version Platforms of Linux/amd64 and Darwin/amd64.
  - `task pr:binaries`
- Create a new Workspace with the Terraform in the `workspace/` folder.
- Run `terraform apply` in the Workspace, let the plan finish, but do not apply yet.
- Delete the "random" Provider Version "3.7.2" from the Registry.
  - `task pr:delete`
- Create a Version of the "random" provider, version: "3.7.2", with a SHA256SUMS file that includes all platforms.
  - `task pr:create:all`
- Upload Provider Version Platforms of Linux/amd64 and Darwin/amd64.
  - `task pr:binaries`
- Go back to the Workspace and apply the plan. You should see the error related to "
Error: Inconsistent dependency lock file".

View the taskfile for more details on the commands.

### Logs

```
terraform apply
Running apply in HCP Terraform. Output will stream here. Pressing Ctrl-C
will cancel the remote apply if it's still pending. If the apply started it
will stop streaming the logs, but will not stop the apply running remotely.

Preparing the remote apply...

To view this run in a browser, visit:
https://app.terraform.io/app/terraform-tom/lock-file-test/runs/run-E9m4rKUF1QacJaFa

Waiting for the plan to start...

Terraform v1.14.1
on linux_amd64
Initializing plugins and modules...

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the
following symbols:
  + create

Terraform will perform the following actions:

  # random_pet.name will be created
  + resource "random_pet" "name" {
      + id        = (known after apply)
      + length    = 2
      + prefix    = (known after apply)
      + separator = "-"
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + name = (known after apply)

Do you want to perform these actions in workspace "lock-file-test"?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

╷
│ Error: Inconsistent dependency lock file
│ 
│ The given plan file was created with a different set of external dependency
│ selections than the current configuration. A saved plan can be applied only
│ to the same configuration it was created from.
│ 
│ Create a new plan from the updated configuration.
╵
Operation failed: failed running terraform apply (exit 1)
```