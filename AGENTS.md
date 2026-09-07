# AGENTS.md

Instruções normativas para agentes autônomos de desenvolvimento de código (**GitHub Copilot**, **OpenCode**, **Google Antigravity**, **Claude Code CLI** e similares) atuando neste repositório.

---

## 1. Escopo e Papel do Agente

* **Objetivo do Repositório**: Framework modular de configuração Bash voltado para desenvolvedores no Windows que utilizam o **Git Bash**. Implementa as especificações **XDG Base Directory** e **FHS** para manter o diretório pessoal limpo e o drive de sistema (`C:`) preservado através de Junções NTFS.
* **Papel do Agente**: Criar, modificar, refatorar, testar e evoluir shell scripts e documentação respeitando as restrições arquiteturais e de runtime estabelecidas abaixo.

---

## 2. Restrições Operacionais Estritas (Directives)

### 2.1 Shell de Execução Obrigatório: Git Bash (`bash.exe`)
* **PROIBIDO O USO DO POWERSHELL**: Agentes de código **NÃO** devem executar comandos via PowerShell para interagir com o repositório ou inspecionar arquivos.
* **Execução via `bash.exe`**: Todas as ações de terminal, comandos de compilação/teste, verificações e invocações de utilitários devem ser despachadas diretamente para o executável `bash.exe` do Git Bash (MSYS2) utilizando comandos e sintaxe nativos POSIX (`ls`, `cat`, `grep`, `find`, `sed`, `awk`, etc.).

### 2.2 Fonte da Verdade e Separação de Diretórios
* **Payload em `src/home/`**: O diretório `src/home/` espelha rigorosamente a raiz do `$HOME` (`~/`) do usuário final. Modificações em dotfiles (`.bashrc`, `.bash_profile`), configurações (`.config/bashrc/`) ou executáveis (`bin/`) devem ser realizadas exclusivamente sob `src/home/`.
* **Isolamento do `$HOME` Real**: Agentes **NUNCA** devem modificar ou sobrescrever arquivos reais no `$HOME` do usuário durante desenvolvimento, testes ou validações. A sincronização para `$HOME` cabe unicamente ao usuário por meio de `scripts/install.sh`.
* **Arquivos Temporários e Rascunhos**: Todo artefato efêmero, script de teste exploratório, backlog ou rascunho de documentação deve ser alocado na pasta `EXTRAS/` (ignorada no `.gitignore`).

### 2.3 Invariante do Manifesto (`scripts/install-manifest.txt`)
* O arquivo `scripts/install-manifest.txt` é a **fonte da verdade** do instalador (`scripts/install.sh`) e do backup (`scripts/backup.sh`).
* **Regra Mandatória**: Qualquer arquivo novo criado em `src/home/`, bem como remoções ou renomeações, **DEVE** ser obrigatoriamente refletido em `scripts/install-manifest.txt`. A omissão deste passo resulta em descompasso de instalação.

---

## 3. Padrões de Implementação Shell e Regras de Runtime

### 3.1 Scripts Sourced de Inicialização (`src/home/.config/bashrc/*.sh`)
Scripts carregados pelo `~/.bashrc` rodam no contexto interativo principal da sessão do usuário. As seguintes regras são absolutas:

* **PROIBIDO `set -e`, `set -u` ou `set -o pipefail`**: Ativar essas diretivas fecha o terminal do usuário caso um comando retorne status diferente de zero.
* **PROIBIDO `exit`**: Jamais use `exit` em scripts sourced (isso encerra a sessão ativa). Para saídas antecipadas seguras, use:
  ```bash
  return 0 2>/dev/null || exit 0
  ```
* **Degradação Graciosa**: Se uma dependência ou caminho estiver ausente, emita feedback com as funções padrão (`displayWarning` ou `displayFailure`) sem interromper a carga dos demais scripts.
* **Performance no Shell Startup**: Todo shell aberto pelo usuário executa esses scripts. O caminho feliz (*happy path*) deve ter **zero forks de processo**:
  * Utilize built-ins do Bash sempre que possível.
  * Utilize expansão de parâmetros (`${var%/*}`, `${var##*/}`, `${var,,}`) em vez de invocar `cut`, `awk` ou `sed`.
  * Adote guardas de teste antes de invocar subshells: `[ -d "$dir" ] || mkdir -p "$dir"`.
* **Higiene do Escopo Global**:
  * Remova variáveis de controle de loops e temporárias ao final do script: `unset rc _temp_var`.
  * Remova funções auxiliares privadas que não devam permanecer exportadas para a sessão do usuário: `unset -f _helper_function`.

### 3.2 Scripts Standalone Executáveis (`scripts/*.sh`, `src/home/bin/*`)
Scripts executados diretamente pelo usuário ou no `$PATH`:

* **Shebang Obrigatório**: `#!/bin/bash`.
* **Tratamento Estrito de Erros**: Utilize `set -euo pipefail` no topo de scripts de instalação e manutenção para impedir execução parcial em caso de falhas.
* **Validação de Argumentos**: Valide número e formato de argumentos recebidos e exiba mensagens informativas em caso de parâmetros incorretos.
* **Reutilização de Helpers**: Mantenha lógica compartilhada em `src/home/bin/helpers/` ou `scripts/common.sh`.

