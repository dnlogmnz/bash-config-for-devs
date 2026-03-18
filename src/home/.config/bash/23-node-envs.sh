#
# Script: ~/.config/bash/node-envs.sh
# Variáveis de ambiente para o Node.js
# Dica: Algumas variáveis não são "oficiais", ou seja, não são parte da documentação
#       do Node.js e NPM, mas são usadas aqui seguindo práticas comuns da comunidade.
# ==========================================================================================
#
# NOTA IMPORTANTE sobre NPM_CONFIG_PREFIX e isolamento por versão:
# =============================================================================
# Os pacotes npm instalados globalmente (`npm install -g`) frequentemente contêm binários
# nativos compilados especificamente para a versão do Node.js/npm usada na instalação.
# Diferentes versões do Node.js (v20, v22, v24, etc.) podem produzir binários incompatíveis.
#
# Por isso, NPM_CONFIG_PREFIX aponta para $NODE_CURRENT/npm-global (isolado por versão),
# e não para uma pasta centralizada. Isto significa:
#
#   - Ao trocar de versão com node-default(), o NODE_CURRENT muda
#   - NPM_CONFIG_PREFIX automaticamente aponta para a pasta npm-global daquela versão
#   - Cada versão do Node.js mantém seus próprios pacotes npm globais isolados
#
# Exemplos:
#   $APPS_BASE/nodejs/v20.20.1/npm-global/   ← Pacotes globais para v20.20.1
#   $APPS_BASE/nodejs/v22.x.x/npm-global/    ← Pacotes globais para v22
#   $APPS_BASE/nodejs/v24.14.0/npm-global/   ← Pacotes globais para v24.14.0
#
# ==========================================================================================

# Variáveis não oficiais para definir diretório onde estarão as versões do Node.js
export NODE_HOME="$APPS_BASE/nodejs"         # Todas as versões do Node.js instaladas
export NODE_CURRENT="$NODE_HOME/current"     # Link simbólico ou junction para a versão default

# Variáveis oficiais para configurações do NPM, com valores aderentes ao XDG
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"           # Cache de pacotes (compartilhado)
export NPM_CONFIG_TMP="$XDG_CACHE_HOME/npm/tmp"         # Diretório temporário (compartilhado)
export NPM_CONFIG_LOGS_DIR="$XDG_STATE_HOME/npm"        # Diretório de logs (compartilhado)
export NPM_CONFIG_PREFIX="$NODE_CURRENT/npm-global"     # Instalação global de pacotes (isolado por versão)
export NPM_CONFIG_REGISTRY="https://registry.npmjs.org/"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"

# Variáveis oficiais para configurações do Node.js, com valores aderentes ao XDG
export NODE_REPL_HISTORY="$XDG_STATE_HOME/node_repl_history"

# Adicionar Node.js ao PATH
if [[ ":$PATH:" != *":$NODE_CURRENT:"* ]]; then
    displayFailure "Windows" "Variáveis de ambiente para sua conta: adicionar \"$(command path2win "$NODE_CURRENT")\" ao PATH"
    export PATH="$NODE_CURRENT:$PATH"
fi

#-------------------------------------------------------------------------------------------
#--- Final do script node-envs.sh
#-------------------------------------------------------------------------------------------