#!/bin/bash
#
# Script: ~/.local/bin/helpers/uv-pyproject-toml.sh
# Descrição: Criar arquivo pyproject.toml no diretório corrente
# Uso: uv-pyproject-toml.sh <project_name> [python_version] [build_mode]
# Argumentos:
#   $1: Nome do projeto (obrigatório)
#   $2: Versão Python (opcional, padrão 3.10)
#   $3: Modo de build: "simple" ou "package" (opcional, padrão package)
# ==========================================================================================

# Source das funções de display
if [ -f "${HOME}/.config/bash/00-display-functions.sh" ]; then
    source "${HOME}/.config/bash/00-display-functions.sh"
else
    displayAction()  { echo ">>> $*"; }
    displayInfo()    { echo "  - $1: ${2:+$2}"; }
    displayFailure() { echo "[FAILURE] $*"; }
    displayWarning() { echo "[WARNING] $*"; }
fi

# Source das funções helper
if [ -f "${HOME}/.local/bin/helpers/uv-utils.sh" ]; then
    source "${HOME}/.local/bin/helpers/uv-utils.sh"
fi

# Validar argumentos
if [ -z "$1" ]; then
    displayFailure "Erro" "Uso: uv-pyproject-toml.sh <project_name> [python_version] [build_mode]"
    exit 1
fi

# Verificar se está em um projeto (verificar existência de pyproject.toml)
if [ ! -f "pyproject.toml" ]; then
    displayWarning "Erro" "Arquivo 'pyproject.toml' não encontrado. Você está em um diretório de projeto?"
    exit 1
fi

project_name="$1"
python_version="${2:-3.10}"
build_mode="${3:-package}"
author_name=$(_utils_get_git_user "name")
author_email=$(_utils_get_git_user "email")

displayAction "Criando arquivo pyproject.toml (modo $build_mode)"
displayInfo "Projeto" "$project_name"
displayInfo "Python" ">=$python_version"
displayInfo "Autor" "$author_name <$author_email>"

TEMPLATE_FILE="$HOME/.config/templates/pyproject.toml.template"
if [ ! -f "$TEMPLATE_FILE" ]; then
    displayFailure "Erro" "Template não encontrado: $TEMPLATE_FILE"
    exit 1
fi

# Substituir placeholders e criar arquivo
sed \
    -e "s/{{PROJECT_NAME}}/$project_name/g" \
    -e "s/{{PYTHON_VERSION}}/$python_version/g" \
    -e "s/{{AUTHOR_NAME}}/$author_name/g" \
    -e "s/{{AUTHOR_EMAIL}}/$author_email/g" \
    "$TEMPLATE_FILE" > pyproject.toml

# Adicionar seção build-system se necessário
if [ "$build_mode" == "package" ]; then
    cat >> pyproject.toml << 'EOF'

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"
EOF
fi

displayAction "Arquivo pyproject.toml criado com sucesso!"

#-------------------------------------------------------------------------------------------
#--- Final do script uv-pyproject-toml.sh
#-------------------------------------------------------------------------------------------
