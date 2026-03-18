#
#Script: ~/.config/bash/claude-code-envs.sh
# Variáveis de ambiente para o Claude Code
# ==========================================================================================

_GIT_BASH_EXE="`echo $(/bin/df / | grep ' /$' | awk '{print $1}')${BASH}.exe | tr '/' '\\\'`"
export CLAUDE_CODE_GIT_BASH_PATH="${_GIT_BASH_EXE}"
unset _GIT_BASH_EXE

#-------------------------------------------------------------------------------------------
#--- Final do script claude-code-envs.sh
#-------------------------------------------------------------------------------------------