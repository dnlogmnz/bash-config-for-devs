#
# Script: ~/.config/bash/git-functions.sh
# Funções para facilitar o uso do Git CLI
# ==========================================================================================

#-------------------------------------------------------------------------------------------
# Função para mostrar informações do Git
#-------------------------------------------------------------------------------------------
git-info() {
  echo ""
  displayAction "Configurações do Git"
  displayInfo "Versão" "$(git --version 2>/dev/null || echo 'Git não encontrado')"
  displayInfo "Executável" "$(which git 2>/dev/null || echo 'Não encontrado')"
  displayInfo "Global Config Name" "$(git config --global user.name 2>/dev/null || echo 'Não configurado')"
  displayInfo "Global Config Email" "$(git config --global user.email 2>/dev/null || echo 'Não configurado')"
  displayInfo "Global Config Editor" "$(git config --global core.editor 2>/dev/null || echo 'Não configurado')"

  if git rev-parse --git-dir &>/dev/null; then
    echo ""
    displayAction "Informações do diretório corrente"
    displayInfo "Branch corrente" "$(git branch --show-current 2>/dev/null || echo 'Não disponível')"
    displayInfo "Arquivos modificados" "$(git status --porcelain | wc -l) arquivo(s)"
    displayInfo "Arquivos em stash" "$(git stash show -p 2>/dev/null | wc -l) arquivo(s)"
    displayInfo "Remote repository" "$(git remote get-url origin 2>/dev/null || echo 'Não configurado')"
  fi
}

#-------------------------------------------------------------------------------------------
# Função para configurar Git globalmente
#-------------------------------------------------------------------------------------------
git-config() {
  displayAction "Configurações do Git"
  read -p " - Nome completo .........: " name
  read -p " - Nome completo .........: " name
  read -p " - Endereço de email .....: " email
  read -p " - Endereço de email .....: " email

  git config set --global user.name "$name"
  git config set --global user.email "$email"
  git config set --global core.autocrlf "false"
  git config set --global core.eol "lf"
  git config set --global gui.encoding "utf-8"
  git config set --global http.sslbackend "schannel"
  git config set --global i18n.commitencoding "utf-8"
  git config set --global i18n.logoutputencoding "utf-8"

  displaySuccess "Sucesso" "Configurações globais aplicadas com sucesso!"

  git-info
}


#-------------------------------------------------------------------------------------------
# Função para status rápido da branch corrente
#-------------------------------------------------------------------------------------------
git-merge-tests() {
    # Validação inicial
    if ! git rev-parse --git-dir &>/dev/null; then
        displayFailure "Erro" "Este diretório não é um repositório Git"
        return 1
    fi

    # Configuração de variáveis
    local branch_from="staging"
    local branch_into="main"
    local report_titles="/tmp/git-merge-titles.$$"
    local report_files="/tmp/git-merge-files.$$"
    local ci_branches=("main" "staging" "developer")
    
    # 1. Atualização do Remoto
    echo ""
    displayAction "Sincronizando referências remotas..."
    git fetch --all --prune --verbose

    # 2. Atualização das Branches de CI/CD
    for branch in "${ci_branches[@]}"; do
        # Verifica se a branch existe localmente antes de tentar checkout
        echo ""
        displayAction "Atualizando branch: $branch"
        if git show-ref --verify --quiet "refs/heads/$branch"; then
            git checkout "$branch" && git pull || displayWarning "Aviso" "Falha ao atualizar $branch"
        else
            displayWarning "Pular" "Branch local '$branch' não encontrada"
        fi
    done

    echo ""
    displayAction "Gerando relatórios de comparação ($branch_from -> $branch_into)..."

    # 3. Gerar arquivo com títulos dos Merge Requests
    # Mantivemos 'echo' aqui pois é escrita em arquivo (texto puro), não saída visual.
    { 
        echo "# Lista de funcionalidades (Títulos dos Merge Requests)"
        echo "> from \`${branch_from}\` into \`${branch_into}\`"
        git log "${branch_into}..${branch_from}" --merges --pretty=format:"- %s"
    } > "$report_titles" 2>/dev/null
        
    # 4. Gerar arquivo com nomes dos arquivos alterados
    { 
        echo "# Lista de arquivos alterados"
        echo "> from \`${branch_from}\` into \`${branch_into}\`"
        git diff "${branch_into}..${branch_from}" --name-only
    } > "$report_files" 2>/dev/null

    # 5. Feedback final
    if [ -f "$report_titles" ] && [ -f "$report_files" ]; then
        displaySuccess "Sucesso" "Relatórios gerados em /tmp/"
        displayInfo "Log de Merges" "$report_titles"
        displayInfo "Arquivos Diff" "$report_files"
    else
        displayFailure "Erro" "Falha ao gerar os arquivos de relatório."
    fi
}

#-------------------------------------------------------------------------------------------
# Função para status rápido da branch corrente
#-------------------------------------------------------------------------------------------
git-branch() {
  if ! git rev-parse --git-dir &>/dev/null; then
    displayFailure "Erro" "Este diretório não é um repositório Git"
    return 1
  fi

  displayAction "Remote Branches"
  git branch -vv -r
  echo ""

  displayAction "Local Branches"
  git branch -vv
  echo ""

  displayAction "Current Branch"
  displayInfo "Branch" "$(git branch --show-current)"
  displayInfo "Arquivos modificados" "$(git status --porcelain | wc -l)"
  displayInfo "Commits ahead" "$(git rev-list --count HEAD @{upstream} 2>/dev/null || echo '0')"
  displayInfo "Commits behind" "$(git rev-list --count @{upstream} HEAD 2>/dev/null || echo '0')"
}

#-------------------------------------------------------------------------------------------
#--- Final do script git-functions.sh
#-------------------------------------------------------------------------------------------