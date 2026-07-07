# Inventario De Pacotes

## Desktop

- GNOME completo via `task-gnome-desktop`
- Firefox ESR
- LibreOffice
- Evince como leitor PDF
- VLC
- Ghostty com configuracao Clear Dark
- Ghostty instalado via apt quando disponivel; em Debian usa o repositorio comunitario `debian.griffo.io`
- Chrome como navegador principal
- VSCodium como app padrao para textos/codigo
- VLC como app padrao para videos/midia
- GNOME Terminal apenas como fallback do desktop
- JetBrains Mono
- JetBrainsMono Nerd Font instalada por `saggeo-aplicar-terminal`
- Noto Color Emoji
- dconf-cli
- GParted
- Calamares para instalacao grafica a partir do live

## Sistema

- NetworkManager
- sudo
- openssh-client e openssh-server
- firmware Linux comum, incluindo Realtek e misc non-free-firmware

## Desenvolvimento

- git e git-lfs
- curl e wget
- build-essential
- pkg-config
- make e cmake
- jq, ripgrep, fd-find, tree, htop, tmux, vim e nano

## Python E Dados

- python3
- python3-full
- python3-venv
- python3-pip
- python3-dev
- numpy
- pandas
- scipy
- matplotlib
- openpyxl
- requests
- BeautifulSoup
- lxml
- PyYAML
- Pillow
- piexif
- Flask
- google-auth
- Google API client
- Google Maps client opcional
- IPython
- pipx
- variaveis globais em `/etc/profile.d/saggeo-python.sh`
- helper `saggeo-python-venv`

## Agentes E Configuracoes

- nodejs e npm
- Codex CLI via pacote npm `@openai/codex`
- Claude Code via instalador oficial, como etapa opcional pós-instalação
- GitHub CLI `gh`
- zsh
- dotfiles/configuração padrão: `git@github.com:iagoguilherme/mac-bootstrap.git`
- configuração de Ghostty aplicada a partir de `ghostty/config` no repo de dotfiles

## Apps Desktop Externos

- VSCodium via repositorio apt do projeto VSCodium
- Google Chrome via repositorio apt oficial do Google
- Google Earth Pro via pacote `.deb` oficial do Google
- Instalador unico para Debian ja instalado: `scripts/instalar-no-debian.sh`
- Aplicador de visual do terminal: `saggeo-aplicar-terminal`

## Cloud, Segredos E APIs Externas

- `gcloud` via Google Cloud CLI oficial
- `op` via 1Password CLI oficial
- app desktop 1Password via repositorio apt oficial
- projeto GCP padrão: `saggeo-ecosystem-prod`
- região padrão: `us-central1`
- GCP Secret Manager como fonte para Cloud Run
- 1Password CLI como fonte para VMs e máquinas locais
- Foxit PDF Services documentado como dependência externa; credenciais ficam no 1Password, nunca na ISO
- SERPRO consulta-cpf-df/v1 documentado como dependência de runtime
- Google Maps Geocoding fica opcional, apenas fallback

## Observacoes De Seguranca

- A ISO nao embute tokens, service accounts, `.env` nem chaves.
- `op://` e Secret Manager sao configurados depois da instalacao, no ambiente real.
- O arquivo `/etc/1password/op.env`, quando usado em VM, deve ser criado manualmente com modo `0600`.
