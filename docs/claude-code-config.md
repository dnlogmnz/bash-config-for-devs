# Importância do Claude Code

O Claude Code é um agente de IA essencial para Desenvolvedores que trabalham com Git Bash no Windows. Integrado ao VS Code, PyCharm e outras IDEs, ele oferece autocompletar inteligente, refatorações de código e automação de tarefas de desenvolvimento, economizando tempo e reduzindo erros.

O **Bash RC for Devs** está voltado a definir variáveis de ambiente para o Git Bash no Windows, mas o Claude Code pode ser usado não apenas no `bash`, mas também na extensão para VS Code, PyCharm e outras IDE's. Isso quer dizer que algumas variáveis podem - e devem - ser definidas de diferentes formas.

Este documento apresenta informações úteis para o Dev que deseja usar o Claude Code (tanto o CLI quanto as extensões para o VS Code, PyCharm e outras IDEs).

# 1. Onde configurar variáveis do Claude Code

Existem três locais principais para configurar variáveis que o Claude Code pode usar:

1. App Windows "Editar as variáveis de ambiente para sua conta"
   - Aplica-se a todos os terminais do usuário no Windows, incluindo Prompt de Comandos, PowerShell, e extensões para VS Code, PyCharm e outras IDE's
   - É o local mais recomendável para definir configurações obrigatórias, que serão válidas tanto dentro quanto fora do Git Bash
2. Shell script de startup (Run Command) do Git Bash
   - No **Bash RC for Devs**: `$HOME/.config/bash/31-claude-code-envs.sh`
   - Aplica-se apenas ao ambiente do Git Bash
   - Útil para variáveis específicas de shell e para scripts que só executam em Bash
3. Arquivo de configuração do Claude Code
   - Global, para todos os projetos em um computador: `%USERPROFILE%/.claude/settings.json` **(*)**
   - Para um projeto específico: `<base-do-projeto>/.claude/settings.json`

> **(*)**: *Em um computador rodando Windows, a variável `%USERPROFILE%` normalmente aponta para `C:\Users\<usuário>`.*

## Regra de precedência:

Quando uma variável é definida em múltiplos locais, a ordem de precedência (da menor para a maior) é:

1. **Variáveis definidas no app Windows** ("Editar as variáveis de ambiente para sua conta")
2. **Variáveis definidas em arquivo `settings.json` global** (`%USERPROFILE%/.claude/settings.json`)
3. **Variáveis definidas em arquivo `settings.json` de projeto** (`<PROJETO>/.claude/settings.json`)
4. **Variáveis definidas em shell scripts** (ex: `$HOME/.config/bash/31-claude-code-envs.sh`)
5. **Variáveis definidas na linha de comando** (shell interativo ou script em execução)

> **Exemplo**: *se você define `CLAUDE_CODE_DISABLE_TELEMETRY=1` no app Windows, e depois abre um Git Bash ou no Prompt de Comandos e define explicitamente `CLAUDE_CODE_DISABLE_TELEMETRY=0`, esta última definição terá precedência e o valor será `0` para aquele shell.*

# 2. Arquivo contendo o certificado raiz

## Porque o arquivo é necessário

O Claude Code é construído sobre Node.js, que em ambiente corporativo pode não conseguir acessar automaticamente o certificado raiz do Windows.

Quando você estiver atrás de um proxy corporativo ou em uma rede com certificados customizados, é essencial apontar explicitamente as variáveis `SSL_CERT_FILE` e `NODE_EXTRA_CA_CERTS` para o arquivo de certificado raiz. Sem isso, o Claude Code poderá falhar ao tentar conectar-se aos servidores de IA, mesmo que seu navegador funcione normalmente.  

## Tratamento dado pelo **Bash RC for Devs**

Este projeto contém dois scripts definindo as variáveis que determinama localização do arquivo de certificado raiz que será usado pelo Claude Code (tanto pelo CLI quanto pela extensão do VS Code):

- `$HOME/.config/bash/31-claude-code-cert.sh`
  - Baixa e gerencia o certificado raiz em `$HOME/.config/certs/ca_root.pem`
  - Atualiza o arquivo apenas se ele não existir ou se o fingerprint SHA256 mudar
  - Verifica se o certificado está válido por pelo menos 24 horas
  - Exporta `SSL_CERT_FILE` e `NODE_EXTRA_CA_CERTS`
