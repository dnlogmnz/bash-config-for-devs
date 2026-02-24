#
# Script: ~/.config/bash/git-envs.sh
# Variaveis de ambiente para o Git CLI
# Ver: https://git-scm.com/book/en/v2/Git-Internals-Environment-Variables
# ==========================================================================================

# Garantir que o "gitconfig" será armazenado em diretório compatível com XDG / FHS
[ -d "$XDG_CONFIG_HOME" ] && mkdir -p "$XDG_CONFIG_HOME"/git

#-------------------------------------------------------------------------------------------
#--- Final do script ~/.config/'git-envs.sh'
#-------------------------------------------------------------------------------------------