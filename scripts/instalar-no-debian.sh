#!/usr/bin/env bash
set -Eeuo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

log() {
  printf '[instalar-no-debian] %s\n' "$*"
}

confirmar() {
  local pergunta="$1"
  local resposta
  read -r -p "${pergunta} [s/N] " resposta
  [[ "${resposta}" =~ ^[Ss]$ ]]
}

require_debian() {
  if ! command -v apt-get >/dev/null 2>&1; then
    echo "Este instalador espera um Debian/Ubuntu com apt-get." >&2
    exit 1
  fi
}

require_sudo() {
  if ! sudo -v; then
    echo "Este instalador precisa de sudo." >&2
    exit 1
  fi
}

instalar_comandos_saggeo() {
  log "Instalando comandos Saggeo em /usr/local."

  sudo install -m 0755 \
    "${repo_dir}/config/includes.chroot/usr/local/sbin/saggeo-pos-instalacao" \
    /usr/local/sbin/saggeo-pos-instalacao

  sudo install -m 0755 \
    "${repo_dir}/config/includes.chroot/usr/local/bin/saggeo-instalar-agentes" \
    /usr/local/bin/saggeo-instalar-agentes

  sudo install -m 0755 \
    "${repo_dir}/config/includes.chroot/usr/local/bin/saggeo-instalar-apps-desktop" \
    /usr/local/bin/saggeo-instalar-apps-desktop

  sudo install -m 0755 \
    "${repo_dir}/config/includes.chroot/usr/local/bin/saggeo-instalar-cloud-tools" \
    /usr/local/bin/saggeo-instalar-cloud-tools

  sudo install -m 0755 \
    "${repo_dir}/config/includes.chroot/usr/local/bin/saggeo-primeiro-login" \
    /usr/local/bin/saggeo-primeiro-login
}

main() {
  require_debian
  require_sudo
  instalar_comandos_saggeo

  log "Rodando pos-instalacao base."
  sudo saggeo-pos-instalacao

  log "Instalando apps desktop padrao."
  saggeo-instalar-apps-desktop

  if confirmar "Instalar Codex, Claude Code e dotfiles agora?"; then
    saggeo-instalar-agentes
  fi

  if confirmar "Instalar Google Cloud CLI, 1Password CLI e app 1Password agora?"; then
    saggeo-instalar-cloud-tools
  fi

  log "Concluido."
}

main "$@"
