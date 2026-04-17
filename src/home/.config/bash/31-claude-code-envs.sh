
# Este script exporta variáveis de ambiente do Claude Code no Git Bash.
# A gestão do certificado raiz é feita em um script separado: 31-claude-code-cert.sh.

# Configuração da localização do Git Bash - requisito do terminal integrado do Claude Code no Windows
_GIT_BASH_EXE="echo $(/bin/df / | grep ' /$' | awk '{print $1}')${BASH}.exe | tr '/' '\\\'"
export CLAUDE_CODE_GIT_BASH_PATH="${CLAUDE_CODE_GIT_BASH_PATH:-$_GIT_BASH_EXE}"
unset _GIT_BASH_EXE

# Configuração de Diretório XDG para o Claude Code
export CLAUDE_CONFIG_DIR="${CLAUDE_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/claude}"
mkdir -p "$CLAUDE_CONFIG_DIR"

# Alternativa ao uso de LLM's na Anthropic: configurar um AI Gateway (p.ex: LiteLLM)
# export ANTHROPIC_BASE_URL="${ANTHROPIC_BASE_URL:-https://your-lite-llm-gateway.com}"
# export ANTHROPIC_MODEL="${ANTHROPIC_MODEL:-claude-sonnet-4-6}"
# export ANTHROPIC_AUTH_TOKEN="${ANTHROPIC_AUTH_TOKEN:-seu-token-sk-litellm}"

# Desativa tráfego não essencial para a Anthropic (verificação de atualizações, análises, etc)
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1

# Desativa coleta e envio de dados de telemetria para a Anthropic
export CLAUDE_CODE_DISABLE_TELEMETRY=1

#-------------------------------------------------------------------------------------------
#--- Final do script claude-code-envs.sh
#-------------------------------------------------------------------------------------------