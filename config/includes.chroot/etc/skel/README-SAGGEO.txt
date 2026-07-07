Debian SAGGEO completo

Este sistema foi gerado pelo repositório debian-pendrive-completo.

No primeiro login do usuario instalado, um terminal Saggeo abre automaticamente
com os proximos passos. Se ele nao abrir, procure no menu:

  Saggeo Pos-instalacao

Ou rode manualmente:

  sudo saggeo-pos-instalacao

Esse comando atualiza pacotes, habilita NetworkManager e garante que ferramentas
base de desenvolvimento estejam instaladas.

Para instalar Codex, Claude Code e aplicar dotfiles:

  saggeo-instalar-agentes

Para instalar leitor PDF, VLC, VSCodium, Google Chrome e Google Earth Pro:

  saggeo-instalar-apps-desktop

Para aplicar o visual Ghostty/Clear Dark no GNOME Terminal:

  saggeo-aplicar-terminal

Para criar um venv Python pronto no projeto atual:

  saggeo-python-venv

Para instalar Google Cloud CLI, 1Password CLI e app 1Password:

  saggeo-instalar-cloud-tools

O repositório de dotfiles/configuracao usado como padrao e:

  git@github.com:iagoguilherme/mac-bootstrap.git

Credenciais nao sao gravadas na ISO. Para VMs, o padrao do ecossistema e criar
o arquivo /etc/1password/op.env manualmente com modo 0600 ou recuperar o token
por Secret Manager, conforme o ambiente permitir.
