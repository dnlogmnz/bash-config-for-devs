# 🤖 Guia do Bash RC for Devs: Claude Code

O **Claude Code** é uma ferramenta de linha de comando (CLI) desenvolvida pela Anthropic. Diferente de IDEs de copiloto, ele opera diretamente no terminal, atuando como um agente que permite interagir com a base de código, executar comandos, realizar testes, e realizar refatorações automatizadas.

Embora seja executado no terminal (como o Git Bash), o Claude Code pode ser perfeitamente usado através dos **terminais integrados** de IDEs como VS Code, PyCharm, IntelliJ, entre outras. Ou seja, o Claude Code em seu computador executa comandos tanto dentro do Git Bash for Windows, como também fora dele.

O propósito do **Bash RC for Devs** é definir variáveis de ambiente para o Git Bash for Windows. Mas devido à natureza do Claude Code, será necessário definir algumas variáveis de ambiente fora do escopo do **Bash RC for Devs**.

Abaixo, explicamos como configurar seu ambiente para extrair o máximo do Claude Code.

---

## 1. Níveis e Hierarquia de Precedência

O Claude Code busca configurações em seis camadas. Se uma variável estiver definida em duas camadas, a de menor número (mais específica) vence:

### Nível 1: Terminal: Flags na Linha de Comando
- **Onde:** Ao executar o Claude Code CLI diretamente na linha de comandos (ex: `claude --model claude-3-5-sonnet-20241022`).
- **Uso:** Para algum teste específico, ou alguma configuração particular para scripts de automação.

### Nível 2: Terminal: Variáveis de Ambiente do Shell
- **Onde:** Definidas via `export` no Bash ou via script `$HOME/.config/bash/31-claude-code-envs.sh`.
- **Uso:** Configurações temporárias ou atalhos que afetam apenas o terminal aberto no momento.

### Nível 3: Claude Code: Arquivo de Configurações Pessoais de Projeto
- **Onde:** Pasta raiz do repositório atual (`PROJETO/.claude/settings.local.json`)
- **Uso:** Preferências pessoais do desenvolvedor que **não devem** ser versionadas no Git (inclua este arquivo no `.gitignore`).

### Nível 4: Claude Code: Arquivo de Configurações de Projeto
- **Onde:** Pasta raiz do repositório atual (`PROJETO/.claude/settings.json`)
- **Uso:** Definições e configurações para a equipe inteira usar, garantindo consistência no uso do Claude Code, e que **devem** ser versionadas no Git.

### Nível 5: Claude Code: Arquivo de Configurações Globais
- **Onde:** Arquivo `%USERPROFILE%\.claude\settings.json`
- **Uso:** Preferências de interface, telemetria e modelos que valem para qualquer projeto em sua máquina.

### Nível 6: Windows: Variáveis de Ambiente do Usuário
- **Onde:** "Editar variáveis de ambiente para sua conta".
- **Uso:** Definições estruturais. É o local mais seguro para a `ANTHROPIC_API_KEY`, garantindo que ela esteja disponível para IDEs, PowerShell e Git Bash simultaneamente.

---

## 2. Configuração de Variáveis

Para o projeto **Bash RC for Devs**, recomendamos a seguinte distribuição de variáveis:

### 🌐 Configurações de Sistema (Sessão Windows / Nível 6)
Estas variáveis garantem que o "motor" do Claude Code (Node.js) e a integração com o Windows funcionem corretamente:

- **`ANTHROPIC_API_KEY`**: Sua chave de acesso.
- **`CLAUDE_CODE_GIT_BASH_PATH`**: Caminho para o `bash.exe` (ex: `C:\Program Files\Git\bin\bash.exe`).
- **`NODE_EXTRA_CA_CERTS`**: Essencial se você estiver atrás de um proxy corporativo com inspeção SSL.
- **`CLAUDE_CONFIG_DIR`**: Se desejar mover a pasta de configuração global para outro drive.

### 👤 Preferências Globais (JSON Usuário / Nível 5)
Configure no seu `%USERPROFILE%\.claude\settings.json`:

```json
{
  "env": {
    "ANTHROPIC_MODEL": "claude-sonnet-4-6",
    "CLAUDE_CODE_DISABLE_TELEMETRY": "1",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1"
  }
}
```

### 🛡 Segurança do Projeto (Nível 4)

Um `.claude/settings.json` na raiz do seu projeto pode impor limites ao agente:

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "allow": ["Bash(git status)", "Bash(npm test)"],
    "deny": ["Read(./.env)", "Read(./secrets/**)", "Bash(rm -rf *)"]
  }
}
```

### 🐚 Atalhos de Shell (Bash / Nível 2)
No arquivo `31-claude-code-envs.sh`:
```bash
# Atalho rápido para iniciar o agente
alias c="claude"
# Forçar modo compacto em telas menores
export CLAUDE_CODE_COMPACT=1
```

---

## 4. Resumo de Caminhos

| Configuração | Caminho / Local | Escopo |
| :--- | :--- | :--- |
| **Global JSON** | `%USERPROFILE%\.claude\settings.json` | Usuário |
| **Shared JSON** | `<PROJETO>\.claude\settings.json` | Projeto (Git) |
| **Local JSON** | `<PROJETO>\.claude\settings.local.json` | Pessoal |
| **Bash Setup** | `$HOME/.config/bash/31-claude-code-envs.sh` | Git Bash |
| **API Keys** | Variáveis de ambiente para sua conta | Windows |

