#
# Script: ~/.config/bash/uv-envs.sh
# Variaveis de ambiente para o UV (Python Package Manager)
# ==========================================================================================

# Extra: versão mínima de Python a ser usada pelo "uv add"
export UV_PYTHON_MIN_VER="3.14"

# Diretórios e arquivos do Python grenciado pelo UV
export UV_PYTHON_INSTALL_DIR="${APPS_BASE}/Python"       # diretóro contendo as diferentes versões do Python
export UV_PYTHON_BIN_DIR="${UV_PYTHON_INSTALL_DIR}/bin"  # shims do Python: links para os executáveis do Python

# Diretórios e arquivos do UV
export UV_HOME="${UV_PYTHON_INSTALL_DIR}/uv"   # diretório base do uv
export UV_INSTALL_DIR="${UV_HOME}/bin"         # binários: uv.exe, uvw.exe, uvx.exe
export UV_CACHE_DIR="${UV_HOME}/cache"         # cache das packages python
export UV_TOOL_DIR="${UV_HOME}/tools"          # ferramentas do uv: ruff, black, etc

# Configurações do UV
# export UV_PYTHON="3.14"                        # versão padrão do Python para todos os projetos
export UV_LINK_MODE="copy"                     # define como o UV deve tratar links simbólicos
export UV_PYTHON_INSTALL_REGISTRY="1"          # registrar as instalações do Python no Windows Registry
export UV_PYTHON_DOWNLOADS="manual"            # desabilitar os downloads automáticos do Python pelo uv
export UV_NATIVE_TLS="1"                       # usar os certificados do Windows (SChannel)

# Habilitar o autocompletion para comandos uv e uvx
# if [ -r "${UV_INSTALL_DIR}/uv" ]; then
#     echo 'eval "$(uv generate-shell-completion bash)"' 1> /tmp/uv-autocompletion.sh 2>/dev/null
#     echo 'eval "$(uvx --generate-shell-completion bash)"' 1>> /tmp/uv-autocompletion.sh 2>/dev/null
#     source /tmp/uv-autocompletion.sh
#     rm -f /tmp/uv-autocompletion.sh
# fi

#-------------------------------------------------------------------------------------------
#--- Final do script uv-envs.sh
#-------------------------------------------------------------------------------------------