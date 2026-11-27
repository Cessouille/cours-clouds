# Lab 6 - database and multi-tier architecture

Pair lab with two states. student_6 creates the subnets and the database (`network_rds.tfstate`): RDS PostgreSQL 14.22 in private subnets (the 14.7 of the assignment is no longer offered), its security group and the credentials in SSM Parameter Store. student_7 creates the bastion (`bastion.tfstate`, in `bastion/`): the only way into the database.

```text
laptop --SSH 22--> bastion (public subnet) --PostgreSQL 5432--> RDS (private subnets)
                      |
                      +-- IAM role --> SSM Parameter Store (credentials)
```

## Layout

```sh
.
`-- bastion
    |-- terraform.tf          # versions and S3 backend
    |-- main.tf               # datasources, security group, IAM role, key pair, instance
    |-- variables.tf          # names of the resources, SSH access
    |-- outputs.tf            # public IP, SSH command, security group IDs
    `-- user_data.sh.tftpl    # installs psql and creates connect-db.sh
```

## What the bastion does

- Reads the VPC, the public subnet, and the security group and parameters of student_6, without changing any of them. The password is not read by Terraform, so it is not in `bastion.tfstate`.
- Creates the security group `student_6_7_bastion`: SSH from your current public IP only, all outbound.
- Creates an IAM role and its instance profile. The role can:
  - read `/lab6/db/student_6_7/*` (`ssm:GetParameter`);
  - open Session Manager sessions. The AWS policy `AmazonSSMManagedInstanceCore` is not used, because it also allows reading every parameter of the account.
- Starts an Amazon Linux 2 `t3.micro` in the public subnet. At the first boot it installs the PostgreSQL 14 client and creates `/usr/local/bin/connect-db.sh`, which reads the credentials from SSM at each run. The password is not saved on the disk.

Amazon Linux 2 is past its end of life (30 June 2026). It is used because the assignment asks for it.

## What student_6 provides

All in `eu-north-1`, in the `Lab5-6` VPC.

| Resource       | Name                            |
| -------------- | ------------------------------- |
| Public subnet  | `student_6_7_Public_a`          |
| Security group | `student_6_7_rds`               |
| SSM parameter  | `/lab6/db/student_6_7/username` |
| SSM parameter  | `/lab6/db/student_6_7/password` |
| SSM parameter  | `/lab6/db/student_6_7/name`     |
| SSM parameter  | `/lab6/db/student_6_7/endpoint` |

- Encrypt the password (`SecureString`) with the default `aws/ssm` key. Another key needs `kms:Decrypt` on the bastion role.
- `endpoint` is the host name alone (`host:port` also works). The port is `5432`.
- The lab 5 network is destroyed, so the subnets come from the state of student_6: the public one (`192.168.7.0/24`, zone a) and two private ones (zones a and b) for the database. The public subnet needs a route to the internet gateway.

In step 3, student_6 adds this to their code. The names `data.aws_vpc.lab` and `aws_security_group.rds` are the ones to adapt. The RDS security group must not have inline `ingress` blocks, which conflict with this rule.

```hcl
data "aws_security_group" "bastion" {
  vpc_id = data.aws_vpc.lab.id
  name   = "student_6_7_bastion"
}

resource "aws_vpc_security_group_ingress_rule" "postgresql_from_bastion" {
  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = data.aws_security_group.bastion.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}
```

## Inputs

All have a default, so no `.tfvars` file is needed.

| Name                 | Description                     | Default                  |
| -------------------- | ------------------------------- | ------------------------ |
| `region`             | AWS region of the resources     | `eu-north-1`             |
| `name`               | Prefix of the resource names    | `student_7-lab6-bastion` |
| `pair_name`          | Pair name in the parameter path | `student_6_7`            |
| `vpc_name`           | `Name` tag of the VPC           | `Lab5-6`                 |
| `public_subnet_name` | `Name` tag of the public subnet | `student_6_7_Public_a`   |
| `rds_sg_name`        | RDS security group of student_6 | `student_6_7_rds`        |
| `bastion_sg_name`    | Security group of the bastion   | `student_6_7_bastion`    |
| `ssh_cidr`           | Addresses allowed to SSH        | your current public IP   |
| `public_key_path`    | SSH public key                  | `~/.ssh/lab6_key.pub`    |
| `ami_ssm_parameter`  | Public parameter giving the AMI | latest Amazon Linux 2    |
| `create_instance`    | `false` for step 2: no instance | `true`                   |

## Outputs