- `$HOME/.config/bash/31-claude-code-envs.sh`
  - Define apenas variáveis de ambiente do Claude Code
  - Configura o caminho do Git Bash para o terminal integrado do Claude Code no Windows

## Atualização automática do arquivo de certificado

O script `$HOME/.config/bash/31-claude-code-cert.sh` utiliza o fingerprint SHA256 para detectar mudanças reais do certificado raiz.

- **Fingerprint**
  - É o hash do certificado completo
  - Se o certificado mudar, o fingerprint muda imediatamente
  - É a forma mais confiável de saber se o arquivo baixado é diferente do arquivo existente

- **Issuer**
  - É a autoridade emissora do certificado
  - Pode ser igual mesmo se o certificado específico mudar (por exemplo, renovação pela mesma CA)
  - É útil para saber se a cadeia de confiança permanece na mesma CA, mas não substitui a verificação por fingerprint

## 3. Definir variáveis obrigatórias no app Windows

### Por que usar o app do Windows

- Garante que a variável exista em todos os terminais do Windows
- Garante que o Claude Code (tanto o CLI quanto a extensão do VS Code) detecte a configuração mesmo fora do Git Bash
- É o local para definir valores obrigatórios para o usuário

### Definir as variáveis

Abrir o app "Editar as variáveis de ambiente para sua conta", e adicionar as seguintes variáveis:

- `SSL_CERT_FILE=%USERPROFILE%\.config\certs\ca_root.pem`
- `NODE_EXTRA_CA_CERTS=%USERPROFILE%\.config\certs\ca_root.pem`

## 4. Arquivo global `%USERPROFILE%/.claude/settings.json`

Use `%USERPROFILE%/.claude/settings.json` para configurações pessoais que devem valer em **todos os seus projetos**. Este arquivo fica no seu `$HOME` (pasta do usuário) e é lido pelo Claude Code automaticamente.

Exemplo:

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "env": {
    "CLAUDE_CODE_DISABLE_TELEMETRY": "1",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1"
  },
  "permissions": {
    "allow": [
      "Bash(npm run lint)",
      "Bash(npm test *)"
    ],
    "deny": [
      "Bash(curl *)",
      "Read(./.env)",
      "Read(./secrets/**)"
    ]
  }
}
```

### Quando usar este arquivo

- Quando você quiser aplicar configurações a todos os seus projetos (ex: telemetria desativada, permissões pessoais)
- Quando quiser um ponto centralizado para políticas de segurança pessoais (ex: bloquear `curl` globalmente)
- Quando não for necessário ou desejável compartilhar a configuração com sua equipe

## 5. Arquivo de projeto `.claude/settings.json`

Use `.claude/settings.json` (na raiz do seu repositório) para configurações que devem ser **compartilhadas com toda a equipe**. Este arquivo é versionado no Git e garante que todos os desenvolvedores usem as mesmas políticas.

Exemplo:

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "env": {
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1"
  },
  "permissions": {
    "allow": [
      "Bash(git status)",
      "Read(./README.md)"
    ],
    "deny": [
      "Bash(curl *)",
      "Read(./.env)",
      "Read(./secrets/**)"
    ]
  }
}
```

### Quando usar este arquivo

- Quando precisar que toda a equipe use as mesmas permissões (ex: permissão para `npm run lint` e `npm test`)
- Quando quiser garantir que arquivos sensíveis (ex: `.env`, `secrets/**`) não sejam acessados pelo Claude Code
- Quando quiser documentar e versionar políticas de segurança do projeto no Git

## 7. Observações úteis

- Variáveis definidas no app Windows têm efeito fora do Git Bash e em todas as IDEs
- Variáveis definidas em `$HOME/.config/bash/31-claude-code-envs.sh` têm efeito apenas no Git Bash
- Configurações de projeto em `<PROJETO>/.claude/settings.json` têm precedência sobre `%USERPROFILE%/.claude/settings.json` (veja seção 1 para hierarquia completa)
- Se você precisar de um override pessoal em um projeto sem versioná-lo, use `.claude/settings.local.json` e adicione esse arquivo ao `.gitignore`
- As variáveis de ambiente exportadas pelos scripts (ex: `SSL_CERT_FILE`, `CLAUDE_CODE_DISABLE_TELEMETRY`) afetam o Claude Code CLI, a extensão VS Code e qualquer processo filho

