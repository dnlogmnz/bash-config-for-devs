#
# Projeto: bashrc-for-devs
#
# Script: ~/.config/bashrc/claude-code-envs.sh
# Objetivo: validar variáveis de ambiente e configura aliases para uso do Claude Code.
# =============================================================================================

# ---------------------------------------------------------------------------------------------
# Verificação inicial: o binário precisa estar disponível em $HOME/.local/bin
# ---------------------------------------------------------------------------------------------
if [[ ! -x "$HOME/.local/bin/claude.exe" ]]; then
    return 0 2>/dev/null || exit 0
fi

# ---------------------------------------------------------------------------------------------
# CLAUDE_CONFIG_DIR
# O Claude Code procura seu diretório de configuração na seguinte ordem:
#   1. Variável CLAUDE_CONFIG_DIR (se já definida antes de abrir o shell)
#   2. Instalação padrão: $HOME/.claude
#
# Se você adota o padrão XDG de diretórios em seu computador, a variável deve
# apontar para $XDG_CONFIG_HOME/claude (geralmente $HOME/.config/claude).
# ---------------------------------------------------------------------------------------------
if [[ -z "$CLAUDE_CONFIG_DIR" ]]; then
    if [[ -n "$XDG_CONFIG_HOME" ]]; then
        export CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME/claude"
    elif [[ -n "$HOME" ]]; then
        export CLAUDE_CONFIG_DIR="$HOME/.config/claude"
    fi
fi

# Quando CLAUDE_CONFIG_DIR estiver no formato Windows, converte para o formato Unix.
if [[ "$CLAUDE_CONFIG_DIR" == [A-Za-z]:* ]]; then
    export CLAUDE_CONFIG_DIR="$(cygpath -u -- "$CLAUDE_CONFIG_DIR")"
fi

# ---------------------------------------------------------------------------------------------
# Validação das configurações obrigatórias e recomendadas
# ---------------------------------------------------------------------------------------------

# Recebe um nome de variável e verifica se está definida no ambiente ou no settings.json.
_claude_is_set() {
    local key="$1"
    [[ -n "${!key}" ]]                          && return 0  # é variável de ambiente
    [[ "$settings_content" == *"\"$key\""* ]]   && return 0  # está no bloco "env" do settings.json
    return 1  # não foi definida nem no ambiente nem no settings.json
}

# Valida as variáveis e credenciais obrigatórias do Claude Code
_claude_validate_required_config() {

    # Carrega o settings.json do Claude Code (se existir) para validar as variáveis obrigatórias.
    local config_dir="${CLAUDE_CONFIG_DIR%/}"
    local settings_json="$config_dir/settings.json"
    local settings_content=""
    [[ -f "$settings_json" ]] && settings_content="$(< "$settings_json")"

    # --- Validar se CLAUDE_CODE_GIT_BASH_PATH está definida ----------------------------------
    # Validação em ordem de prioridade (linha de comando é ignorada aqui):
    #   1. Variável de ambiente → se definida, foi escolha consciente do dev → OK
    #   2. settings.json        → local esperado pelo projeto (bloco "env")  → OK
    # Não estando em nenhum nível, falha apontando para o settings.json.
    if ! _claude_is_set CLAUDE_CODE_GIT_BASH_PATH; then
        displayFailure \
            "Claude Code" \
            "CLAUDE_CODE_GIT_BASH_PATH não definida → adicione no bloco \"env\" de $settings_json"
    fi

    # --- Validar qual método de autenticação está sendo usado ----------------------------------
    # Métodos explícitos, mutuamente exclusivos (apenas UM deve estar definido):
    #   - ANTHROPIC_API_KEY        → API Key do Console da Anthropic
    #   - ANTHROPIC_AUTH_TOKEN     → Token de AI Gateway / LiteLLM
    #   - CLAUDE_CODE_USE_BEDROCK  → AWS Bedrock   (credenciais geridas pelo AWS SDK)
    #   - CLAUDE_CODE_USE_VERTEX   → GCP Vertex AI (credenciais geridas pelo GCP SDK)
    #   - CLAUDE_CODE_USE_FOUNDRY  → Azure Foundry (API Key / Entra ID, geridas pelo Azure SDK)
    # Cada método é checado no ambiente OU no settings.json (via _claude_is_set).
    #
    # O método padrão de autenticação no Claude Code é o OAuth (ou seja, login Claude AI),
    # e NÃO entra na contagem de conflito: se existe um token salvo em disco e uma das variáveis
    # acima foi definida, o token é ignorado silenciosamente.
    # ------------------------------------------------------------------------------------------
    local auth_methods=()
    _claude_is_set ANTHROPIC_API_KEY       && auth_methods+=("ANTHROPIC_API_KEY")
    _claude_is_set ANTHROPIC_AUTH_TOKEN    && auth_methods+=("ANTHROPIC_AUTH_TOKEN")
    _claude_is_set CLAUDE_CODE_USE_BEDROCK && auth_methods+=("CLAUDE_CODE_USE_BEDROCK")
    _claude_is_set CLAUDE_CODE_USE_VERTEX  && auth_methods+=("CLAUDE_CODE_USE_VERTEX")
    _claude_is_set CLAUDE_CODE_USE_FOUNDRY && auth_methods+=("CLAUDE_CODE_USE_FOUNDRY")

    local n=${#auth_methods[@]}

    if (( n > 1 )); then
        # Conflito: mais de um provedor/credencial explícito definido.
        displayFailure \
            "Claude Code" \
            "Múltiplos métodos de autenticação definidos — use apenas um: ${auth_methods[*]}"
    fi

    # --- Validar se arquivo settings.json existe ----------------------------------------------
    if [[ ! -f "$settings_json" ]]; then
        displayWarning \
            "Claude Code" \
            "settings.json não encontrado: $settings_json"
    fi

}

_claude_validate_required_config

# Limpar funções auxiliares do escopo global
unset -f _claude_validate_required_config _claude_is_set

#----------------------------------------------------------------------------------------------
#--- Final do script claude-code-envs.sh
#----------------------------------------------------------------------------------------------