| Name                        | Description                             |
| --------------------------- | --------------------------------------- |
| `bastion_public_ip`         | Public IP of the bastion                |
| `ssh_command`               | Command to connect to the bastion       |
| `bastion_security_group_id` | Security group allowed by student_6     |
| `rds_security_group_id`     | Security group of the database          |
| `instance_id`               | Target of Session Manager               |
| `database`                  | Endpoint, name and user of the database |

## Remote state

| State       | Key in the `terraform-state-w9e85` bucket   | Owner     |
| ----------- | ------------------------------------------- | --------- |
| network_rds | `global/s3/student_6_7/network_rds.tfstate` | student_6 |
| bastion     | `global/s3/student_6_7/bastion.tfstate`     | student_7 |

Both use the `default` workspace. The bucket is in `eu-west-3`, the resources are in `eu-north-1`.

## Run

Put your AWS keys in the `default` profile of `~/.aws/credentials`, as in lab 5.

Create the SSH key, once.

```powershell
ssh-keygen -t ed25519 -f "$HOME\.ssh\lab6_key"
```

### Step 1 - student_6

student_6 applies first: subnets, RDS security group, database and parameters. Wait for the end of their apply, or the datasources find nothing.

### Step 2 - security group and IAM role

```powershell
cd bastion
```

```powershell
terraform init
```

```powershell
terraform apply -var "create_instance=false"
```

Send the security group ID (`sg-...`) to student_6. The database refuses every connection until they allow it.

```powershell
terraform output -raw bastion_security_group_id
```

### Step 3 - student_6

student_6 allows the bastion on port `5432` and applies.

### Step 4 - bastion

This starts a billed instance.

```powershell
terraform apply
```

## Test

### SSH and connection

Get the command, run it, and wait for the first boot to finish.

```powershell
terraform output -raw ssh_command
```

On the bastion:

```sh
sudo cloud-init status --wait
connect-db.sh -c "SELECT version();"
```

### Tables and data

On the bastion, open a session with `connect-db.sh`, then:

```sql
CREATE TABLE students (
  id         SERIAL PRIMARY KEY,
  name       TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO students (name) VALUES ('student_6'), ('student_7');

SELECT * FROM students;
\q
```

### Persistence

Replace the bastion: the data stays in RDS.

```powershell
terraform apply -replace "aws_instance.bastion[0]"
```

Connect to the new instance and read the table again.

```sh
connect-db.sh -c "SELECT * FROM students;"
```

### Security

| Test                                                                      | Expected result                    |
| ------------------------------------------------------------------------- | ---------------------------------- |
| student_6 removes the rule, then `connect-db.sh` on the bastion           | `timeout expired` after 10 seconds |
| `Test-NetConnection <endpoint> -Port 5432` on your laptop                 | `TcpTestSucceeded : False`         |
| SSH from another network (phone hotspot), without a new `terraform apply` | timeout                            |
| On the bastion, read a parameter outside `/lab6/db/student_6_7/`          | `AccessDeniedException`            |

For the last test:

```sh
aws ssm get-parameter --region eu-north-1 --name /lab6/db/another_pair/password
```

`<endpoint>` is shown by `terraform output database`. Leave out the `:5432` if it is there.

### Session Manager (bonus)

No SSH key and no port 22. In the AWS console: EC2 > select the bastion > Connect > Session Manager > Connect, then run `connect-db.sh`.

With the AWS CLI and its Session Manager plugin:

```powershell
aws ssm start-session --region eu-north-1 --target <instance_id>
```

## Troubleshooting

| Symptom                                                 | Cause                                                                                |
| ------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| `no matching EC2 Security Group` or parameter not found | student_6 has not applied (step 1), or a name differs                                |
| `no matching EC2 Subnet`                                | student_6 has not applied: the subnet is in their state                              |
| `AccessDenied` on `iam:CreateRole`                      | Your AWS user cannot create roles: ask the teacher                                   |
| `connect-db.sh: command not found`                      | The first boot is not finished, or failed: `sudo cat /var/log/cloud-init-output.log` |
| `timeout expired`                                       | The rule of step 3 is missing                                                        |
| `password authentication failed`                        | The password parameter differs from the one of the database                          |
| SSH timeout                                             | Your IP changed (run `terraform apply` again), or the subnet has no internet route   |

## Clean up

The order matters: AWS refuses to delete a security group used by a rule of another one, and `destroy` still reads the resources of student_6.

1. student_6 removes the rule `postgresql_from_bastion` and applies.
2. student_7 destroys the bastion:

```powershell
terraform destroy
```

3. student_6 destroys their state.
