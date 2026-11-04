output "configuration" {
  description = "Cloudinit compatible docker installation script"
  value = templatefile(
    "${path.module}/user_data.yaml.tpl",
    {
      install_dependencies      = var.install_dependencies
      install_container_toolkit = var.install_container_toolkit
      docker_install_script     = base64gzip(file("${path.module}/install_docker.sh"))
      docker_users              = var.docker_users
    }
  )
}
