# Lab 3 - first steps on AWS

Creates an EC2 instance in the existing main VPC (no new VPC) and sets up SSH access.

## Layout

```sh
.
|-- terraform.tf            # required Terraform and provider versions
|-- main.tf                 # provider, key pair, security group, EC2 instance
|-- variables.tf            # variables (credentials are sensitive)
|-- outputs.tf              # public IP and ready-to-use SSH command
`-- terraform.tfvars.example
```

## Inputs

| Name              | Description                       | Default                    |
| ----------------- | --------------------------------- | -------------------------- |
| `access_key`      | AWS access key ID (sensitive)     | required                   |
| `secret_key`      | AWS secret access key (sensitive) | required                   |
| `region`          | AWS region                        | `eu-west-3`                |
| `vpc_id`          | Existing VPC                      | `vpc-01b6138c71cc82aba`    |
| `subnet_id`       | Existing subnet                   | `subnet-0855fbfcf29f845c3` |
| `ami`             | AMI of the instance               | `ami-092c64119783c2f31`    |
| `instance_type`   | Instance type                     | `t3.micro`                 |
| `public_key_path` | SSH public key sent to AWS        | `~/.ssh/lab3_key.pub`      |

## Run

Put your AWS keys in `terraform.tfvars`.

```powershell
cp terraform.tfvars.example terraform.tfvars
```

Generate an SSH key.

```powershell
ssh-keygen -t ed25519 -f ~/.ssh/lab3_key
```

Start terraform

```powershell
terraform init
terraform apply
```

Connect with the `ssh_command` output:

```powershell
ssh -i ~/.ssh/lab3_key ec2-user@<public_ip>
```

Clean up when done:

```powershell
terraform destroy
```
