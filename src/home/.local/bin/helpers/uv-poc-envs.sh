#!/bin/bash
#
# Script: ~/.local/bin/helpers/uv-poc-envs.sh
# Descrição: Criar estrutura de ambientes em ./envs/ para Proof of Concept
# Uso: uv-poc-envs.sh
# Cria: envs/prod-a.sh, envs/prod-b.sh, envs/prod-c.sh
# ==========================================================================================

# Source das funções de display
if [ -f "${HOME}/.config/bash/00-display-functions.sh" ]; then
    source "${HOME}/.config/bash/00-display-functions.sh"
else
    # Fallback simples se funções de display não estiverem disponíveis
    displayAction() { echo ">>> $*"; }
    displayInfo() { echo "  - $1: ${2:+$2}"; }
    displayWarning() { echo "[WARNING] $*"; }
fi

# Verificar se está em um projeto (verificar existência de pyproject.toml)
if [ ! -f "pyproject.toml" ]; then
    displayWarning "Erro" "Arquivo 'pyproject.toml' não encontrado. Você está em um diretório de projeto?"
    exit 1
fi

# Verificar se envs/ já existe
if [ -d "envs" ]; then
    displayWarning "Aviso" "Diretório envs/ já existe. Nenhuma ação foi realizada."
    exit 0
fi

displayAction "Criando estrutura de ambientes em ./envs/"
displayInfo "Ambientes" "prod-a, prod-b, prod-c"

TEMPLATE_FILE="$HOME/.config/templates/poc-env.template"
if [ ! -f "$TEMPLATE_FILE" ]; then
    displayFailure "Erro" "Template não encontrado: $TEMPLATE_FILE"
    exit 1
fi

mkdir -p envs
for product in prod-a prod-b prod-c; do
    sed "s/{{PRODUCT_NAME}}/${product}/g" "$TEMPLATE_FILE" > "./envs/${product}.sh"
done

displayAction "Estrutura de ambientes criada com sucesso!"

#-------------------------------------------------------------------------------------------
#--- Final do script uv-poc-envs.sh
#-------------------------------------------------------------------------------------------
