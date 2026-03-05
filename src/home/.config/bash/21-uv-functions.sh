#
# Script: ~/.config/bash/uv-functions.sh
# Funções para facilitar o uso do UV (Python Package Manager)
# ==========================================================================================

#-------------------------------------------------------------------------------------------
# HELPERS: Utilitários e Validações
#-------------------------------------------------------------------------------------------

# Helper para obter dados do Git (Nome e Email)
_utils_get_git_user() {
    local config_type="$1" # name ou email
    if [ "$config_type" == "name" ]; then
        git config user.name || echo "Usuario Desconhecido"
    elif [ "$config_type" == "email" ]; then
        git config user.email || echo "email@desconhecido.com"
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
# HELPERS: Geradores de Arquivos de Configuração
#-------------------------------------------------------------------------------------------

# Helper para criar o .env padrão
_gen_dot_env() {
    displayInfo "Arquivo .env:" "Template de variáveis de ambiente"
    [ -r .env ] || cat > .env << EOF
# Este arquivo possui secrets, manter sempre no .gitignore para que não seja enviado ao repositório

# secrets:
# API_KEY="xxx"

#configmap:

# Biblioteca 'logger' - definir o nível de detalhe nos logs
LOG_LEVEL="INFO"

GLOBAL_TIMEOUT="30"
EOF
}

# Helper para criar o pyproject.toml
# Recebe: $1=project_name, $2=python_version, $3=build_mode ("simple" ou "package")
_gen_pyproject_toml() {
    local project_name="$1"
    local python_version="$2"
    local build_mode="$3"
    local author_name=$(_utils_get_git_user "name")
    local author_email=$(_utils_get_git_user "email")

    displayInfo "Arquivo pyproject.toml" "Modo '$build_mode'"

    # Cabeçalho comum
    cat > pyproject.toml << EOF
[project]
name = "$project_name"
version = "0.1.0"
description = "Projeto $project_name"
readme = "README.md"
requires-python = ">=${python_version}"
authors = [
    { name = "${author_name}", email = "${author_email}" }
]
dependencies = []
EOF

    # Se for modo package (Lib, Backend), adiciona sistema de build
    if [ "$build_mode" == "package" ]; then
        cat >> pyproject.toml << EOF

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"
EOF
    fi
}

# Helper para criar o ruff.toml com comentários explicativos
_gen_ruff_toml() {
    local python_version="$1"
    local line_length="120"

    displayInfo "Arquivo ruff.toml" "Linter & Formatter"

    cat > ruff.toml << EOF
# Configurações globais
line-length = $line_length
target-version = "py${python_version//./}"

[lint]
select = [
    "E",      # pycodestyle errors
    "F",      # Pyflakes
    "I",      # isort (ordenação de imports)
    "N",      # pep8-naming (convenções de nomenclatura)
    "UP",     # pyupgrade (modernização de código)
    "B",      # flake8-bugbear (bugs comuns)
    "C4",     # flake8-comprehensions (otimização de comprehensions)
    "DTZ",    # flake8-datetimez (uso correto de timezone)
    "T10",    # flake8-debugger (detecta debugger statements)
    "EM",     # flake8-errmsg (mensagens de erro consistentes)
    "ISC",    # flake8-implicit-str-concat (concatenação implícita)
    "ICN",    # flake8-import-conventions (convenções de import)
    "PIE",    # flake8-pie (melhorias diversas)
    "PT",     # flake8-pytest-style (boas práticas pytest)
    "Q",      # flake8-quotes (consistência de aspas)
    "RSE",    # flake8-raise (uso correto de raise)
    "RET",    # flake8-return (otimização de returns)
    "SIM",    # flake8-simplify (simplificação de código)
    "TID",    # flake8-tidy-imports (imports organizados)
    "ARG",    # flake8-unused-arguments (argumentos não utilizados)
    "PTH",    # flake8-use-pathlib (uso de pathlib)
    "ERA",    # eradicate (código comentado)
    "PL",     # Pylint
    "TRY",    # tryceratops (boas práticas de exceções)
    "RUF",    # Ruff-specific rules
]

ignore = [      # Regras ignoradas (com justificativa)
    "TRY003",   # Permite mensagens longas em exceções (comum em APIs)
    "PLR0913",  # Permite mais de 5 argumentos em funções (comum em injeção de dependência)
    "B008",     # Permite function calls em argumentos default (necessário para Depends() do FastAPI)
]

[lint.per-file-ignores]
"__init__.py" = [
    "F401",     # Permite imports não utilizados em __init__.py (comum para re-exportação de símbolos)
]
"tests/**/*.py" = [
    "ARG001",   # Detecta argumentos de função que foram declarados mas nunca utilizados no corpo da função
    "ARG002"    # Detecta argumentos de método (funções dentro de Classes) que foram declarados mas nunca utilizados
]

[lint.isort]
known-first-party = ["${project_name}"]
force-sort-within-sections = true         # Forçar ordenação alfabética dentro de cada seção
combine-as-imports = true                 # Combinar imports do mesmo módulo
section-order = [        # Ordem das seções de imports
    "future",            # Imports de __future__            - p.ex: from __future__ import annotations
    "standard-library",  # Biblioteca padrão do Python      - p.ex: import os, sys, datetime
    "third-party",       # Pacotes de terceiros instalados  - p.ex: from fastapi import FastAPI
    "first-party",       # Módulos do próprio projeto       - p.ex: from ${project_name}.models import User
    "local-folder",      # Imports relativos locais         - p.ex: from .utils import helper
]

[lint.pydocstyle]
convention = "google"

[lint.pylint]
max-args = 7  # Ajustado para injeção de dependência

# Configurações de formatação
[format]
docstring-code-line-length = $line_length
quote-style = "double"             # Usa aspas duplas (convenção padrão Python moderna)
indent-style = "space"             # Usa espaços para indentação (padrão PEP8)
skip-magic-trailing-comma = false  # Evita remover a vírgula final em listas multilinhas (melhora diffs no git)
line-ending = "auto"               # Detecta automaticamente se deve usar LF (Linux) ou CRLF (Windows)
docstring-code-format = true       # Formata exemplos de código dentro de docstrings
EOF
}

# Helper específico para criar a estrutura de pastas da PoC
_gen_poc_envs_folder() {
    # Usando displayInfo para manter o alinhamento com a geração de outros arquivos/pastas
    displayInfo "Diretório" "./envs/ (Estrutura de ambientes)"

    mkdir -p envs
    for product in prod-a prod-b prod-c; do
        cat > "./envs/${product}.sh" << EOF
# Configuração para: ${product%.env}
API_BASE_URL="https://api.${product%.env}.com"
API_KEY="insira-aqui-a-api-key"
PING_RESOURCE="/ping"
PING_EXPECTED_STATUS="200"
EOF
    done
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
    _gen_pyproject_toml "$project_name" "$python_version" "$build_mode"

    # 2. Gerar configurações
    _gen_dot_env
    _gen_ruff_toml "$python_version"

    # 3. Instalar dependências de desenvolvimento universais
    echo ""
    displayAction "Instalando ferramentas de Dev (Ruff, Mypy, Pytest)..."
    uv add --dev ruff mypy pytest pytest-asyncio pytest-cov
}

#-------------------------------------------------------------------------------------------
# FUNÇÕES PÚBLICAS
#-------------------------------------------------------------------------------------------

uv-info() {
    echo ""
    displayAction "Informações do UV"
    displayInfo "Versão" "$(uv --version 2>/dev/null || echo 'Não encontrado')"
    displayInfo "Python" "${UV_PYTHON_INSTALL_DIR:-Não configurado}"
    displayInfo "Cache" "${UV_CACHE_DIR:-Não configurado}"

    echo ""
    displayAction "Informações do Python"
    uv python list --only-installed 2>/dev/null || displayWarning "Aviso" "Nenhuma versão instalada"
}

# 1. Criação de PoC (Proof of Concept)
# Foco: Estrutura simples (--app), múltiplos environments, bibliotecas de teste de API.
uv-new-poc() {
    _utils_validate_args "$@" || return 1
    local project_name="$1"
    local python_version="${2:-$UV_PYTHON_MIN_VER}"
    displayTitle "python version" "$python_version"
    displayTitle "python min version" "$UV_PYTHON_MIN_VER"

    displayAction "Iniciando PoC: $project_name (Python $python_version)"

    # Inicializa estrutura plana
    uv init --app --python "$python_version" "$project_name"
    cd "$project_name" || return

    # Configura base (Modo simple = sem build system)
    _setup_common_env "$project_name" "$python_version" "simple"

    # Dependências específicas de PoC
    echo ""
    displayAction "Instalando libs de Runtime (Httpx, Pydantic-Settings)..."
    uv add httpx pydantic-settings

    # Cria pasta de envs
    _gen_poc_envs_folder

    echo ""
    displaySuccess "Concluído" "PoC criada com sucesso!"

    echo ""
    displayAction "A seguir" "Acesse a pasta e rode o projeto:"
    echo "   cd $project_name && uv run main.py"
}

# 2. Criação de Aplicação Simples (Scripts/Notebooks)
# Foco: Estrutura simples (--app), uso geral.
uv-new-app() {
  _utils_validate_args "$@" || return 1
  local project_name="$1"
  local python_version="${2:-$UV_PYTHON_MIN_VER}"

  displayAction "Iniciando Backend/App Estruturada: $project_name"

  # Inicializa como aplicação empacotada (src layout + app)
  uv init --app --package --python "$python_version" "$project_name"
  cd "$project_name" || return

  # Configura base (Modo package = com build system hatchling)
  _setup_common_env "$project_name" "$python_version" "package"

  echo ""
  displaySuccess "Concluído" "Backend inicializado em ./src/$project_name!"
}


# 3. Criação de Backend Profissional (API/CLI)
# Foco: Estrutura src/ (--app --package), build system configurado, pronto para crescer.

uv-new-backend() {
    _utils_validate_args "$@" || return 1
    local project_name="$1"
    local python_version="${2:-$UV_PYTHON_MIN_VER}"

    displayAction "Iniciando Backend/App Estruturada: $project_name"

    # Inicializa como aplicação empacotada (src layout + app)
    uv init --app --package --python "$python_version" "$project_name"
    cd "$project_name" || return

    # Configura base (Modo package = com build system hatchling)
    _setup_common_env "$project_name" "$python_version" "package"

    # Backend geralmente precisa de libs robustas, mas deixamos limpo para escolha do dev
    # (Poderíamos adicionar fastapi uvicorn aqui se fosse um template específico)

    echo ""
    displaySuccess "Concluído" "Backend inicializado em ./src/$project_name!"
}


# 4. Criação de Biblioteca (Library)
# Foco: Estrutura src/ (--lib), preparada para distribuição (PyPI).
uv-new-lib() {
  _utils_validate_args "$@" || return 1
  local project_name="$1"
  local python_version="${2:-$UV_PYTHON_MIN_VER}"

  displayAction "Iniciando Biblioteca Reutilizável: $project_name"

  # Inicializa como biblioteca
  uv init --lib --python "$python_version" "$project_name"
  cd "$project_name" || return

  # Configura base (Modo package)
  _setup_common_env "$project_name" "$python_version" "package"

  echo ""
  displaySuccess "Concluído" "Biblioteca criada com estrutura src/!"
}

# Mantida para compatibilidade (alias para uv-new-app)
uv-new-project() {
    uv-new-app "$@"
}

#-------------------------------------------------------------------------------------------
#--- Final do script uv-functions.sh
#-------------------------------------------------------------------------------------------