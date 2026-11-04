variable "install_dependencies" {
  description = "Whether to install/download application dependencies."
  type        = bool
  default     = true
}

variable "docker_users" {
  description = "List of users that should have execute permission on the docker daemon"
  type        = list(string)
  default     = []
}

variable "install_container_toolkit" {
  description = "Whether to install and configure nvidia docker container toolkit."
  type        = bool
  default     = true
}
