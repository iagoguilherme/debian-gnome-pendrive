#!/usr/bin/env bash
set -Eeuo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
log_dir="${LOG_DIR:-${HOME}/.local/state/saggeo}"
log_file="${LOG_FILE:-${log_dir}/instalar-debian-$(date +%Y%m%d-%H%M%S).log}"
passo_atual=0
total_passos=0
sudo_keepalive_pid=""

if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  reset=$'\033[0m'
  bold=$'\033[1m'
  dim=$'\033[2m'
  red=$'\033[31m'
  green=$'\033[32m'
  yellow=$'\033[33m'
  blue=$'\033[34m'
  cyan=$'\033[36m'
else
  reset=""
  bold=""
  dim=""
  red=""
  green=""
  yellow=""
  blue=""
  cyan=""
fi

barra() {
  local atual="$1"
  local total="$2"
  local largura=28
  local cheio=0
  local percentual=0
  local i

  if [[ "${total}" -gt 0 ]]; then
    cheio=$((atual * largura / total))
    percentual=$((atual * 100 / total))
  fi

  printf '['
  for ((i = 0; i < cheio; i++)); do
    printf '#'
  done
  for ((i = cheio; i < largura; i++)); do
    printf '-'
  done
  printf '] %3d%%' "${percentual}"
}

banner() {
  if [[ -t 1 ]]; then
    clear || true
  fi

  printf '%b\n' "${bold}${blue}Debian GNOME Pendrive - Instalador Saggeo${reset}"
  printf '%b\n' "${dim}Saida limpa no terminal. Detalhes tecnicos ficam no log.${reset}"
  printf '%b%s%b\n\n' "${dim}Log: " "${log_file}" "${reset}"
}

falhar() {
  local mensagem="$1"
  local status="${2:-1}"
  printf '\n%bERRO:%b %s\n' "${red}${bold}" "${reset}" "${mensagem}" >&2
  if [[ -f "${log_file}" ]]; then
    printf '%bUltimas linhas do log:%b\n' "${yellow}" "${reset}" >&2
    tail -n 40 "${log_file}" >&2 || true
  fi
  exit "${status}"
}

finalizar() {
  if [[ -n "${sudo_keepalive_pid}" ]]; then
    kill "${sudo_keepalive_pid}" >/dev/null 2>&1 || true
  fi
}

trap finalizar EXIT

iniciar_sudo_keepalive() {
  (
    while true; do
      sudo -n true >/dev/null 2>&1 || exit 0
      sleep 50
    done
  ) &
  sudo_keepalive_pid="$!"
}

etapa_sudo() {
  passo_atual=$((passo_atual + 1))
  printf '%b%s%b %s\n' "${cyan}" "$(barra "${passo_atual}" "${total_passos}")" "${reset}" "Autorizando sudo"
  sudo -v || falhar "Nao consegui liberar sudo."
  iniciar_sudo_keepalive
  printf '%bOK%b sudo liberado\n\n' "${green}" "${reset}"
}

rodar_limpo() {
  local descricao="$1"
  shift
  local pid
  local status
  local frames='|/-\'
  local frame=0

  passo_atual=$((passo_atual + 1))
  printf '%b%s%b %s ' "${cyan}" "$(barra "${passo_atual}" "${total_passos}")" "${reset}" "${descricao}"

  {
    printf '\n### %s\n' "${descricao}"
    date
    "$@"
  } >>"${log_file}" 2>&1 &

  pid="$!"
  while kill -0 "${pid}" >/dev/null 2>&1; do
    printf '\r%b%s%b %s %s' \
      "${cyan}" "$(barra "${passo_atual}" "${total_passos}")" "${reset}" \
      "${descricao}" "${frames:frame % 4:1}"
    frame=$((frame + 1))
    sleep 0.2
  done

  if wait "${pid}"; then
    printf '\r%b%s%b %s %bOK%b\n' \
      "${cyan}" "$(barra "${passo_atual}" "${total_passos}")" "${reset}" \
      "${descricao}" "${green}" "${reset}"
  else
    status="$?"
    printf '\r%b%s%b %s %bFALHOU%b\n' \
      "${cyan}" "$(barra "${passo_atual}" "${total_passos}")" "${reset}" \
      "${descricao}" "${red}" "${reset}"
    falhar "Falha na etapa: ${descricao}" "${status}"
  fi
}

