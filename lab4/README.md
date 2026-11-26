# Lab 4 - remote state and workspaces

Lab 3 reworked to run its EC2 instances in an Auto Scaling Group, with the state stored in S3 and one workspace per country.

## Layout

```sh
.
|-- terraform.tf        # versions and S3 backend
|-- main.tf             # provider + call to the asg module
|-- variables.tf        # variables (min_size and max_size are required)
|-- outputs.tf          # ASG name and public IPs
|-- fr.tfvars           # france: min 1, max 2
|-- de.tfvars           # germany: min 2, max 3
`-- modules/asg         # datasources, key pair, security group, launch template, ASG
```

## Remote state

| Workspace | Key in the `terraform-state-w9e85` bucket            |
| --------- | ---------------------------------------------------- |
| `default` | `global/s3/student_7/terraform.tfstate`              |
| `france`  | `env:/france/global/s3/student_7/terraform.tfstate`  |
| `germany` | `env:/germany/global/s3/student_7/terraform.tfstate` |

Locking uses the DynamoDB table `terraform-up-and-running-locks`. Recent Terraform versions warn that `dynamodb_table` is deprecated.

## Run

Put your AWS keys in `~/.aws/credentials`. The provider and the S3 backend both read the `default` profile, so there is nothing to pass to Terraform.

```ini
[default]
aws_access_key_id = ...
aws_secret_access_key = ...
```

Generate an SSH key.

```powershell
ssh-keygen -t ed25519 -f ~/.ssh/lab4_key
```

### 1. Migrate the state to S3

Copy the local state of lab 3.5, then initialize. Answer `yes` if Terraform asks to copy the state (it does not ask when the state is empty).

```powershell
cp ../lab3.5/terraform.tfstate .
```

```powershell
terraform init
```

### 2. Deploy the ASG

```powershell
terraform apply -var-file="fr.tfvars"
```

### 3. Migrate the state to the `france` workspace

`cmd /c` avoids the UTF-16 encoding of the PowerShell redirection.

```powershell
cmd /c "terraform state pull > default.tfstate"
```

```powershell
terraform workspace new france
```

```powershell
terraform state push default.tfstate
```

Check that `terraform state list` shows the `module.asg` resources before going further.

```powershell
terraform state list
```

Remove the resources from the `default` state so that only `france` manages them (nothing is destroyed).

```powershell
terraform workspace select default
```

```powershell
terraform state rm module.asg
```

```powershell
terraform workspace select france
```

```powershell
rm default.tfstate
```

Apply once to update the `Name` tag of the ASG. Instances already running keep their previous tag.

```powershell
terraform apply -var-file="fr.tfvars"
```

### 4. Deploy the `germany` ASG

```powershell
terraform workspace new germany
```

```powershell
terraform apply -var-file="de.tfvars"
```

Connect to an instance with one of the `public_ips`. Run `terraform apply -refresh-only -var-file="de.tfvars"` if the list is not up to date.

```powershell
ssh -i ~/.ssh/lab4_key ec2-user@<public_ip>
```

## Clean up

Always use the `.tfvars` file matching the selected workspace.

```powershell
terraform workspace select germany
```

```powershell
terraform destroy -var-file="de.tfvars"
```

```powershell
terraform workspace select france
```

```powershell
terraform destroy -var-file="fr.tfvars"
```
