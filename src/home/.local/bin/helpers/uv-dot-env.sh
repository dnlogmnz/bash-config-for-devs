#!/bin/bash
#
# Script: ~/.local/bin/helpers/uv-dot-env.sh
# Descrição: Criar arquivo .env no diretório corrente com template de variáveis de ambiente
# Uso: uv-dot-env.sh
# Nota: Detecta automaticamente se está em um projeto (busca por pyproject.toml)
# ==========================================================================================

# Source das funções de display
if [ -f "${HOME}/.config/bash/00-display-functions.sh" ]; then
    source "${HOME}/.config/bash/00-display-functions.sh"
else
    # Fallback simples se funções de display não estiverem disponíveis
    displayAction() { echo ">>> $*"; }
    displayWarning() { echo "[WARNING] $*"; }
fi

# Validar se está em um projeto (verificar existência de pyproject.toml)
if [ ! -f "pyproject.toml" ]; then
    displayWarning "Erro" "Arquivo 'pyproject.toml' não encontrado. Você está em um diretório de projeto?"
    exit 1
fi

# Verificar se .env já existe
if [ -f ".env" ]; then
    displayWarning "Aviso" "Arquivo .env já existe. Nenhuma ação foi realizada."
    exit 0
fi

# Criar .env com template
displayAction "Criando arquivo .env com template de variáveis de ambiente"

TEMPLATE_FILE="$HOME/.config/templates/dot-env.template"
if [ ! -f "$TEMPLATE_FILE" ]; then
    displayFailure "Erro" "Template não encontrado: $TEMPLATE_FILE"
    exit 1
fi

cat "$TEMPLATE_FILE" > .env

displayAction "Arquivo .env criado com sucesso!"

#-------------------------------------------------------------------------------------------
#--- Final do script uv-dot-env.sh
#-------------------------------------------------------------------------------------------
