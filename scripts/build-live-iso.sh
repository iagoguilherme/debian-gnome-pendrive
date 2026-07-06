#!/usr/bin/env bash
set -Eeuo pipefail

DIST="${DIST:-trixie}"
ARCH="${ARCH:-amd64}"
IMAGE_NAME="${IMAGE_NAME:-debian-saggeo-completo-${ARCH}}"

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
work_dir="${repo_dir}/build/live-build"
dist_dir="${repo_dir}/dist"

log() {
  printf '[build-live-iso] %s\n' "$*"
}

require_linux() {
  if [[ "$(uname -s)" != "Linux" ]]; then
    cat >&2 <<'EOF'
Este builder precisa rodar em Linux, preferencialmente Debian/Ubuntu.
No macOS, use uma VM Debian/Ubuntu ou gere a ISO em outro computador Linux.
EOF
    exit 1
  fi
}

require_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    echo "Rode com sudo: sudo ./scripts/build-live-iso.sh" >&2
    exit 1
  fi
}

install_dependencies() {
  if ! command -v lb >/dev/null 2>&1; then
    if command -v apt-get >/dev/null 2>&1; then
      log "Instalando live-build e dependencias."
      apt-get update
      apt-get install -y live-build debootstrap xorriso isolinux syslinux-common squashfs-tools
    else
      echo "Nao encontrei live-build nem apt-get para instalar dependencias." >&2
      exit 1
    fi
  fi
}

prepare_tree() {
  mkdir -p "${work_dir}" "${dist_dir}"
  cd "${work_dir}"

  log "Limpando configuracao anterior do live-build, se existir."
  lb clean --purge >/dev/null 2>&1 || true

  log "Configurando Debian ${DIST} ${ARCH} como ISO hibrida."
  lb config \
    --distribution "${DIST}" \
    --architectures "${ARCH}" \
    --binary-images iso-hybrid \
    --archive-areas "main contrib non-free-firmware" \
    --debian-installer live \
    --bootappend-live "boot=live components locales=pt_BR.UTF-8 keyboard-layouts=br timezone=America/Sao_Paulo" \
    --mirror-bootstrap "http://deb.debian.org/debian" \
    --mirror-chroot "http://deb.debian.org/debian" \
    --mirror-binary "http://deb.debian.org/debian"

  log "Copiando listas de pacotes, hooks e arquivos incluidos."
  mkdir -p config/package-lists config/hooks/normal config/includes.chroot
  cp -R "${repo_dir}/config/package-lists/." config/package-lists/
  cp -R "${repo_dir}/config/hooks/normal/." config/hooks/normal/
  cp -R "${repo_dir}/config/includes.chroot/." config/includes.chroot/
  find config/hooks -type f -exec chmod 755 {} +
}

build_iso() {
  cd "${work_dir}"
  log "Gerando ISO. Isso pode demorar bastante."
  lb build 2>&1 | tee "${repo_dir}/build/live-build.log"

  local iso
  iso="$(find "${work_dir}" -maxdepth 1 -type f -name '*.iso' | head -n 1)"
  if [[ -z "${iso}" ]]; then
    echo "Build terminou sem encontrar arquivo .iso." >&2
    exit 1
  fi

  cp "${iso}" "${dist_dir}/${IMAGE_NAME}.iso"
  sha512sum "${dist_dir}/${IMAGE_NAME}.iso" > "${dist_dir}/${IMAGE_NAME}.iso.sha512"
  log "ISO pronta: ${dist_dir}/${IMAGE_NAME}.iso"
  log "Checksum: ${dist_dir}/${IMAGE_NAME}.iso.sha512"
}

main() {
  require_linux
  require_root
  install_dependencies
  prepare_tree
  build_iso
}

main "$@"

