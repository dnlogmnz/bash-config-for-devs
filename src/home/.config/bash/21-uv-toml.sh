#
# Script: ~/.config/bash/uv-toml.sh
# Criar arquivo "uv.toml", caso ainda não existir
# ==========================================================================================

if [ -d "${UV_HOME}" ]; then

    # Define local do arquivo de configuração global do uv
    export UV_CONFIG_FILE="${UV_HOME}/uv.toml"
    
    # Ajusta valores das variaveis para formato do Windows
    UV_CONF_FILE="$(echo $UV_CONFIG_FILE | sed -e 's,^/d,D:,g' -e 's,/,\\,g')"
    UV_CACHE_DST="$(echo $UV_CACHE_DIR | sed -e 's,^/d,D:,g' -e 's,/,\\\\,g')"

    # Cria um novo arquivo, caso ainda não exitir
    [ -r "$UV_CONFIG_FILE" ] || cat >"$UV_CONFIG_FILE" << EOF
#
# Arquivo: $UV_CONF_FILE
# Configuração global do UV
# =============================================================================

# Configurações gerais
link-mode = "copy"
python-downloads = "manual"

# Diretórios
cache-dir = "$UV_CACHE_DST"
EOF

    # Liberar variáveis de ambiente
    unset UV_CONF_FILE UV_CACHE_DST

fi

#-------------------------------------------------------------------------------------------
#--- Final do script ~/.config/uv-toml.sh
#-------------------------------------------------------------------------------------------