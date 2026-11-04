#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

SCRIPT_NAME="$(basename "$0")"

log() {
  printf '[%s] [%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$SCRIPT_NAME" "$1"
}

install_docker() {
  log "Installing Docker Engine..."

  apt-get update -qq
  apt-get install -y ca-certificates curl gnupg

  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc

  local codename
  codename="$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")"

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu ${codename} stable" |
    tee /etc/apt/sources.list.d/docker.list >/dev/null

  apt-get update -qq
  apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

  log "Docker installed successfully."
}

has_nvidia_driver() {
  if command -v nvidia-smi &>/dev/null && nvidia-smi &>/dev/null; then
    return 0
  fi
  return 1
}

install_nvidia_docker() {
  log "Installing NVIDIA Container Toolkit..."

  curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey |
    gpg --yes --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

  curl -fsSL https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list |
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' |
    tee /etc/apt/sources.list.d/nvidia-container-toolkit.list >/dev/null

  apt-get update -qq
  apt-get install -y nvidia-container-toolkit

  nvidia-ctk runtime configure --runtime=docker
  systemctl restart docker

  log "NVIDIA Container Toolkit installed and Docker runtime configured."
}

main() {
  local install_container_toolkit=true
  local arg

  for arg in "$@"; do
    case "$arg" in
      --install-container-toolkit=true)  install_container_toolkit=true ;;
      --install-container-toolkit=false) install_container_toolkit=false ;;
      *)
        printf 'Invalid argument: %s\n' "$arg" >&2
        return 2
        ;;
    esac
  done

  install_docker

  if [[ "$install_container_toolkit" == "true" ]] && has_nvidia_driver; then
    install_nvidia_docker
  else
    log "Skipping NVIDIA Container Toolkit installation."
  fi
}

main "$@"