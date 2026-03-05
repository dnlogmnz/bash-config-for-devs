#
# Script: ~/.config/bash/node-functions.sh
# Funções para facilitar o uso do Node.js
# ==========================================================================================

# [to-do] # Configurações ao "ativar" uma versão
# [to-do] export NPM_CONFIG_PREFIX="${XDG_DATA_HOME}/npm"    
# [to-do] export NPM_CONFIG_PREFIX="${NODE_CURRENT}"
# [to-do] npm config set prefix "D:\%USERNAME%\Apps\nodejs\vXX.XX.X"
# [to-do] npm config set cache "%XDG_CACHE_HOME%\npm"

#-------------------------------------------------------------------------------------------
# Função para limpar PATH do Node.js anterior
#-------------------------------------------------------------------------------------------
_clean_node_path() {
    # Remove todas as entradas relacionadas ao Node.js do PATH
    PATH=$(echo "$PATH" | tr ':' '\n' | grep -v "$NODE_HOME" | tr '\n' ':')

    # Remove ':' duplos e o último ':'
    PATH=$(echo "$PATH" | sed 's/::/:/g' | sed 's/:$//')
    export PATH
}


#-------------------------------------------------------------------------------------------
# Função para detectar se symlinks reais funcionam no Windows
#-------------------------------------------------------------------------------------------
_test_node_symlinks_support() {
    local test_dir=$(mktemp -d)
    local test_source="$test_dir/source"
    local test_link="$test_dir/link"

    mkdir -p "$test_source"
    echo "test" > "$test_source/test.txt"

    # Tentar criar symlink
    if ln -sf "$test_source" "$test_link" 2>/dev/null; then
        # Verificar se é symlink real (não cópia)
        if [ -L "$test_link" ]; then
            rm -rf "$test_dir"
            return 0  # Symlinks reais funcionam
        fi
    fi

    rm -rf "$test_dir"
    return 1  # Symlinks não funcionam (só cópias)
}


#-------------------------------------------------------------------------------------------
# Função para obter a versão atualmente ativa
#-------------------------------------------------------------------------------------------
_get_current_node_version() {
    local current_version=""

    # Verificar se existe versão padrão definida
    if [ -f "$NODE_HOME/.default_version" ]; then
        current_version=$(cat "$NODE_HOME/.default_version")
    fi

    # Verificar se o diretório current existe e se corresponde à versão padrão
    if [ -d "$NODE_CURRENT" ] && [ -n "$current_version" ]; then
        local node_dir="$NODE_HOME/$current_version"
        if [ -L "$NODE_CURRENT" ]; then
            # É um symlink - verificar destino
            if [ "$(readlink "$NODE_CURRENT")" = "$node_dir" ]; then
                echo "$current_version" # Retorno de função, não visual
            fi
        elif [ -d "$node_dir" ]; then
            # É uma cópia - assumir que corresponde à versão padrão
            echo "$current_version" # Retorno de função, não visual
        fi
    fi
}

#-------------------------------------------------------------------------------------------
# Função interna para listar versões instaladas com indicadores
#-------------------------------------------------------------------------------------------
_list_node_versions() {
    local show_header="${1:-true}"

    if [ "$show_header" = "true" ]; then
        displayAction "Versoes disponiveis:"
    fi

    if [ ! -d "$NODE_HOME" ]; then
        displayWarning "Aviso" "Nenhuma versão encontrada em $NODE_HOME"
        return 1
    fi

    local current_version=$(_get_current_node_version)
    local has_versions="false"

    # Listar diretórios que começam com "node-" e destacar a versão ativa
    while read -r version; do
        has_versions="true"
        if [ "$current_version" = "$version" ]; then
            displayInfo "Versão" "$version (* Ativa)"
        else
            displayInfo "Versão" "$version"
        fi
    done < <(ls -1 "$NODE_HOME" | grep "^node-" | tr -d '/')

    # Verificar se encontrou alguma versão
    if [ "$has_versions" = "false" ]; then
        displayWarning "Aviso" "Nenhuma versão encontrada em $NODE_HOME"
    fi
}


