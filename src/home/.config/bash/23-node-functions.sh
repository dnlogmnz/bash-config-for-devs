#
# Script: ~/.config/bash/node-functions.sh
# Funções para gerenciar versões do Node.js (substituto leve do nvm)
# ==========================================================================================


#-------------------------------------------------------------------------------------------
# HELPER: Resolve qual versão está ativa via junction "current"
#-------------------------------------------------------------------------------------------
_get_node_current_version() {
    # No Git Bash, junctions criadas com mklink /J aparecem como symlinks para o readlink.
    if [ -L "$NODE_CURRENT" ]; then
        basename "$(readlink "$NODE_CURRENT")"   # retorna ex: "v22.14.0"
    elif [ -d "$NODE_CURRENT" ]; then
        # Junction criada externamente: pergunta ao próprio executável
        node.exe --version 2>/dev/null || echo ""
    else
        echo ""
    fi
}

#-------------------------------------------------------------------------------------------
# HELPER: Apresenta informações sobre a versão default do Node.js
#-------------------------------------------------------------------------------------------
_node_current_version() {
    displayAction "Informações sobre a versão default para o ambiente"
    local current_version
    current_version=$(_get_node_current_version)
    displayInfo "Versão ativa" "${current_version:-Nenhuma (junction inexistente ou inválida)}"
    displayInfo "node --version" "$(node.exe --version 2>/dev/null || echo 'Não encontrado no PATH')"
    displayInfo "npm --version"  "$(npm.cmd --version  2>/dev/null || echo 'Não encontrado no PATH')"
}

#-------------------------------------------------------------------------------------------
# HELPER: Cria ou recria a junction $NODE_CURRENT → $node_dir via cmd.exe
# Equivalente nvm: nvm alias default <versão>
#
# Usa arquivo .bat temporário para evitar problemas de quoting com caminhos com espaços.
# A saída do cmd.exe é convertida de CP850 → UTF-8 para evitar caracteres quebrados.
#-------------------------------------------------------------------------------------------
_node_set_junction() {
    local new_current_dir="$1"

    # Converter caminhos para formato Windows (necessário para mklink /J)
    local win_current win_target
    win_current=$(path2win "$NODE_CURRENT")
    win_target=$(path2win "$new_current_dir")

    # Remover junction existente
    if [ -e "$NODE_CURRENT" ] || [ -L "$NODE_CURRENT" ]; then
        displayInfo "Remover configuração atual" "$NODE_CURRENT"
        rm "$NODE_CURRENT" || exit 1
    fi

    # Criar nova junction
    displayInfo "Configurar nova versão padrão" "$new_current_dir"
    cmd.exe //c "mklink /J $win_current $win_target" 1>/dev/null 2>&1
    exit_code=$?

    if [ $exit_code -eq 0 ]; then
        displaySuccess "Sucesso" "Junction criada: $NODE_CURRENT → $node_dir"
        return 0
    else
        displayFailure "Erro" "mklink falhou: $output"
        displayWarning "Dica" "Verifique se o terminal tem acesso ao cmd.exe e se os caminhos existem"
        return 1
    fi
}


#-------------------------------------------------------------------------------------------
# Lista as versões instaladas em $NODE_HOME (diretórios com nome vX.Y.Z).
# Equivalente a "nvm list".
#-------------------------------------------------------------------------------------------
node-list() {
    if [ ! -d "$NODE_HOME" ]; then
        displayWarning "Aviso" "Diretório \$NODE_HOME não encontrado: $NODE_HOME"
        return 1
    fi

    local current_version
    current_version=$(_get_node_current_version)

    local versions
    versions=$(ls -1p "$NODE_HOME" | grep "^v[0-9].*/$" | tr -d '/' 2>/dev/null)

    if [ -z "$versions" ]; then
        displayWarning "Aviso" "Nenhuma versão instalada em $NODE_HOME"
        return 0
    fi

    displayAction "Versões do Node.js instaladas"
    while IFS= read -r ver; do
        if [ "$ver" = "$current_version" ]; then
            displayInfo "$ver" "$NODE_HOME/$ver/  (*default)"
        else
            displayInfo "$ver" "$NODE_HOME/$ver/"
        fi
    done <<< "$versions"
}


