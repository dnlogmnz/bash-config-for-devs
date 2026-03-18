#!/bin/bash
#
# Script: ~/.local/bin/helpers/node-current.sh
# Descrição: Funções para detecção e exibição da versão atual do Node.js
# ==========================================================================================

# Source das funções de display
if [ -f "${HOME}/.config/bash/00-display-functions.sh" ]; then
    source "${HOME}/.config/bash/00-display-functions.sh"
else
    displayAction() { echo ">>> $*"; }
    displayInfo()   { echo "  - $1: ${2:+$2}"; }
fi

#-------------------------------------------------------------------------------------------
# HELPER: Resolve qual versão está ativa via junction "current"
#-------------------------------------------------------------------------------------------
_get_node_current_version() {
    # No Git Bash, junctions criadas com mklink /J aparecem como symlinks para o readlink.
    if [ -L "$NODE_CURRENT" ]; then
        basename "$(readlink "$NODE_CURRENT")"   # retorna ex: "v22.14.0"
    elif [ -d "$NODE_CURRENT" ]; then
        # Junction criada externamente: pergunta ao próprio executável
        node.exe --version 2>/dev/null || echo ""
    else
        echo ""
    fi
}

#-------------------------------------------------------------------------------------------
# HELPER: Apresenta informações sobre a versão default do Node.js
#-------------------------------------------------------------------------------------------
_node_current_version() {
    displayAction "Informações sobre a versão default para o ambiente"
    local current_version
    current_version=$(_get_node_current_version)
    displayInfo "Versão ativa" "${current_version:-Nenhuma (junction inexistente ou inválida)}"
    displayInfo "node --version" "$(node.exe --version 2>/dev/null || echo 'Não encontrado no PATH')"
    displayInfo "npm --version"  "$(npm.cmd --version  2>/dev/null || echo 'Não encontrado no PATH')"
}

#-------------------------------------------------------------------------------------------
#--- Final do script node-current.sh
#-------------------------------------------------------------------------------------------
