#!/bin/bash
#
# Script: ~/.local/bin/helpers/uv-utils.sh
# Descrição: Funções utilitárias e helpers para scripts UV
# ==========================================================================================

# Source das funções de display (se disponível)
if [ -f "${HOME}/.config/bash/00-display-functions.sh" ]; then
    source "${HOME}/.config/bash/00-display-functions.sh"
fi

#-------------------------------------------------------------------------------------------
# HELPERS: Utilitários e Validações
#-------------------------------------------------------------------------------------------

# Helper para obter dados do Git (Nome e Email)
_utils_get_git_user() {
    local config_type="$1" # name ou email
    if [ "$config_type" == "name" ]; then
        git config user.name 2>/dev/null || echo "Usuario Desconhecido"
    elif [ "$config_type" == "email" ]; then
        git config user.email 2>/dev/null || echo "email@desconhecido.com"
    fi
}

# Helper para validação básica de entrada
_utils_validate_args() {
  if [ $# -eq 0 ]; then
    displayWarning "Uso" "${FUNCNAME[1]} <nome-do-projeto> [<versao-python>]"
    return 1
  fi
  return 0
}

#-------------------------------------------------------------------------------------------
# HELPERS: Orquestração
#-------------------------------------------------------------------------------------------

# Configura o ambiente de desenvolvimento comum a todos os projetos
# Recebe: $1=project_name, $2=python_version, $3=build_mode
_setup_common_env() {
    local project_name="$1"
    local python_version="${2:-$UV_PYTHON_MIN_VER}"
    local build_mode="$3"

    echo ""
    displayAction "Configurando padronização..."

    # 1. Ajustar pyproject.toml gerado pelo "uv init"
    ./helpers/uv-pyproject-toml.sh "$project_name" "$python_version" "$build_mode"

    # 2. Gerar configurações
    ./helpers/uv-dot-env.sh
    ./helpers/uv-ruff-toml.sh "$python_version"

    # 3. Instalar dependências de desenvolvimento universais
    echo ""
    displayAction "Instalando ferramentas de Dev (Ruff, Mypy, Pytest)..."
    uv add --dev ruff mypy pytest pytest-asyncio pytest-cov
}

#-------------------------------------------------------------------------------------------
#--- Final do script uv-utils.sh
#-------------------------------------------------------------------------------------------