#-------------------------------------------------------------------------------------------
# Função para carregar versão padrão salva
#-------------------------------------------------------------------------------------------
_load_default_node() {
    if [ -f "$NODE_HOME/.default_version" ]; then
        local default_version=$(cat "$NODE_HOME/.default_version")
        local node_dir="${NODE_HOME}/${default_version}"

        if [ -d "$node_dir" ]; then
            # Verificar se a versão atual já é a mesma da versão padrão
            local current_is_correct=false

            if [ -e "$NODE_CURRENT" ]; then
                if [ -L "$NODE_CURRENT" ]; then
                    # É um symlink - verificar se aponta para o diretório correto
                    if [ "$(readlink "$NODE_CURRENT")" = "$node_dir" ]; then
                        current_is_correct=true
                    fi
                elif [ -d "$NODE_CURRENT" ]; then
                    # É um diretório copiado - verificar se contém a versão correta
                    local current_node_version=$("$NODE_CURRENT/node" --version 2>/dev/null)
                    local expected_node_version=$("$node_dir/node" --version 2>/dev/null)
                    if [ "$current_node_version" = "$expected_node_version" ]; then
                        current_is_correct=true
                    fi
                fi
            fi

            # Se a versão atual não é a correta, fazer a troca
            if [ "$current_is_correct" = "false" ]; then
                # Limpar PATH anterior do Node.js
                _clean_node_path

                # Remover diretório/link atual
                if [ -e "$NODE_CURRENT" ]; then
                    rm -rf "$NODE_CURRENT"
                fi

                # Criar link/cópia para versão padrão
                if _test_node_symlinks_support && ln -sf "$node_dir" "$NODE_CURRENT" 2>/dev/null; then
                    # Symlink funcionou
                    export PATH="$NODE_CURRENT:$PATH"
                else
                    # Fallback: cópia
                    cp -r "$node_dir" "$NODE_CURRENT"
                    export PATH="$NODE_CURRENT:$PATH"
                fi
            else
                # Versão já está correta, apenas garantir que está no PATH
                if [[ ":$PATH:" != *":$NODE_CURRENT:"* ]]; then
                    export PATH="$NODE_CURRENT:$PATH"
                fi
            fi
        fi
    fi
}

#-------------------------------------------------------------------------------------------
# Função para mostrar informações do Node.js
#-------------------------------------------------------------------------------------------
node-info() {
    displayAction "Informações do Node.js"
    displayInfo "Versão do Node" "$(node --version 2>/dev/null || echo 'Não encontrado')"
    displayInfo "Versão do NPM" "$(npm --version 2>/dev/null || echo 'Não encontrado')"
    displayInfo "Executável Node" "$(which node 2>/dev/null || echo 'Não encontrado')"
    displayInfo "Executável NPM" "$(which npm 2>/dev/null || echo 'Não encontrado')"
    displayInfo "Diretório atual" "$NODE_CURRENT"
    displayInfo "Cache NPM" "$NPM_CONFIG_CACHE"
    displayInfo "Pacotes globais" "$NPM_CONFIG_PREFIX"
    displayInfo "Symlinks reais" "$(_test_node_symlinks_support && echo "Sim (Developer Mode)" || echo "Não (Usando cópia)")"

    # Mostrar versão padrão
    if [ -f "$NODE_HOME/.default_version" ]; then
        displayInfo "Versão padrão" "$(cat "$NODE_HOME/.default_version")"
    else
        displayInfo "Versão padrão" "Nenhuma definida"
    fi

    echo ""
    displayAction "Versões Instaladas"
    _list_node_versions false
}

