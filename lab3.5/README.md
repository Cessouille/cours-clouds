# Lab 3.5 - datasources and output variables

Creates an EC2 instance in the existing main VPC (no new VPC) and sets up SSH access.

## Layout

```sh
.
|-- terraform.tf            # required Terraform and provider versions
|-- main.tf                 # provider + call to the ec2 module
|-- variables.tf            # variables (credentials are sensitive)
|-- outputs.tf              # public DNS, public IP and ready-to-use SSH command
|-- terraform.tfvars.example
`-- modules/ec2
    |-- main.tf             # datasources (AMI, subnet), key pair, security group, instance
    |-- variables.tf        # name, instance_type, subnet_id, public_key_path
    `-- outputs.tf          # public_dns, public_ip, ami_id
```

## Datasources

- `data "aws_ami"`: latest Amazon Linux 2023 (`ec2-user`) owned by Amazon, instead of a hardcoded AMI ID.
- `data "aws_subnet"`: looks up the existing subnet by ID; the VPC for the security group is read from it, so no `vpc_id` variable is needed.

## Inputs

| Name              | Description                       | Default                    |
| ----------------- | --------------------------------- | -------------------------- |
| `access_key`      | AWS access key ID (sensitive)     | required                   |
| `secret_key`      | AWS secret access key (sensitive) | required                   |
| `region`          | AWS region                        | `eu-west-3`                |
| `subnet_id`       | Existing subnet                   | `subnet-0855fbfcf29f845c3` |
| `name`            | Name of the instance (Name tag)   | `lab3-ec2`                 |
| `instance_type`   | Instance type                     | `t2.micro`                 |
| `public_key_path` | SSH public key sent to AWS        | `~/.ssh/lab3.5_key.pub`    |

## Outputs

| Name          | Description                     |
| ------------- | ------------------------------- |
| `public_dns`  | Public DNS name of the instance |
| `public_ip`   | Public IP of the instance       |
| `ssh_command` | Ready-to-use SSH command        |

## Run

Put your AWS keys in `terraform.tfvars`.

```powershell
cp terraform.tfvars.example terraform.tfvars
```

Generate an SSH key.

```powershell
ssh-keygen -t ed25519 -f ~/.ssh/lab3.5_key
```

Start terraform

```powershell
terraform init
terraform apply
```

Connect with the `ssh_command` output:

```powershell
ssh -i ~/.ssh/lab3.5_key ec2-user@<public_dns>
```

Clean up when done:

```powershell
terraform destroy
```
