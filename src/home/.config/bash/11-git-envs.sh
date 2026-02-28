#
# Script: ~/.config/bash/git-envs.sh
# Variaveis de ambiente para o Git CLI
# Ver: https://git-scm.com/book/en/v2/Git-Internals-Environment-Variables
# ==========================================================================================

# Garante que o "gitconfig" será armazenado em diretório compatível com XDG / FHS
[ -d "$XDG_CONFIG_HOME" ] && mkdir -p "$XDG_CONFIG_HOME"/git

# Define o local do arquivo de configuração global seguindo o XDG
export GIT_CONFIG_GLOBAL="$XDG_CONFIG_HOME/git/config"

#-------------------------------------------------------------------------------------------
#--- Final do script ~/.config/git-envs.sh
#-------------------------------------------------------------------------------------------