#-------------------------------------------------------------------------------------------
# Função para exibir qual versão do Node.js está ativa
#-------------------------------------------------------------------------------------------
node-current() {
    if command -v node >/dev/null 2>&1; then
        displayAction "Node.js Ativo"
        displayInfo "Versão ativa" "$(node --version)"
        displayInfo "Executável" "$(which node)"
        if [ -f "$NODE_HOME/.default_version" ]; then
            displayInfo "Versão padrão" "$(cat "$NODE_HOME/.default_version")"
        else
            displayInfo "Versão padrão" "Nenhuma versão padrão definida"
        fi
    else
        displayFailure "Erro" "Node.js não está disponível no PATH"
        displayInfo "Dica" "Para ativar, execute o comando:"
        displayScript "node-use <versao>"
        echo ""
        _list_node_versions true
    fi
}

#-------------------------------------------------------------------------------------------
# Função para alternar entre versões do Node.js (salva automaticamente como padrão)
#-------------------------------------------------------------------------------------------
node-use() {
    if [ -z "$1" ]; then
        echo ""
        displayAction "Informar a versão"
        displayWarning "Uso" "node-use <versao>"
        echo ""
        _list_node_versions true
        return 1
    fi

    local version="$1"
    local node_dir="${NODE_HOME}/${version}"

    if [ ! -d "$node_dir" ]; then
        displayFailure "Erro" "Node.js versão $version não encontrada"
        displayInfo "Esperado" "$node_dir"
        echo ""
        _list_node_versions true
        return 1
    fi

    displayAction "Alterando para Node.js versão $version..."

    _clean_node_path

    if [ -e "$NODE_CURRENT" ]; then
        displayInfo "Ação" "Removendo versão anterior"
        rm -rf "$NODE_CURRENT"
    fi

    if _test_node_symlinks_support && ln -sf "$node_dir" "$NODE_CURRENT" 2>/dev/null; then
        displayInfo "Link" "Criado symlink para $node_dir"
        method="symlink"
    else
        displayInfo "Ação" "Copiando arquivos (symlinks não suportados)..."
        cp -r "$node_dir" "$NODE_CURRENT"
        method="cópia"
    fi

    export PATH="$NODE_CURRENT:$PATH"

    mkdir -p "$NODE_HOME"
    echo "$version" > "$NODE_HOME/.default_version"

    # Verificar se a mudança funcionou
    local active_version=$(node --version 2>/dev/null)
    local expected_version=$(grep -o 'v[0-9.]*' <<< "$version" || echo "desconhecida")

    if [ "$active_version" = "$expected_version" ] || [[ "$active_version" == *"$(echo $version | grep -o '[0-9.]*')"* ]]; then
        echo ""
        displaySuccess "Concluído" "Node.js versão $version ativada (via $method)"
        displayInfo "Status" "Versão $active_version definida como padrão."
    else
        echo ""
        displayFailure "Erro" "A versão não foi ativada corretamente"
        displayInfo "Esperado" "$expected_version"
        displayInfo "Atual" "$active_version"
        displayInfo "Executável" "$(which node)"
        echo ""
        displayAction "Depuração"
        displayInfo "NODE_CURRENT" "$NODE_CURRENT"
        displayInfo "PATH" "$PATH"
        return 1
    fi
}

#-------------------------------------------------------------------------------------------
# Função para exibir instruções para instalar uma nova versão do Node.js
#-------------------------------------------------------------------------------------------
node-download() {
    if [ -z "$1" ]; then
        echo "Uso: node-download <versao>"
        echo "Exemplo: node-download 18.17.0"
        echo ""
        _list_node_versions true
        return 1
    fi

    local version="$1"
    local node_dir="${NODE_HOME}/node-v${version}-win-x64"

    if [ -d "$node_dir" ]; then
        echo "Node.js versao $version ja esta instalada em:"
        echo "  $node_dir"
        echo "Para usar: node-use node-v${version}-win-x64"
        echo ""
        _list_node_versions true
        return 0
    fi

    echo "Para instalar Node.js $version:"
    local node_zip="https://nodejs.org/dist/v${version}/node-v${version}-win-x64.zip"
    displayInfo "Baixar ZIP" "$node_zip"
    displayInfo "Criar diretório" "mkdir -p $node_dir"
    displayInfo "Extrair ZIP" "unzip -q $node_zip -d $node_dir"
    displayInfo "Tornar corrente" "node-use node-v${version}-win-x64"
    echo ""
    echo "=== Versoes ja instaladas ==="
    _list_node_versions false
}


