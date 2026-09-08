#
# Projeto: bashrc-for-devs
#
# Script: ~/.bashrc
# Descrição: Define variáveis XDG e carrega os scripts rc em shells interativos.
# =============================================================================================
#
# NOTA IMPORTANTE:
# Este script assume que as seguintes variáveis podem ter sido definidas no aplicativo
# "Editar varíaveis de ambiente para sua conta" do Windows:
#   - XDG_BIN_HOME
#   - XDG_CACHE_HOME
#   - XDG_CONFIG_HOME
#   - XDG_DATA_HOME
#   - XDG_STATE_HOME
# =============================================================================================

# Define defaults para variáveis XDG considerando o caso em que já possam ter sido definidas no ambiente.
_xdg_bin="${XDG_BIN_HOME:-$HOME/.local/bin}"
_xdg_cache="${XDG_CACHE_HOME:-$HOME/.cache}"
_xdg_config="${XDG_CONFIG_HOME:-$HOME/.config}"
_xdg_data="${XDG_DATA_HOME:-$HOME/.local/share}"
_xdg_state="${XDG_STATE_HOME:-$HOME/.local/state}"

# Ajusta os caminhos das variáveis XDG para formato Linux/Unix.
# Evita fork do "cygpath" se variáveis já estiverem no formato esperado.
if [[
     "$_xdg_bin"    == [A-Za-z]:* || "$_xdg_cache" == [A-Za-z]:* || \
     "$_xdg_config" == [A-Za-z]:* || "$_xdg_data"  == [A-Za-z]:* || \
     "$_xdg_state"  == [A-Za-z]:*
   ]]
then
    mapfile -t _xdg < <(cygpath -u "$_xdg_bin" "$_xdg_cache" "$_xdg_config" "$_xdg_data" "$_xdg_state")
    _xdg_bin="${_xdg[0]}"; _xdg_cache="${_xdg[1]}"; _xdg_config="${_xdg[2]}"; _xdg_data="${_xdg[3]}"; _xdg_state="${_xdg[4]}"
fi

# Define as variáveis de diretórios padrão XDG (X Desktop Group)
export \
    XDG_BIN_HOME="$_xdg_bin" \
    XDG_CACHE_HOME="$_xdg_cache" \
    XDG_CONFIG_HOME="$_xdg_config" \
    XDG_DATA_HOME="$_xdg_data" \
    XDG_STATE_HOME="$_xdg_state"

# Garante que a estrutura de pastas existe (evitar erro "File not found")
if [ ! -d "$XDG_BIN_HOME" ]     || [ ! -d "$XDG_CACHE_HOME" ] || \
   [ ! -d "$XDG_CONFIG_HOME" ] || [ ! -d "$XDG_DATA_HOME" ]  || \
   [ ! -d "$XDG_STATE_HOME" ]
then
    mkdir -p \
        "$XDG_BIN_HOME" "$XDG_CACHE_HOME" \
        "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" \
        "$XDG_STATE_HOME"
fi

# Carrega primeiro os scripts com definições usadas pelos demais scripts rc
source "$XDG_CONFIG_HOME/bashrc/bash-envs.sh"
source "$XDG_CONFIG_HOME/bashrc/bash-functions.sh"

# Carrega os demais scripts rc *ordem alfabética), pulando os que são carregados explicitamente
for rc in "$XDG_CONFIG_HOME"/bashrc/*.sh; do
    case "$rc" in
        */bash-envs.sh | */bash-functions.sh | */bash-junctions.sh) continue ;;
    esac
    source "$rc"
done

# Carrega por último o que depender de definições feitas pelos scripts anteriores
source "$XDG_CONFIG_HOME/bashrc/bash-junctions.sh"

# Limpa variáveis do escopo global
unset rc _xdg _xdg_bin _xdg_cache _xdg_config _xdg_data _xdg_state

#----------------------------------------------------------------------------------------------
#--- Final do script ~/.bashrc
#----------------------------------------------------------------------------------------------