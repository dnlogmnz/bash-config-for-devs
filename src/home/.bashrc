#
# Script: ~/.bashrc
# Executado por shells interativos.
# Define variáveis e carrega os scripts rc.
# =============================================================================

# Configurações de locale
export LANG=pt_BR.UTF-8
export LC_ALL=pt_BR.UTF-8

# Padrão FHS (Filesystem Hierarchy Standard) / XDG (X Desktop Group)
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# Carga (source) dos scripts de inicialização do shell (run command files)
if [ -d $XDG_CONFIG_HOME/bash ]; then
    for rc in $XDG_CONFIG_HOME/bash/*.sh; do
        [ -f "$rc" ] && source "$rc"
    done
fi

# Limpa a variável rc do escopo global
unset rc local_bin

#--------------------------------------------------------------------------------
#--- Final do script ~/.bashrc
#--------------------------------------------------------------------------------