#-------------------------------------------------------------------------------------------
# Função para listar projetos Node.js
#-------------------------------------------------------------------------------------------
node-projects() {
    displayAction "Projetos Node.js no diretório atual"
    local found_projects=false

    find . -name "package.json" | head -10 | while read project; do
        found_projects=true
        displayInfo "Projeto" "$project"
    done

    if [ "$found_projects" = "false" ]; then
        displayWarning "Atenção" "Nenhum projeto Node.js encontrado no diretório atual"
    fi
}


#-------------------------------------------------------------------------------------------
# Função para criar projeto Node.js básico
#-------------------------------------------------------------------------------------------
node-new-project() {
    local project_name="${1:-$(basename $PWD)}"

    if [ -f package.json ]; then
        displayWarning "Aviso" "O arquivo package.json já existe neste diretório."
        return 1
    fi

    displayAction "Criando projeto Node.js: $project_name"

    # Verificar se Node.js está disponível
    if ! command -v node >/dev/null 2>&1; then
        displayFailure "Erro" "Node.js não encontrado."
        displayInfo "Dica" "Execute primeiro o comando:"
        displayScript "node-use <versao>"
        echo ""
        _list_node_versions true
        return 1
    fi

    displayInfo "Status" "Versão do Node.js: $(node --version)"

    # Redirecionado para manter o terminal mais limpo
    npm init -y > /dev/null

    echo ""
    displaySuccess "Sucesso" "Projeto '$project_name' criado!"

    echo ""
    displayAction "Comandos úteis"
    displayInfo "npm install <pacote>" "Instalar dependência"
    displayInfo "npm install -D <pacote>" "Instalar dev dependency"
    displayInfo "npm run <script>" "Executar script"
    displayInfo "npm test" "Executar testes"
    echo ""
}


#-------------------------------------------------------------------------------------------
# Função para limpar cache do NPM
#-------------------------------------------------------------------------------------------
npm-clean() {
    echo "Limpando cache do NPM..."
    if command -v npm >/dev/null 2>&1; then
        npm cache clean --force
        echo "Cache limpo!"
    else
        echo "ERRO: NPM nao encontrado. Execute primeiro: node-use <versao>"
        echo ""
        _list_node_versions true
    fi
}


#-------------------------------------------------------------------------------------------
# Função para verificar pacotes desatualizados
#-------------------------------------------------------------------------------------------
npm-outdated() {
    echo "Verificando pacotes desatualizados..."
    if command -v npm >/dev/null 2>&1; then
        npm outdated
    else
        echo "ERRO: NPM nao encontrado. Execute primeiro: node-use <versao>"
        echo ""
        _list_node_versions true
    fi
}


#-------------------------------------------------------------------------------------------
# Função para audit de segurança
#-------------------------------------------------------------------------------------------
npm-audit() {
    echo "Executando audit de seguranca..."
    if command -v npm >/dev/null 2>&1; then
        npm audit
        echo ""
        echo "Para corrigir vulnerabilidades automaticamente:"
        echo "  npm audit fix"
    else
        echo "ERRO: NPM nao encontrado. Execute primeiro: node-use <versao>"
        echo ""
        _list_node_versions true
    fi
}


#-------------------------------------------------------------------------------------------
# Carregar versão padrão automaticamente quando o script é inicializado
#-------------------------------------------------------------------------------------------
_load_default_node 2>/dev/null


#-------------------------------------------------------------------------------------------
#--- Final do script node-functions.sh
#-------------------------------------------------------------------------------------------