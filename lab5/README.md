# Lab 5 - load balanced Auto Scaling Groups

Pair lab with two states. student_6 creates the network and the application load balancer (`network.tfstate`). student_7 creates the instances (`ec2.tfstate`, in `ec2/`): two Auto Scaling Groups of 2 `t3.micro`, named `nginx` and `tomcat`, in the private subnet and behind the load balancer.

Both run Amazon Linux 2023. No nginx or Tomcat is installed: the user data of the assignment starts the Python web server on port `80`, with a page that tells which application and instance answered. It needs no internet access.

## Layout

```sh
.
`-- ec2
    |-- terraform.tf            # versions and S3 backend
    |-- main.tf                 # provider, datasources, calls to the asg module with their user data
    |-- variables.tf            # region, names of the network resources, AMI
    |-- outputs.tf              # ASG names, AMI name, test URLs
    `-- modules/asg
        |-- main.tf             # launch template and ASG
        |-- variables.tf        # AMI, sizes, subnets, security groups, target groups
        `-- outputs.tf          # asg_name, launch_template_id
```

## What it does

- Reads the network of student_6 from AWS, without creating or changing any of it.
- Calls the `asg` module once per entry of `target_group_names` (`for_each`), with `min_size = 2` and `max_size = 2`.
- Registers each ASG in its target group. The load balancer health checks then replace the unhealthy instances.
- Runs the user data at the first boot. `${each.key}` is `nginx` or `tomcat`:
  - reads the instance ID from the metadata service;
  - writes the same page in `/srv/index.html` (health check) and `/srv/<app>/index.html` (the load balancer forwards the path as is);
  - serves `/srv` on port `80`.
- Replaces the running instances progressively when the launch template changes (AMI, user data, security group).

## Datasources

- `data "aws_vpc"`: the `Lab5-6` VPC, by its `Name` tag.
- `data "aws_subnet"`: the private subnet, by its `Name` tag.
- `data "aws_security_group"`: the `internal` security group, by its name.
- `data "aws_lb"` and `data "aws_lb_target_group"`: the load balancer and its two target groups, by their names.
- `data "aws_ami"`: latest Amazon Linux 2023 owned by Amazon, instead of a hardcoded AMI ID.

## What student_6 provides

All in `eu-north-1`.

| Resource       | Name                                      |
| -------------- | ----------------------------------------- |
| VPC            | `Lab5-6`                                  |
| Private subnet | `student_6_7_Private`                     |
| Security group | `student_6_7_internal`                    |
| Load balancer  | `student-6-7-alb`                         |
| Target groups  | `student-6-7-nginx`, `student-6-7-tomcat` |

The network also has to:

- send both `/nginx` and `/nginx/*` to the nginx target group, and likewise for Tomcat (the web server redirects `/nginx` to `/nginx/`);
- use port `80` and the health check path `/` on both target groups;
- allow ports `80` and `443` from the load balancer on the `internal` security group;
- place the private subnet in the same availability zone as one of the public subnets, or the load balancer sends no traffic to the instances.

## Inputs

All have a default, so no `.tfvars` file is needed.

| Name                  | Description                               | Default                                                          |
| --------------------- | ----------------------------------------- | ---------------------------------------------------------------- |
| `region`              | AWS region of the resources               | `eu-north-1`                                                     |
| `name`                | Prefix of the resource names              | `student_7-lab5`                                                 |
| `vpc_name`            | `Name` tag of the VPC                     | `Lab5-6`                                                         |
| `private_subnet_name` | `Name` tag of the private subnet          | `student_6_7_Private`                                            |
| `internal_sg_name`    | Security group of the instances           | `student_6_7_internal`                                           |
| `alb_name`            | Application load balancer                 | `student-6-7-alb`                                                |
| `target_group_names`  | Target group of each application, one ASG | `{ nginx = "student-6-7-nginx", tomcat = "student-6-7-tomcat" }` |
| `ami_name`            | Name pattern of the Amazon AMI            | `al2023-ami-2023.*-x86_64`                                       |

## Module `asg`

| Name                        | Description                              | Default    |
| --------------------------- | ---------------------------------------- | ---------- |
| `name`                      | Instance name and resource name prefix   | required   |
| `ami_id`                    | AMI of the instances                     | required   |
| `min_size`                  | Minimum number of instances              | required   |
| `max_size`                  | Maximum number of instances              | required   |
| `subnet_ids`                | Subnets the instances are created in     | required   |
| `security_group_ids`        | Security groups of the instances         | required   |
| `instance_type`             | EC2 instance type                        | `t3.micro` |
| `target_group_arns`         | Load balancer target groups to join      | `[]`       |
| `user_data`                 | First boot script                        | none       |
| `health_check_grace_period` | Seconds before a new instance is checked | `300`      |

## Outputs

| Name        | Description                                   |
| ----------- | --------------------------------------------- |
| `asg_names` | Name of the ASG of each application           |
| `ami_name`  | Name of the AMI found by the datasource       |
| `urls`      | Addresses of nginx and Tomcat on the balancer |

## Remote state

| State   | Key in the `terraform-state-w9e85` bucket | Owner     |
| ------- | ----------------------------------------- | --------- |
| network | `global/s3/student_6_7/network.tfstate`   | student_6 |
| ec2     | `global/s3/student_6_7/ec2.tfstate`       | student_7 |

Both use the `default` workspace. The bucket is in `eu-west-3`, the resources are in `eu-north-1`. Locking uses the DynamoDB table `terraform-up-and-running-locks`. Recent Terraform versions warn that `dynamodb_table` is deprecated.

## Run

student_6 applies first.

Put your AWS keys in `~/.aws/credentials`. The provider and the S3 backend both read the `default` profile, so there is nothing to pass to Terraform.

```ini
[default]
aws_access_key_id = ...
aws_secret_access_key = ...
```

Go into the root module. All the next commands run from there.

```powershell
cd ec2
```

Initialize the providers, the module and the S3 backend.

```powershell
terraform init
```

Check that the `default` workspace is selected.

```powershell
terraform workspace show
```

```powershell
terraform workspace select default
```

Check the formatting and the configuration.

```powershell
terraform fmt -check -recursive
```

```powershell
terraform validate
```

Preview, then create 2 launch templates and 2 ASGs. This starts 4 instances, which are billed.

```powershell
terraform plan
```

```powershell
terraform apply
```

## Test

Show the addresses again.

```powershell
terraform output
```

Wait a few minutes for the instances to become healthy, then request both applications with the `urls` output. Keep the final `/`.

```powershell
curl.exe -i http://<alb_dns_name>/nginx/
```

```powershell
curl.exe -i http://<alb_dns_name>/tomcat/
```

Each page shows the ID of the instance that answered. Repeat the request to see both instances.

```powershell
1..6 | ForEach-Object { curl.exe -s http://<alb_dns_name>/nginx/ }
```

```powershell
1..6 | ForEach-Object { curl.exe -s http://<alb_dns_name>/tomcat/ }
```

List the resources of the state.

```powershell
terraform state list
```

## Troubleshooting

| Symptom                              | Cause                                                                    |
| ------------------------------------ | ------------------------------------------------------------------------ |
| `no matching ... found` (datasource) | The network is not applied, or a name differs                            |
| `404 Use /nginx or /tomcat`          | Wrong path                                                               |
| `503 Service Temporarily Unavailable` | No instance in the target group, they are not created yet or not healthy |
| Instances replaced over and over     | The health check fails: read the boot output                             |
| `Error acquiring the state lock`     | Another run holds the lock, or an interrupted run left it                |

The instances have no public IP and no SSH access. Read the output of the first boot in the EC2 console: select an instance, then Actions > Monitor and troubleshoot > Get system log.

The web server is only started at the first boot. A rebooted instance stops answering and the ASG replaces it.

After a change to the user data in `main.tf`, apply again: the ASGs replace their instances.

To remove a lock left by an interrupted run (check first that nobody is running Terraform):

```powershell
terraform force-unlock <lock_id>
```

## Clean up

Destroy this state before student_6 destroys the network.

```powershell
terraform destroy
```