### 3.3 Funções de Interface Padronizadas (UI Functions)
Utilize as funções de exibição padronizadas declaradas em `bash-functions.sh` e `common.sh`:
* `displayTitle "Texto"`: Cabeçalho principal.
* `displayAction "Ação"`: Indicação de etapa em andamento.
* `displayInfo "Rótulo" "Mensagem"`: Informação contextualmente relevante.
* `displaySuccess "Rótulo" "Mensagem"`: Sucesso da operação.
* `displayWarning "Rótulo" "Mensagem"`: Aviso ou degradação não-fatal.
* `displayFailure "Rótulo" "Mensagem"`: Falha detectada.

---

## 4. Arquitetura de Carregamento e Nomenclatura

### 4.1 Ordem de Carregamento no `.bashrc`
O carregamento segue estritamente três fases:

| Fase | Arquivos | Critério de Carregamento | Justificativa |
| :--- | :--- | :--- | :--- |
| **1. Núcleo** | `bash-envs.sh`<br>`bash-functions.sh` | Explícito (nome fixo, primeiro) | Estabelece variáveis base (`APPS_BASE`), caminhos padrão e funções de UI (`display*`) necessárias a todos os outros scripts. |
| **2. Ferramentas** | Demais scripts `*.sh` | Glob em ordem alfabética | A ordenação natural garante que `-envs.sh` execute antes de `-folders.sh` para cada ferramenta. |
| **3. Junções** | `bash-junctions.sh` | Explícito (nome fixo, último) | Depende de variáveis de diretório e caminhos definidos pelos scripts anteriores para criar as junções NTFS. |

### 4.2 Sufixos de Nomenclatura Mandatórios
* `<ferramenta>-envs.sh`: Define variáveis de ambiente, inclusões no `$PATH` e aliases curtos específicos da ferramenta.
* `<ferramenta>-folders.sh`: Valida ou cria diretórios e ajusta `$PATH` dependente das variáveis estabelecidas no respectivo `-envs.sh`.
* `<ferramenta>-functions.sh`: Declara funções shell complexas ou helpers auxiliares para o terminal.
* `<ferramenta>-aliases.sh`: Declara aliases extensos (quando separados do `-envs.sh`).
* **PROIBIÇÃO**: **NÃO** utilize prefixos numéricos (ex.: `01-`, `10-`) nos nomes de arquivos. A ordem de precedência entre variáveis e diretórios é regida exclusivamente pelos sufixos em ordem alfabética (`-envs` antecede `-folders`).

---

## 5. Interoperabilidade Windows e Junções NTFS

* **Padrão de Caminhos no Shell**: Scripts internos devem usar exclusivamente o formato Unix/POSIX (`/c/Users/...`, `/d/...`).
* **Caminhos Nativos Windows**: Utilize `cygpath -w` apenas ao repassar parâmetros para utilitários nativos Win32 (como `cmd.exe` ou instaladores `.exe`/`.msi`).
* **Criação de Junções NTFS**:
  * Invocação obrigatória via `cmd.exe` com neutralização de conversão de parâmetros:
    ```bash
    MSYS_NO_PATHCONV=1 cmd //c "mklink /J \"$src_w\" \"$tgt_w\""
    ```
  * **Política Estritamente Não-Destrutiva**: Se o caminho de origem em `%USERPROFILE%` existir como diretório ou arquivo físico real, **NUNCA** o remova automaticamente. Emita `displayFailure` e instrua o usuário a migrar os dados manualmente.

---

## 6. Procedimento Operacional: Adicionando Suporte a Nova Ferramenta

Ao adicionar suporte a um novo utilitário ou ecossistema (ex.: `terraform`):

1. **Definição de Ambiente**: Criar `src/home/.config/bashrc/<tool>-envs.sh` exportando variáveis conforme especificação XDG e incluindo binários no `$PATH`.
2. **Estrutura de Pastas (Opcional)**: Se a ferramenta demandar diretórios de cache/estado locais, criar `src/home/.config/bashrc/<tool>-folders.sh` com validação prévia (`[ -d ] || mkdir -p`).
3. **Helpers e Executáveis (Opcional)**:
   * Criar wrappers ou scripts executáveis em `src/home/bin/<tool>-*`.
   * Criar scripts auxiliares em `src/home/bin/helpers/<tool>-*.sh`.
4. **Registro no Manifesto**: Adicionar imediatamente todos os novos arquivos em `scripts/install-manifest.txt`.
5. **Validação de Sintaxe**: Validar os scripts via `bash -n <arquivo.sh>` para assegurar ausência de erros léxicos ou de parse.

---

## 7. Convenções de Idioma e Mensagens de Commit

* **Idioma de Documentação e Comentários**: Todo texto descritivo, documentação (`README.md`, `AGENTS.md`, docs sob `.local/share/`) e comentários de código inline devem ser redigidos em **português do Brasil (`pt-BR`)**.
* **Identificadores de Código**: Nomes de variáveis, funções, comandos e arquivos devem permanecer em **inglês**.
* **Formato de Mensagens de Commit**:
  * **Cabeçalho**: `<tipo>: <resumo em pt-BR, indicativo claro, ≤ ~50 caracteres>`
    * Tipos aceitos: `feat`, `fix`, `refactor`, `perf`, `docs`, `style`, `test`, `build`, `chore`, `ci`.
  * **Corpo Estruturado (Opcional, utilizar heredoc entre aspas `<<'EOF'` para segurança)**:
    * `Motivo:` Contexto, necessidade ou problema motivador.
    * `Mudança:` Descrição técnica do que foi implementado.
    * `Impacto:` Implicações na sessão, dependências ou compatibilidade.
