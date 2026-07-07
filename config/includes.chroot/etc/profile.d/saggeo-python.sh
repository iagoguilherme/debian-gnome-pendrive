# Ambiente Python padrao do Debian SAGGEO.

export PYTHONUTF8=1
export PYTHONIOENCODING=UTF-8
export PIP_DISABLE_PIP_VERSION_CHECK=1
export PIPX_HOME="${PIPX_HOME:-${HOME}/.local/pipx}"
export PIPX_BIN_DIR="${PIPX_BIN_DIR:-${HOME}/.local/bin}"

case ":${PATH}:" in
  *":${HOME}/.local/bin:"*) ;;
  *) export PATH="${HOME}/.local/bin:${PATH}" ;;
esac
