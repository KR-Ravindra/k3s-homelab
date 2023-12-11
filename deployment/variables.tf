variable "hosts" {
  description = "List of hosts"
  type        = list(string)
}

variable "usernames" {
  description = "Map of host to username for SSH"
  type        = map(string)
}

variable "passwords" {
  description = "Map of host to password for SSH"
  type        = map(string)
  sensitive   = true
}

variable "private_key" {
  description = "Path to the private key for SSH"
  type        = string
}

variable "default_password" {
    description = "Override if you have a single password"
    type = string
    sensitive = true
}

variable "default_username" {
    description = "Override if you have a single username"
    type = string
}

variable "is_root" {
  description = "Whether the user is root"
  type        = bool
  default     = false
}

variable "num_masters" {
  description = "The number of master nodes"
  type        = number
  default     = 1
}


variable "devops_user_password" {
  description = "The password for the devops user"
  type        = string
  default     = "devops"
}

variable "packages" {
  description = "The packages to be installed"
  type        = list(string)
  default     = ["sshpass"]
}
