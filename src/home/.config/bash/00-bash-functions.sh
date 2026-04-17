#
# Script: ~/.config/bash/bash-functions.sh
# Funções para facilitar o uso do Bash
# =============================================================================

#-------------------------------------------------------------------------------------------
# Funções para exibir mensagens
#-------------------------------------------------------------------------------------------

# Definir variaveis para cores das mensagens, usando códigos ANSI
export colorTitle="$(printf '\e[48;5;44;38;5;0m')" # 5: paleta de 256 cores; 48: fundo, 44: Ciano; 38: frente, 0: preto
export colorAction="$(printf '\e[36m')"     # 36: Ciano
export colorScript="$(printf '\e[33m')"     # 33: Amarelo
export colorSuccess="$(printf '\e[1;32m')"  # 1: Negrito, 32: Verde
export colorFailure="$(printf '\e[1;31m')"  # 1: Negrito, 31: Vermelho
export colorWarning="$(printf '\e[1;33m')"  # 1: Negrito, 33: Amarelo
export colorReset="$(printf '\e[0m')"       # Reset de todas as as cores e formatações

# Definir funções que apresentam mensagens com textos coloridos e formatados, usando as variáveis de cor acima
displayTitle()   { printf '%s>>> %-*s%s\n'    "${colorReset}${colorTitle}" "$((${COLUMNS:-80} - 4))" "$*" "${colorReset}"; }
displayAction()  { printf '%s>>> %s%s\n'      "${colorReset}${colorAction}" "$*" "${colorReset}"; }
displayScript()  { printf '%s%s... %s'        "${colorReset}${colorScript}" "$*" "${colorReset}"; }
displayInfo()    { printf '%s  - %-32s%s%s\n' "${colorReset}" "$1" "${colorReset}" "${2:+: ${*:2}}"; }
displaySuccess() { printf '%s[%s]%s %s\n'     "${colorReset}${colorSuccess}" "$1" "${colorReset}" "$2"; }
displayFailure() { printf '%s[%s]%s %s\n'     "${colorReset}${colorFailure}" "$1" "${colorReset}" "$2"; }
displayWarning() { printf '%s[%s]%s %s\n'     "${colorReset}${colorWarning}" "$1" "${colorReset}" "$2"; }

# Garantir que as funções de display de mensagens estejam disponívels para sub-shells
export -f displayTitle
export -f displayAction
export -f displayScript
export -f displayInfo
export -f displaySuccess
export -f displayFailure
export -f displayWarning

#-------------------------------------------------------------------------------------------
#--- Final do script bash-functions.sh
#-------------------------------------------------------------------------------------------