# Lab 1 - nginx container with Terraform

Runs an nginx container from the official image with the `kreuzwerker/docker` provider, on the local Docker engine.

## Layout

```sh
.
|-- main.tf                 # provider, image and container
```

## What it does

- Pulls `nginx:latest`.
- Starts a container named `lab1`, with port `80` of the container published on `8000`.
- Bonus: the container start command injects its hostname into the nginx home page.

## Run

```powershell
terraform init
terraform apply
```

Then open <http://localhost:8000>.

Clean up when done:

```powershell
terraform destroy
```
