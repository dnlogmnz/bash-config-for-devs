#!/bin/bash
#
# Script: ~/.local/bin/helpers/uv-ruff-toml.sh
# Descrição: Criar arquivo ruff.toml no diretório corrente com configurações de Linter & Formatter
# Uso: uv-ruff-toml.sh <python_version> [project_name]
# Argumentos:
#   $1: Versão Python (obrigatório, ex: 3.10, 3.11)
#   $2: Nome do projeto (opcional, detectado do pyproject.toml se não fornecido)
# ==========================================================================================

# Source das funções de display
if [ -f "${HOME}/.config/bash/00-display-functions.sh" ]; then
    source "${HOME}/.config/bash/00-display-functions.sh"
else
    # Fallback simples se funções de display não estiverem disponíveis
    displayAction() { echo ">>> $*"; }
    displayInfo() { echo "  - $1: ${2:+$2}"; }
    displayFailure() { echo "[FAILURE] $*"; }
    displayWarning() { echo "[WARNING] $*"; }
fi

# Validar argumentos
if [ -z "$1" ]; then
    displayFailure "Erro" "Uso: uv-ruff-toml.sh <python_version> [project_name]"
    exit 1
fi

# Verificar se está em um projeto (verificar existência de pyproject.toml)
if [ ! -f "pyproject.toml" ]; then
    displayWarning "Erro" "Arquivo 'pyproject.toml' não encontrado. Você está em um diretório de projeto?"
    exit 1
fi

# Verificar se ruff.toml já existe
if [ -f "ruff.toml" ]; then
    displayWarning "Aviso" "Arquivo ruff.toml já existe. Nenhuma ação foi realizada."
    exit 0
fi

python_version="$1"
project_name="${2:-$(basename "$(pwd)")}"
line_length="120"

displayAction "Criando arquivo ruff.toml com configurações de Linter & Formatter"
displayInfo "Target Python" "${python_version}"
displayInfo "Line Length" "$line_length"

TEMPLATE_FILE="$HOME/.config/templates/ruff.toml.template"
if [ ! -f "$TEMPLATE_FILE" ]; then
    displayFailure "Erro" "Template não encontrado: $TEMPLATE_FILE"
    exit 1
fi

# Substituir placeholders
sed \
    -e "s/{{PYTHON_VERSION}}/${python_version//./}/g" \
    -e "s/{{LINE_LENGTH}}/$line_length/g" \
    -e "s/{{PROJECT_NAME}}/$project_name/g" \
    "$TEMPLATE_FILE" > ruff.toml

displayAction "Arquivo ruff.toml criado com sucesso!"

#-------------------------------------------------------------------------------------------
#--- Final do script uv-ruff-toml.sh
#-------------------------------------------------------------------------------------------
