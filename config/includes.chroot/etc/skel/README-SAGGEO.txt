Debian SAGGEO completo

Este sistema foi gerado pelo repositório debian-pendrive-completo.

Depois de instalar no computador, rode:

  sudo saggeo-pos-instalacao

Esse comando atualiza pacotes, habilita NetworkManager e garante que ferramentas
base de desenvolvimento estejam instaladas.

Para instalar Codex, Claude Code e aplicar dotfiles:

  saggeo-instalar-agentes

Para instalar Google Cloud CLI e 1Password CLI:

  saggeo-instalar-cloud-tools

O repositório de dotfiles/configuracao usado como padrao e:

  git@github.com:iagoguilherme/mac-bootstrap.git

Credenciais nao sao gravadas na ISO. Para VMs, o padrao do ecossistema e criar
o arquivo /etc/1password/op.env manualmente com modo 0600 ou recuperar o token
por Secret Manager, conforme o ambiente permitir.
