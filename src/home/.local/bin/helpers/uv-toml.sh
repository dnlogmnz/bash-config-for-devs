#!/bin/bash
#
# Script: ~/.local/bin/helpers/uv-toml.sh
# Criar arquivo "uv.toml", caso ainda não existir
# ==========================================================================================

if [ -d "${UV_HOME}" ]; then

    # Define local do arquivo de configuração global do uv
    export UV_CONFIG_FILE="${UV_HOME}/uv.toml"
    
    # Ajusta valores das variaveis para formato do Windows
    UV_CONF_FILE="$(echo $UV_CONFIG_FILE | sed -e 's,^/d,D:,g' -e 's,/,\\,g')"
    UV_CACHE_DST="$(echo $UV_CACHE_DIR | sed -e 's,^/d,D:,g' -e 's,/,\\\\,g')"

    # Cria um novo arquivo, caso ainda não exitir
    if [ ! -r "$UV_CONFIG_FILE" ]; then
        TEMPLATE_FILE="$HOME/.config/templates/uv.toml.template"
        if [ ! -f "$TEMPLATE_FILE" ]; then
            displayFailure "Erro" "Template não encontrado: $TEMPLATE_FILE"
            exit 1
        fi

        sed \
            -e "s/{{UV_CONF_FILE}}/$UV_CONF_FILE/g" \
            -e "s/{{UV_CACHE_DST}}/$UV_CACHE_DST/g" \
            "$TEMPLATE_FILE" > "$UV_CONFIG_FILE"
    fi

    # Liberar variáveis de ambiente
    unset UV_CONF_FILE UV_CACHE_DST

fi

#-------------------------------------------------------------------------------------------
#--- Final do script uv-toml.sh
#-------------------------------------------------------------------------------------------
