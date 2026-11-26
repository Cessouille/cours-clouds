# Lab 2 - Terraform nginx module

Terraform module that pulls an nginx image and runs one or more nginx containers with the Docker provider.

## Layout

```sh
.
|-- main.tf                 # root: provider + call to the module
|-- variables.tf            # root variables, passed to the module
`-- modules/nginx           # the reusable module
    |-- main.tf
    |-- variables.tf
```

## Inputs

| Name                  | Description                                         | Type     | Default    |
| --------------------- | --------------------------------------------------- | -------- | ---------- |
| `image_name`          | Docker image name                                   | `string` | `"nginx"`  |
| `image_tag`           | Docker image tag                                    | `string` | `"latest"` |
| `container_memory`    | Container memory (MB)                               | `number` | `256`      |
| `privileged`          | Run the container in privileged mode                | `bool`   | `false`    |
| `container_number`    | Number of containers to create                      | `number` | `1`        |
| `port_starting_point` | First external port, incremented for each container | `number` | `3000`     |

## Run

```powershell
terraform init
terraform plan
terraform apply
terraform apply -var "container_number=3" -var ...
```

Clean up when done:

```powershell
terraform destroy
```
