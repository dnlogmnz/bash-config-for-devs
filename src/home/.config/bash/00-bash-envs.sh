#
# Script: ~/.config/bash/bash-envs.sh
# Aliases e variáveis de ambiente para o Git Bash
# ==========================================================================================

# Aliases para facilitar o uso do Git Bash
alias ll="/usr/bin/ls -l --color=auto --show-control-chars"
alias la="/usr/bin/ls -lA --color=auto --show-control-chars"
alias grep="/usr/bin/grep --color=auto"
alias npp='/usr/bin/start /d/$USERNAME/Apps/Notepad++/notepad++.exe "$@"'

# Diretório base para aplicações e ferramentas.
export APPS_BASE="/d/${USERNAME}/Apps"

# Variáveis "LINHA" e "TRACO"
LINHA="$(for i in `seq 1 $COLUMNS`; do echo -n "="; done)"
TRACO="$(for i in `seq 1 $COLUMNS`; do echo -n "-"; done)"

# Garantir que a estrutura de pastas existe (essencial para não dar erro de "File not found")
mkdir -p "$XDG_CONFIG_HOME"/vim
mkdir -p "$XDG_STATE_HOME"/{bash,less,vim}
mkdir -p "$XDG_DATA_HOME"

# Configurações de histórico de comandos no bash
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoredups:erasedups
export HISTFILE="$XDG_STATE_HOME/bash/history"

# Configurações para aplicativos GNU com Suporte Nativo ao XDG
export LESSCHARSET=utf-8
export LESSHISTFILE="$XDG_STATE_HOME/less/history"
export VIMINIT='let $MYVIMRC="$XDG_CONFIG_HOME/vim/vimrc" | source $MYVIMRC'

#-------------------------------------------------------------------------------------------
#--- Final do script bash-envs.sh
#-------------------------------------------------------------------------------------------