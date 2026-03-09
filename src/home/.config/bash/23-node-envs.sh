#
# Script: ~/.config/bash/node-envs.sh
# Variáveis de ambiente para o Node.js
# Dica: Algumas variáveis não são "oficiais", ou seja, não são parte da documentação
#       do Node.js e NPM, mas são usadas aqui seguindo práticas comuns da comunidade.
# ==========================================================================================

# Variáveis não oficiais para definir diretório onde estarão as versões do Node.js
export NODE_HOME="$APPS_BASE/nodejs"         # Todas as versões do Node.js instaladas
export NODE_CURRENT="$NODE_HOME/current"     # Link simbólico ou junction para a versão default

# Variáveis oficiais para configurações do NPM, com valores aderentes ao XDG
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"
export NPM_CONFIG_REGISTRY="https://registry.npmjs.org/"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"

# Variáveis oficiais para configurações do Node.js, com valores aderentes ao XDG
export NODE_REPL_HISTORY="$XDG_STATE_HOME/node_repl_history"

# Cria os diretórios para evitar erros de permissão ou inexistência
mkdir -p "$NODE_HOME" \
         "$(dirname "$NODE_REPL_HISTORY")" \
         "$NPM_CONFIG_CACHE" \
         "$(dirname "$NPM_CONFIG_USERCONFIG")"

# Continuação do comando acima
#         "$NPM_CONFIG_PREFIX" \

# Adicionar Node.js ao PATH
if [[ ":$PATH:" != *":$NODE_CURRENT:"* ]]; then
    displayFailure "Windows" "Variáveis de ambiente para sua conta: adicionar \"$(path2win "$NODE_CURRENT")\" ao PATH"
    export PATH="$NODE_CURRENT:$PATH"
fi

#-------------------------------------------------------------------------------------------
#--- Final do script node-envs.sh
#-------------------------------------------------------------------------------------------