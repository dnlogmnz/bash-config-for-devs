#!/bin/bash
#
# Script: ~/.local/bin/helpers/node-version.sh
# Descrição: Funções utilitárias para parsing e normalização de versões Node.js
# ==========================================================================================

#-------------------------------------------------------------------------------------------
# HELPER: Normaliza string de versão para o formato canonical vXX.YY.zz
#-------------------------------------------------------------------------------------------
_node_normalize_version() {
    local input="$1"
    # remover prefixo "v" ou "V" se presente
    local ver="${input#v}"
    ver="${ver#V}"

    IFS='.' read -r major minor patch <<< "$ver"
    major=${major:-0}
    minor=${minor:-0}
    patch=${patch:-0}
    printf "v%s.%s.%s" "$major" "$minor" "$patch"
}

#-------------------------------------------------------------------------------------------
# HELPER: Gera um prefixo a partir da versão informada para pesquisa de diretórios
#-------------------------------------------------------------------------------------------
_node_version_prefix() {
    local norm
    norm=$(_node_normalize_version "$1")
    # remover sequências de ".0" no fim para obter o prefixo desejado
    echo "$norm" | sed -E 's/(\.0)+$//'
}

#-------------------------------------------------------------------------------------------
# HELPER: Lista todas as versões instaladas em $NODE_HOME
# Consolidação: evita duplicação de pattern de listagem usado em node-list e node-default
#-------------------------------------------------------------------------------------------
_node_list_versions() {
    /bin/ls -1 "$NODE_HOME" 2>/dev/null | grep "^v[0-9]" | sort -V
}

#-------------------------------------------------------------------------------------------
#--- Final do script node-version.sh
#-------------------------------------------------------------------------------------------
