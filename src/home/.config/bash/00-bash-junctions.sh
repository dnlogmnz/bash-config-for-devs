#
# Script: ~/.config/bash/bash-junctions.sh
# Validar diretórios e PATH para uso do Git Bash
# Depende de funções definidas em bash-functions.sh
# =============================================================================

# Lista de diretórios para criar Junctions em C:\Users\%USERNAME%
dot_dirs=(".cache" ".config" ".local" ".certs" ".ssh" ".aws")

# Função para garantir Junctions
ensure_junction() {
    local folder="$1"
    local path_c="$USERPROFILE/$folder"
    local win_c="C:\\Users\\$USERNAME\\$folder"
    local win_d="D:\\$USERNAME\\home\\$folder"

    if [ ! -L "$path_c" ]; then
        if [ -e "$path_c" ]; then
            displayFailure "Windows"   "Remover diretório ou arquivo '$win_c'"
            displayInfo "Por que?"     "Em C:, esse path deveria ser uma JUNCTION no Windows"
            displayInfo "O que ele é?" "$(stat -c '%F' "$path_c" 2>/dev/null)"
            displayInfo "O que fazer?" "Após remover manualmente, fechar esta sessão e abrir uma nova"
            displayInfo "Sugestão"     "Combine conteúdo com '$win_d' antes de remover"
            echo
        else
            # Executar mklink sem capturar output (evita problemas de encoding)
            if cmd //c "mklink /J \"$win_c\" \"$win_d\"" >/dev/null 2>&1; then
                displaySuccess "Windows" "Junção criada para $win_c <<===>> $win_d"
            else
                # Capturar apenas mensagens de erro significativas
                local err_msg
                err_msg=$(cmd //c "mklink /J \"$win_c\" \"$win_d\"" 2>&1 | sed 's/\r$//' | grep -v "^$" | head -1)
                displayFailure "Windows" "Erro ao criar junção: ${err_msg:-comando falhou}"
            fi
        fi
    fi
}

# Criar JUNCTIONS para a lista de diretórios
for dir in "${dot_dirs[@]}"; do
    ensure_junction "$dir"
done

# Adicionar $HOME/.local/bin ao início do PATH
local_bin="$HOME/.local/bin"
if [[ ":$PATH:" != *":$local_bin:"* ]]; then
    displayFailure "Windows" "Variáveis de ambiente para sua conta: adicionar \"$(command path2win "$local_bin")\" ao PATH"
    export PATH="$local_bin:$PATH"
fi

# Liberar variáveis de ambiente
unset -f ensure_junction

#--------------------------------------------------------------------------------
#--- Final do script bash-junctions.sh
#--------------------------------------------------------------------------------