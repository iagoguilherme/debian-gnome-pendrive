# Debian Pendrive Completo

Repositório para gerar uma imagem Debian bootável com desktop e ferramentas base de trabalho, evitando a instalação mínima sem interface que aconteceu com a imagem `netinst`.

## O que este projeto entrega

- ISO Debian Live `amd64` com GNOME.
- Instalador gráfico incluído no ambiente live.
- Pacotes base de terminal, rede, Git e desenvolvimento.
- Pilha Python com `venv`, `pip`, `numpy`, `pandas`, `scipy`, `matplotlib`, `openpyxl` e utilitários comuns.
- Base para agentes de terminal: Node/npm, Codex CLI, Claude Code e dotfiles.
- Integração com o repositório de configurações `git@github.com:iagoguilherme/mac-bootstrap.git`, incluindo Ghostty, Claude e Codex.
- Scripts separados para gravar a ISO no pendrive no macOS ou no Linux, sempre com confirmação explícita.

## Requisitos

Para gerar a ISO customizada:

- Debian/Ubuntu em uma máquina Linux ou VM.
- Internet.
- Pelo menos 20 GB livres.
- Permissão de `sudo`.

No macOS, use este repositório para gravar a ISO pronta no pendrive. A geração da ISO completa usa `live-build`, que deve rodar em Linux.

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

Depois de instalar o Debian no computador, rode com o usuário normal:

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

## Observação

Este repositório cria um sistema live/installável mais completo. Ele não cria um repositório GitHub remoto automaticamente, porque criar repositório remoto exige confirmação explícita.
