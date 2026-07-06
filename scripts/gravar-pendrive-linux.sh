#!/usr/bin/env bash
set -Eeuo pipefail

iso="${1:-}"

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "Este script e para Linux. Use scripts/gravar-pendrive-macos.sh no macOS." >&2
  exit 1
fi

if [[ -z "${iso}" || ! -f "${iso}" ]]; then
  echo "Uso: $0 caminho/para/imagem.iso" >&2
  exit 1
fi

echo "Discos detectados:"
lsblk -o NAME,MODEL,SIZE,TYPE,TRAN,MOUNTPOINTS
echo

read -r -p "Dispositivo do pendrive inteiro, exemplo /dev/sdb: " disk_path
if [[ ! "${disk_path}" =~ ^/dev/[a-zA-Z0-9]+$ || ! -b "${disk_path}" ]]; then
  echo "Dispositivo invalido: ${disk_path}" >&2
  exit 1
fi

if lsblk -dn -o TRAN "${disk_path}" | grep -vqE 'usb|mmc'; then
  echo "Abortado: ${disk_path} nao parece ser USB/MMC removivel." >&2
  exit 1
fi

echo
echo "ATENCAO: isto apagara todo o conteudo de ${disk_path}."
read -r -p "Digite exatamente APAGAR ${disk_path} para continuar: " confirmacao
if [[ "${confirmacao}" != "APAGAR ${disk_path}" ]]; then
  echo "Abortado."
  exit 1
fi

echo "Desmontando particoes de ${disk_path}."
lsblk -ln -o NAME "${disk_path}" | tail -n +2 | while read -r part; do
  sudo umount "/dev/${part}" 2>/dev/null || true
done

sudo dd if="${iso}" of="${disk_path}" bs=4M status=progress oflag=sync
sync
sudo eject "${disk_path}" || true

echo "Pendrive bootavel pronto."

