#
# Projeto: bashrc-for-devs
#
# Script: ~/.config/bashrc/python-envs.sh
# Objetivo: definir variáveis de ambiente para o Python
# =============================================================================================

#
# NOTA IMPORTANTE sobre instalação do Python neste computador:
# - Python é gerenciado exclusivamente pelo uv neste computador.
# - Não instale Python diretamente (python.org, winget, chocolatey, etc.).
# - Use `uv python install` para instalar versões e `uv tool install` para ferramentas globais.
# =============================================================================================

# Histórico de comandos digitados no intepretador python
export PYTHONHISTORY="${XDG_STATE_HOME:-$HOME/.local/state}/python/history"
[ -d "${PYTHONHISTORY%/*}" ] || mkdir -p "${PYTHONHISTORY%/*}"

# Configurações do interpretador Python
export PYTHONUNBUFFERED="1"         # Outputs (print, logs) direto ao terminal, sem uso de buffer
export PYTHONIOENCODING="utf-8"     # Logs com caracteres especiais sem quebrar o coletor de logs
export PYTHONDONTWRITEBYTECODE="1"  # Não cria arquivos .pyc (bytecode): acelera import de módulos

# Configurações do prompt do Virtualenv (afeta PS1 definido em "bashrc-envs.sh")
export VIRTUAL_ENV_DISABLE_PROMPT=1

#----------------------------------------------------------------------------------------------
#--- Final do script python-envs.sh
#----------------------------------------------------------------------------------------------