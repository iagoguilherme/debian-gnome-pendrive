#!/usr/bin/env bash
set -Eeuo pipefail

iso="${1:-}"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Este script e para macOS. Use scripts/gravar-pendrive-linux.sh no Linux." >&2
  exit 1
fi

if [[ -z "${iso}" || ! -f "${iso}" ]]; then
  echo "Uso: $0 caminho/para/imagem.iso" >&2
  exit 1
fi

echo "Discos externos detectados:"
diskutil list external
echo

read -r -p "Identificador do pendrive inteiro, exemplo disk4: " disk_id
if [[ ! "${disk_id}" =~ ^disk[0-9]+$ ]]; then
  echo "Identificador invalido: ${disk_id}" >&2
  exit 1
fi

info="$(diskutil info "/dev/${disk_id}")"
echo "${info}"

if ! printf '%s\n' "${info}" | grep -q "Device Location:.*External"; then
  echo "Abortado: /dev/${disk_id} nao parece ser um disco externo." >&2
  exit 1
fi

if ! printf '%s\n' "${info}" | grep -q "Removable Media:.*Removable"; then
  echo "Abortado: /dev/${disk_id} nao parece ser midia removivel." >&2
  exit 1
fi

echo
echo "ATENCAO: isto apagara todo o conteudo de /dev/${disk_id}."
read -r -p "Digite exatamente APAGAR ${disk_id} para continuar: " confirmacao
if [[ "${confirmacao}" != "APAGAR ${disk_id}" ]]; then
  echo "Abortado."
  exit 1
fi

echo "Desmontando /dev/${disk_id}."
diskutil unmountDisk "/dev/${disk_id}"

echo "Gravando ISO. No macOS, pressione Ctrl+T para ver progresso do dd."
sudo dd if="${iso}" of="/dev/r${disk_id}" bs=4m conv=sync
sync
diskutil eject "/dev/${disk_id}"

echo "Pendrive bootavel pronto."

