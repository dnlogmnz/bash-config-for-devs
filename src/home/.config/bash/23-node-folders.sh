#
# Script: ~/.config/bash/node-folders.sh
# Variáveis de ambiente para o Node.js
# ==========================================================================================

# Cria os diretórios para evitar erros de permissão ou inexistência
mkdir -p "$NODE_HOME" \
         "$NPM_CONFIG_CACHE" \
         "$(dirname "$NODE_REPL_HISTORY")" \
         "$(dirname "$NPM_CONFIG_USERCONFIG")"

# Adicionar Node.js ao PATH
if [[ ":$PATH:" != *":$NODE_CURRENT:"* ]]; then
    displayFailure "Windows" "Variáveis de ambiente para sua conta: adicionar \"$(path2win "$NODE_CURRENT")\" ao PATH"
    export PATH="$NODE_CURRENT:$PATH"
fi

#-------------------------------------------------------------------------------------------
#--- Final do script node-folders.sh
#-------------------------------------------------------------------------------------------