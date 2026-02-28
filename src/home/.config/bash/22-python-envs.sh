#
# Script: ~/.config/bash/python-envs.sh
# Variáveis de ambiente para o Python
# ==========================================================================================

# Histórico de comandos digitados no intepretador python
mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/python"
export PYTHONHISTORY="${XDG_DATA_HOME:-$HOME/.local/share}/python/history"

# Configurações do interpretador Python
export PYTHONUNBUFFERED="1"         # Outputs (print, logs) direto ao terminal, sem uso de buffer
export PYTHONIOENCODING="utf-8"     # Logs com caracteres especiais sem quebrar o coletor de logs
export PYTHONDONTWRITEBYTECODE="1"  # Não cria arquivos .pyc (bytecode): acelera import de módulos

#-------------------------------------------------------------------------------------------
#--- Final do script ~/.config/python-envs.sh
#-------------------------------------------------------------------------------------------