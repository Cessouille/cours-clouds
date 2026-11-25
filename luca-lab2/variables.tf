variable "image_name" {
  description = "Value of the name for the Docker image to use"
  type        = string
  default     = "nginx"
}

variable "image_tag" {
  description = "Value of the tag for the Docker image to use"
  type        = string
  default     = "latest"
}

variable "container_memory" {
  description = "Value of the Docker container's memory"
  type        = number
  default     = 256

  validation {
    condition     = var.container_memory >= 0
    error_message = "container_memory must be 0 or greater."
  }
}

variable "privileged" {
  description = "Value of the Docker container's privileged mode"
  type        = bool
  default     = false
}

variable "container_number" {
  description = "Value of the number of containers to create"
  type        = number
  default     = 1

  validation {
    condition     = var.container_number >= 0
    error_message = "container_number must be 0 or greater."
  }
}

variable "port_starting_point" {
  description = "Value of the starting point for the external port"
  type        = number
  default     = 3000

  validation {
    condition     = var.port_starting_point >= 1 && var.port_starting_point + var.container_number - 1 <= 65535
    error_message = "port_starting_point + container_number must stay within the valid port range (1-65535)."
  }
}