#-------------------------------------------------------------------------------------------
# Baixa node-vxx.xx.x-win-x64.zip de nodejs.org, e cria pasta $NODE_HOME/v<versão>
# Emula "nvm install <versão>"
#-------------------------------------------------------------------------------------------
node-install() {
    if [ -z "$1" ]; then
        displayWarning "Uso"     "node-install <versão>"
        displayInfo   "Exemplo" "node-install 22.14.0"
        return 1
    fi

    local version="$1"
    local pkg_name="node-v${version}-win-x64"
    local node_dir="${NODE_HOME}/v${version}"           # destino final renomeado
    local zip_url="https://nodejs.org/dist/v${version}/${pkg_name}.zip"
    local zip_file="${NODE_HOME}/${pkg_name}.zip"

    # Verificar se já está instalada
    if [ -d "$node_dir" ]; then
        displayWarning "Aviso" "Node.js v$version já instalado em $node_dir"
        displayInfo   "Dica"  "Para definir como padrão: node-default $version"
        return 0
    fi

    displayAction "Instalando Node.js v$version..."
    displayInfo   "Origem"  "$zip_url"
    displayInfo   "Destino" "$node_dir"
    echo ""

    # Download
    displayScript "Baixando ${pkg_name}.zip"
    if ! curl -L --progress-bar --fail -o "$zip_file" "$zip_url"; then
        echo ""
        displayFailure "Erro" "Falha no download. Verifique se a versão v$version existe em nodejs.org/dist"
        rm -f "$zip_file"
        return 1
    fi
    echo ""

    # Extração: o ZIP contém internamente a pasta "node-v<versão>-win-x64"
    displayScript "Extraindo ${pkg_name}.zip"
    if ! unzip -q "$zip_file" -d "$NODE_HOME"; then
        echo ""
        displayFailure "Erro" "Falha na extração do ZIP"
        rm -f "$zip_file"
        return 1
    fi

    # Renomear para o formato adotado: vX.Y.Z
    displayScript "Renomeando para v${version}"
    mv "${NODE_HOME}/${pkg_name}" "$node_dir"

    # Limpeza do ZIP
    rm -f "$zip_file"

    echo ""
    displaySuccess "Instalado"     "Node.js v$version disponível em $node_dir"
    displayInfo   "Próximo passo" "node-default $version"
}


#-------------------------------------------------------------------------------------------
# Recria a junction $NODE_HOME/current apontando para a versão escolhida.
# Emula "nvm alias default <versão>"
#
# Aceita os seguintes formatos de <versão>:
#   node-default 22.14.0   → usa exatamente v22.14.0
#   node-default 22        → usa a v22.x.x mais recente instalada
#   node-default 20.18     → usa a v20.18.x mais recente instalada
#
# Nota sobre junctions no Windows via Git Bash:
#   O comando nativo é:  cmd /c mklink /J <link> <alvo>
#   Usamos um .bat temporário para lidar corretamente com caminhos com espaços.
#-------------------------------------------------------------------------------------------
node-default() {
    # Sem argumentos: exibir ajuda e versões disponíveis
    if [ -z "$1" ]; then
        displayAction "Nenhum argumento recebido na linha de comandos"
        displayInfo   "Sintaxe"  "node-default <versão>"
        displayInfo   "Exemplos" ""
        displayInfo   "  node-default 22.14.0" "usa exatamente v22.14.0"
        displayInfo   "  node-default 22"      "a v22.x.x mais recente instalada"
        displayInfo   "  node-default 20.18"   "a v20.18.x mais recente instalada"
        echo ""
        node-list
        return 0
    fi

    displayAction "Encontrar diretório contendo a versão solicitada"
    
    # Normalizar entrada: aceitar "22.14.0", "v22.14.0", "22", "20.18" etc.
    local target_version="${1#v}"    # remove prefixo "v" se houver

    # Resolver o diretório instalado que melhor corresponde ao prefixo informado
    local matched_dir
    matched_dir=$(/bin/ls -1 "$NODE_HOME" | grep "^v[0-9]" | grep "^v${target_version}" | sort -V | tail -1)

    if [ -z "$matched_dir" ]; then
        displayFailure "Erro" "Nenhuma versão instalada corresponde a: v${target_version}"
        displayInfo    "Dica" "Use 'node-install <versão>' para baixar uma nova versão"
        echo ""
        node-list
        return 1
    fi

    displayInfo "Matched dir" "$matched_dir"
    local node_dir="${NODE_HOME}/${matched_dir}"
    displayInfo "Node dir" "$node_dir"
    
    echo ""
    displayAction "Definir '$matched_dir' como versão padrão"
    _node_set_junction "$node_dir" || return 1

    echo ""
    _node_current_version
}


#-------------------------------------------------------------------------------------------
# Exibe informações gerais do ambiente Node.js
#-------------------------------------------------------------------------------------------
node-info() {
    echo ""
    displayAction "Variáveis de ambiente para Node.js"
    displayInfo "NODE_HOME"        "${NODE_HOME:-Não configurado}"
    displayInfo "NODE_CURRENT"     "${NODE_CURRENT:-Não configurado}"
    displayInfo "NPM_CONFIG_CACHE" "${NPM_CONFIG_CACHE:-Não configurado}"

    echo ""
    _node_current_version
    
    echo ""
    node-list
}


#-------------------------------------------------------------------------------------------
#--- Final do script node-functions.sh
#-------------------------------------------------------------------------------------------
