#
# Script: ~/.config/bash/bash-functions.sh
# Funções para facilitar o uso do Bash
# =============================================================================

#-------------------------------------------------------------------------------------------
# Função "echodo"
#-------------------------------------------------------------------------------------------
echodo() {
    printf "%s\n"     "${LINHA}"
    printf "=== %s\n" "$*"
    printf "%s\n"     "${LINHA}"
    $@
}

#-------------------------------------------------------------------------------------------
# Função "path2win"
#-------------------------------------------------------------------------------------------
path2win() {
    # Tenta casar o padrão: o grupo 1 é a letra do drive, o grupo 2 é todo o restante.
    if [[ "$1" =~ ^/([a-zA-Z])/(.*) ]]; then
        echo "${BASH_REMATCH[1]^^}:\\${BASH_REMATCH[2]//\//\\}"
    fi
}

#-------------------------------------------------------------------------------------------
# Função "path2lin"
#-------------------------------------------------------------------------------------------
path2lin ()
{
    if [[ "$1" =~ ^([a-zA-Z]):\\(.*) ]]; then
        echo "/${BASH_REMATCH[1],}/${BASH_REMATCH[2]//\\//}";
    fi
}

#-------------------------------------------------------------------------------------------
# Função "urlencode <string>"
#-------------------------------------------------------------------------------------------
urlencode() {
    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c";;
            *) printf '%%%02X' "'$c";;
        esac
    done
}

#-------------------------------------------------------------------------------------------
# Função "urldecode <string>"
#-------------------------------------------------------------------------------------------
urldecode() {
    local url_encoded="${1//+/ }"
    printf '%b' "${url_encoded//%/\\x}"
}


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


#-------------------------------------------------------------------------------------------
# Função para mostrar informações do ambiente
#-------------------------------------------------------------------------------------------
show-versions() {
    echo ""
    displayAction "Diretório de instalação dos Apps"
    displayInfo "APPS_BASE" "${APPS_BASE:-Não configurado}"
    
    echo ""
    displayAction "Clients dos Cloud Providers"
    displayInfo "AWS CLI" "$(aws --version 2>/dev/null || echo 'Não encontrado')"
    displayInfo "GCloud CLI" "$(gcloud --version 2>/dev/null || echo 'Não encontrado' | head -1)"
    
    echo ""
    displayAction "DevSecOps"
    displayInfo "Docker" "$(docker --version 2>/dev/null || echo 'Não encontrado')"
    displayInfo "Git" "$(git --version 2>/dev/null || echo 'Não encontrado')"
    displayInfo "Terraform" "$(terraform --version 2>/dev/null || echo 'Não encontrado' | head -1)"
    
    echo ""
    displayAction "Linguagens"
    displayInfo "Node.js" "$(node --version 2>/dev/null || echo 'Não encontrado')"
    displayInfo "npm" "$(npm --version 2>/dev/null || echo 'Não encontrado')"
    displayInfo "UV" "$(uv --version 2>/dev/null || echo 'Não encontrado')"
    displayInfo "Python (uv managed)"
    echo "$(uv python list --only-installed 2>/dev/null || echo \"'uv' não encontrado\")"
}
#-------------------------------------------------------------------------------------------
#--- Final do script bash-functions.sh
#-------------------------------------------------------------------------------------------