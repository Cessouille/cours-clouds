# Cours clouds

Terraform labs for the cloud course.

## Labs

| Lab                 | Topic                                                         |
|---------------------|---------------------------------------------------------------|
| [Lab 1](lab1)       | nginx container with the Docker provider                      |
| [Lab 2](lab2)       | the same, as a configurable and validated Terraform module    |
| [Lab 2a](luca-lab2) | uses a classmate's lab2 module, referenced from GitHub        |
| [Lab 3](lab3)       | first steps on AWS: EC2 instance with SSH access              |

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install)
- Docker (lab1, lab2)
- AWS account with an access key (lab3)

## Usage

Each lab is independent. Go into its folder and run:

```powershell
terraform init
terraform apply
```

Clean up when done:

```powershell
terraform destroy
```
