# Debian Pendrive Completo

Repositório para gerar uma imagem Debian bootável com desktop e ferramentas base de trabalho, evitando a instalação mínima sem interface que aconteceu com a imagem `netinst`.

## O que este projeto entrega

- ISO Debian Live `amd64` com GNOME.
- Instalador gráfico incluído no ambiente live.
- Pacotes base de terminal, rede, Git e desenvolvimento.
- Pilha Python completa com `python3-full`, `venv`, `pip`, `numpy`, `pandas`, `scipy`, `matplotlib`, `openpyxl` e utilitários comuns.
- Apps desktop: leitor PDF, VLC, VSCodium, Google Chrome e Google Earth Pro.
- Base para GitHub e agentes de terminal: Git, Git LFS, GitHub CLI `gh`, Node/npm, Codex CLI, Claude Code e dotfiles.
- Integração com o repositório de configurações `git@github.com:iagoguilherme/mac-bootstrap.git`, incluindo Ghostty, Claude e Codex.
- Dependências Saggeo do arquivo `DEPENDENCIES.md`: Pillow, piexif, Flask, bibliotecas Google, gcloud, 1Password CLI e padrões de Secret Manager.
- Assistente de primeiro login para orientar a pós-instalação e oferecer agentes/cloud tools.
- Scripts separados para gravar a ISO no pendrive no macOS ou no Linux, sempre com confirmação explícita.

## Requisitos

Para gerar a ISO customizada:

- Debian/Ubuntu em uma máquina Linux ou VM.
- Internet.
- Pelo menos 20 GB livres.
- Permissão de `sudo`.

No macOS, use este repositório para gravar a ISO pronta no pendrive. A geração da ISO completa usa `live-build`, que deve rodar em Linux.

## Instalar Tudo No Debian Oficial

Se o computador foi instalado com a ISO oficial do Debian GNOME, clone este repo
e rode um comando unico:

```bash
cd debian-gnome-pendrive
./scripts/instalar-no-debian.sh
```

Esse instalador copia os comandos Saggeo para `/usr/local`, roda a
pos-instalacao base e instala Python completo, Git, GitHub CLI, leitor PDF, VLC,
VSCodium, Google Chrome e Google Earth Pro. Codex/Claude/dotfiles, Google Cloud
CLI e 1Password sao oferecidos como etapas opcionais no final.

## Gerar a ISO customizada

Em uma máquina Debian/Ubuntu:

```bash
cd /caminho/debian-pendrive-completo
sudo ./scripts/build-live-iso.sh
```

A ISO final será copiada para:

```text
dist/debian-saggeo-completo-amd64.iso
```

## Gravar no pendrive pelo macOS

No Mac, depois de trazer a ISO para esta pasta:

```bash
./scripts/gravar-pendrive-macos.sh dist/debian-saggeo-completo-amd64.iso
```

O script mostra os discos externos, pede o identificador do pendrive e exige a frase de confirmação antes de apagar qualquer coisa.

## Boot pelo pendrive

A ISO gerada é híbrida e deve iniciar em BIOS legado e UEFI. No computador alvo,
abra o menu de boot da placa-mãe e escolha a entrada USB, de preferência a opção
começando por `UEFI`.

Teclas comuns para o menu de boot: `F12`, `F8`, `Esc`, `Del` ou `F11`, dependendo
do fabricante. O pendrive não consegue sozinho forçar a placa-mãe a iniciar por
ele; essa escolha fica na BIOS/UEFI do computador.

Depois que o Debian for instalado no disco interno, o instalador configura o GRUB
e o computador passa a iniciar pelo sistema instalado.

## Gravar no pendrive pelo Linux

```bash
./scripts/gravar-pendrive-linux.sh dist/debian-saggeo-completo-amd64.iso
```

## Ajustar pacotes

Edite os arquivos em:

```text
config/package-lists/
```

Cada arquivo `*.list.chroot` vira uma lista de pacotes instalada dentro da ISO.

## Agentes, Claude, Codex E Ghostty

No primeiro login, o assistente `saggeo-primeiro-login` abre automaticamente e
oferece essa etapa. Para rodar manualmente com o usuário normal:

```bash
saggeo-instalar-agentes
```

Esse comando:

- instala a base `nodejs`, `npm`, `zsh`, `gh` e afins;
- instala o Codex CLI via `npm install -g @openai/codex`;
- oferece instalar o Claude Code pelo instalador oficial;
- clona ou atualiza `git@github.com:iagoguilherme/mac-bootstrap.git`;
- aplica config do Ghostty, Claude Code e template do Codex sem copiar segredos.

Logins e tokens ficam fora da ISO. Depois você autentica Codex, Claude e GitHub normalmente no sistema instalado.

## GCP, 1Password E Dependências Saggeo

Depois de instalar o Debian no computador, rode:

```bash
saggeo-instalar-cloud-tools
```

Esse comando instala:

- Google Cloud CLI (`gcloud`) pelo repositório apt oficial do Google;
- 1Password CLI (`op`) e app desktop 1Password pelo repositório apt oficial do 1Password;
- projeto padrão `saggeo-ecosystem-prod`;
- região padrão `us-central1`.

Ele não grava credenciais. O padrão operacional continua sendo:

- 1Password CLI para VMs/máquinas locais;
- Secret Manager para Cloud Run;
- tokens e service accounts configurados depois, fora da ISO.

## Apps Desktop

Para instalar ou reparar os apps desktop manualmente:

```bash
saggeo-instalar-apps-desktop
```

Esse comando instala `evince` como leitor PDF, VLC, VSCodium, Google Chrome e
Google Earth Pro. Chrome e Earth Pro sao instalados somente em `amd64`, que e a
arquitetura esperada para o PC alvo.

## Observação

Este repositório cria um sistema live/installável mais completo. Segredos,
tokens, chaves SSH e credenciais continuam fora da ISO.
