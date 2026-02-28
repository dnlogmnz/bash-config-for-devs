#
# Script: ~/.config/bash/git-functions.sh
# Funções para facilitar o uso do Git CLI
# ==========================================================================================

#-------------------------------------------------------------------------------------------
# Função para mostrar informações do Git
#-------------------------------------------------------------------------------------------
git-info() {
    echo "=== Configurações do Git ==="
    echo "  Versão ................: $(git --version 2>/dev/null || echo 'Git não encontrado')"
    echo "  Executável ............: $(which git 2>/dev/null || echo 'Não encontrado')"
    echo "  Global Config Name  ...: $(git config --global user.name 2>/dev/null || echo 'Não configurado')"
    echo "  Global Config Email ...: $(git config --global user.email 2>/dev/null || echo 'Não configurado')"
    echo "  Global Config Editor ..: $(git config --global core.editor 2>/dev/null || echo 'Não configurado')"

    if git rev-parse --git-dir &>/dev/null; then
        echo ""
        echo "=== Informações do diretório corrente ==="
        echo "  Branch corrente .......: $(git branch --show-current 2>/dev/null || echo 'Não disponível')"
        echo "  Arquivos modificados ..: $(git status --porcelain | wc -l) arquivos modificados"
        echo "  Arquivos em stash .....: $(git stash show -p 2>/dev/null | wc -l) arquivos em stash"
        echo "  Remote repository .....: $(git remote get-url origin 2>/dev/null || echo 'Não configurado')"
    fi
}


#-------------------------------------------------------------------------------------------
# Função para configurar Git globalmente
#-------------------------------------------------------------------------------------------
git-config() {
    echo "=== Configurando Git ==="
    read -p "  Nome completo .........: " name
    read -p "  Endereço de email .....: " email

    git config set --global user.name "$name"
    git config set --global user.email "$email"
    git config set --global core.autocrlf "false"
    git config set --global core.eol "lf"
    git config set --global gui.encoding "utf-8"
    git config set --global http.sslbackend "schannel"
    git config set --global i18n.commitencoding "utf-8"
    git config set --global i18n.logoutputencoding "utf-8"

    echo "Git configurado com sucesso!"

    echo
    git-info
}


#-------------------------------------------------------------------------------------------
# Função para status rápido da branch corrente
#-------------------------------------------------------------------------------------------
git-merge-tests() {
    if ! git rev-parse --git-dir &>/dev/null; then
        echo "Este diretório não é um repositório Git"
        return 1
    fi

    # Recebe parâmetros na chamada da função
    BRANCH_FROM="staging"
    BRANCH_INTO="main"

    # Buscar todas atualizações de todos os branches ativos no remoto
    git fetch --all --prune
    
    # Opcional: faz um checkout das 3 branches onde rodam pipelines de CI/CD
    echodo git checkout main
    git pull
    echodo git checkout staging
    git pull
    echodo git checkout developer
    git pull
    
    # Gerar arquivo com títulos dos Merge Requests
    { echo "# Lista de funcionalidades (Títulos dos Merge Requests)";
      echo "> from \`${BRANCH_FROM}\` into \`${BRANCH_INTO}\`";
      git log ${BRANCH_INTO}..${BRANCH_FROM} --merges --pretty=format:"- %s";
    } >/tmp/git-merge-titles.$$ 2>/dev/null
        
    # Gerar arquivo com nomes dos arquivos alterados
    { echo "# Lista de arquivos alterados";
      echo "> from \`${BRANCH_FROM}\` into \`${BRANCH_INTO}\`";
      git diff ${BRANCH_INTO}..${BRANCH_FROM} --name-only;
    } >/tmp/git-merge-files.$$ 2>/dev/null
        
}

#-------------------------------------------------------------------------------------------
# Função para status rápido da branch corrente
#-------------------------------------------------------------------------------------------
git-branch() {
    if ! git rev-parse --git-dir &>/dev/null; then
        echo "Este diretório não é um repositório Git"
        return 1
    fi

    echo "=== Remote Branches ==="
    git branch -vv -r
    echo ""
    echo "=== Local Branches ==="
    git branch -vv
    echo ""
    echo "=== Current Branch ==="
    echo "  Branch ................: $(git branch --show-current)"
    echo "  Arquivos modificados ..: $(git status --porcelain | wc -l)"
    echo "  Commits ahead .........: $(git rev-list --count HEAD @{upstream} 2>/dev/null || echo '0')"
    echo "  Commits behind ........: $(git rev-list --count @{upstream} HEAD 2>/dev/null || echo '0')"
}

#-------------------------------------------------------------------------------------------
#--- Final do script ~/.config/git-functions.sh
#-------------------------------------------------------------------------------------------