rodar_interativo() {
  local descricao="$1"
  shift

  passo_atual=$((passo_atual + 1))
  printf '\n%b%s%b %s\n' "${cyan}" "$(barra "${passo_atual}" "${total_passos}")" "${reset}" "${descricao}"
  printf '%bRespostas internas em auto-sim; logins externos ainda podem abrir tela/terminal.%b\n\n' "${yellow}" "${reset}"

  {
    printf '\n### %s\n' "${descricao}"
    date
  } >>"${log_file}" 2>&1

  if "$@" 2>&1 | tee -a "${log_file}"; then
    printf '\n%bOK%b %s\n' "${green}" "${reset}" "${descricao}"
  else
    falhar "Falha na etapa: ${descricao}"
  fi
}

require_debian() {
  if ! command -v apt-get >/dev/null 2>&1; then
    falhar "Este instalador espera um Debian/Ubuntu com apt-get."
  fi
}

verificar_estado() {
  local comandos=(
    python3
    pip3
    git
    gh
    evince
    vlc
    codium
    google-chrome
    google-earth-pro
    gnome-terminal
    dconf
    codex
    claude
    gcloud
    op
  )
  local pacotes=(
    python3-full
    python3-numpy
    python3-pandas
    python3-scipy
    python3-matplotlib
    python3-openpyxl
    fonts-jetbrains-mono
    fonts-noto-color-emoji
    dconf-cli
    1password
    1password-cli
    google-cloud-cli
  )
  local item

  printf 'Comandos:\n'
  for item in "${comandos[@]}"; do
    if command -v "${item}" >/dev/null 2>&1; then
      printf '  OK     %s\n' "${item}"
    else
      printf '  FALTA  %s\n' "${item}"
    fi
  done

  printf '\nPacotes Debian:\n'
  for item in "${pacotes[@]}"; do
    if dpkg -s "${item}" >/dev/null 2>&1; then
      printf '  OK     %s\n' "${item}"
    else
      printf '  FALTA  %s\n' "${item}"
    fi
  done
}

instalar_comandos_saggeo() {
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
    "${repo_dir}/config/includes.chroot/usr/local/bin/saggeo-aplicar-terminal" \
    /usr/local/bin/saggeo-aplicar-terminal

  sudo install -m 0755 \
    "${repo_dir}/config/includes.chroot/usr/local/bin/saggeo-python-venv" \
    /usr/local/bin/saggeo-python-venv

  sudo install -m 0755 \
    "${repo_dir}/config/includes.chroot/usr/local/bin/saggeo-primeiro-login" \
    /usr/local/bin/saggeo-primeiro-login

  sudo install -m 0644 \
    "${repo_dir}/config/includes.chroot/etc/profile.d/saggeo-python.sh" \
    /etc/profile.d/saggeo-python.sh
}

main() {
  mkdir -p "${log_dir}"
  : >"${log_file}"
  banner

  require_debian

  export SAGGEO_ASSUME_YES=1
  export GIT_TERMINAL_PROMPT=0

  printf '%bModo automatico:%b respostas confirmadas como sim/yes.\n' "${green}" "${reset}"

  total_passos=8
  printf '\n%bIniciando %s etapas.%b\n\n' "${bold}" "${total_passos}" "${reset}"

  etapa_sudo
  rodar_limpo "Verificando instalados e pendencias" verificar_estado
  rodar_limpo "Instalando comandos Saggeo" instalar_comandos_saggeo
  rodar_limpo "Atualizando base, Python, GitHub CLI e utilitarios" sudo saggeo-pos-instalacao
  rodar_limpo "Instalando PDF, VLC, VSCodium, Chrome e Google Earth" saggeo-instalar-apps-desktop
  rodar_limpo "Aplicando visual Ghostty no GNOME Terminal" saggeo-aplicar-terminal
  rodar_interativo "Instalando Codex, Claude Code e dotfiles" saggeo-instalar-agentes
  rodar_limpo "Instalando Google Cloud CLI e 1Password" saggeo-instalar-cloud-tools

  printf '\n%bConcluido.%b\n' "${green}${bold}" "${reset}"
  printf 'Log tecnico salvo em: %s\n' "${log_file}"
  printf 'Comandos instalados: saggeo-pos-instalacao, saggeo-instalar-apps-desktop, saggeo-aplicar-terminal, saggeo-python-venv, saggeo-instalar-agentes, saggeo-instalar-cloud-tools\n'
}

main "$@"
