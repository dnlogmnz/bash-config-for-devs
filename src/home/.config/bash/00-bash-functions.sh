#
# Script: ~/.config/bash/bash-functions.sh
# Funções para facilitar o uso do Bash
# =============================================================================

#-------------------------------------------------------------------------------------------
# Função "echodo"
#-------------------------------------------------------------------------------------------
function echodo() {
    echo; echo "$LINHA"; echo "=== $*"; echo "$LINHA"
    $*
}

#-------------------------------------------------------------------------------------------
# Função "path2win"
#-------------------------------------------------------------------------------------------
function path2win() {
    # Tenta casar o padrão: o grupo 1 é a letra do drive, o grupo 2 é todo o restante.
    if [[ "$1" =~ ^/([a-zA-Z])/(.*) ]]; then
        echo "${BASH_REMATCH[1]^^}:\\${BASH_REMATCH[2]//\//\\}"
    fi
}

#-------------------------------------------------------------------------------------------
# Função "path2lin"
#-------------------------------------------------------------------------------------------
function path2lin ()
{
    if [[ "$1" =~ ^([a-zA-Z]):\\(.*) ]]; then
        echo "/${BASH_REMATCH[1],}/${BASH_REMATCH[2]//\\//}";
    fi
}

#-------------------------------------------------------------------------------------------
# Função "urlencode <string>"
#-------------------------------------------------------------------------------------------
function urlencode() {
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
function urldecode() {
    local url_encoded="${1//+/ }"
    printf '%b' "${url_encoded//%/\\x}"
}


#-------------------------------------------------------------------------------------------
# Funções para exibir mensagens
#-------------------------------------------------------------------------------------------

# Definir variaveis para cores no terminal
export colorTitle="$(printf '\e[48;5;44;38;5;0m')" # 5: paleta de 256 cores; 48: fundo, 44: Ciano; 38: frente, 0: preto
export colorAction="$(printf '\e[36m')"     # 36: Ciano
export colorScript="$(printf '\e[33m')"     # 33: Amarelo
export colorSuccess="$(printf '\e[1;32m')"  # 1: Negrito, 32: Verde
export colorFailure="$(printf '\e[1;31m')"  # 1: Negrito, 31: Vermelho
export colorWarning="$(printf '\e[1;33m')"  # 1: Negrito, 33: Amarelo
export colorReset="$(printf '\e[0m')"       # Reset de todas as as cores e formatações

# Definir funções que apresentam mensagens coloridas
function displayTitle()   { printf '%s%-*s%s\n'       "${colorTitle}" "${COLUMNS:-78}" ">>> $*" "${colorReset}"; }
function displayAction()  { printf '%s>>> %s%s\n'     "${colorReset}${colorAction}" "$*" "${colorReset}"; }
function displayScript()  { printf '%s%s... %s'       "${colorReset}${colorScript}" "$*" "${colorReset}"; }
function displayInfo()    { printf '%s - %-15s%s%s\n' "${colorReset}" "$1" "${colorReset}" "${2:+: ${*:2}}"; }
function displaySuccess() { printf '%s[%s]%s %s\n'    "${colorReset}${colorSuccess}" "$1" "${colorReset}" "$2"; }
function displayFailure() { printf '%s[%s]%s %s\n'    "${colorReset}${colorFailure}" "$1" "${colorReset}" "$2"; }
function displayWarning() { printf '%s[%s]%s %s\n'    "${colorReset}${colorWarning}" "$1" "${colorReset}" "$2"; }


#-------------------------------------------------------------------------------------------
# Função para mostrar informações do ambiente
#-------------------------------------------------------------------------------------------
show-versions() {
    echo "=== Diretório de instalação dos Apps ==="
    echo "  APPS_BASE .............: $APPS_BASE"
    echo ""
    echo "=== Clients dos Cloud Providers ==="
    echo -n "  AWS CLI ...............: "
    echo "$(aws --version 2>/dev/null || echo 'Não encontrado')"
    echo -n "  GCloud CLI ............: "
    echo "$(gcloud --version 2>/dev/null || echo 'Não encontrado' | head -1)"
    echo ""
    echo "=== DevSecOps ==="
    echo -n "  Docker ................: "
    echo "$(docker --version 2>/dev/null || echo 'Não encontrado')"
    echo -n "  Git ...................: "
    echo "$(git --version 2>/dev/null || echo 'Não encontrado')"
    echo -n "  Terraform .............: "
    echo "$(terraform --version 2>/dev/null || echo 'Não encontrado' | head -1)"
    echo ""
    echo "=== Linguagens ==="
    echo -n "  Node.js ...............: "
    echo "$(node --version 2>/dev/null || echo 'Não encontrado')"
    echo -n "  npm ...................: "
    echo "$(npm --version 2>/dev/null || echo 'Não encontrado')"
    echo -n "  UV ....................: "
    echo "$(uv --version 2>/dev/null || echo 'Não encontrado')"
    echo -n "  Python (uv managed) ...: "
    echo "$(uv python list --only-installed 2>/dev/null || echo 'uv' não encontrado)"
}

#-------------------------------------------------------------------------------------------
#--- Final do script ~/.config/bash-functions.sh
#-------------------------------------------------------------------------------------------