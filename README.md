# Bashrc for Devs 🚀

Um framework modular e padronizado de configuração Bash para desenvolvedores Windows que utilizam o **Git Bash**.

O **`bashrc-for-devs`** organiza o ambiente de desenvolvimento adotando as especificações **XDG Base Directory** e **FHS (Filesystem Hierarchy Standard)**. Ele desacopla ferramentas e linguagens do drive de sistema (`C:`), mantém o diretório `$HOME` limpo e livre de arquivos ocultos (*dotfiles*) dispersos, e integra ferramentas nativas do Windows de forma transparente via Junções NTFS.

---

## 🎯 Por que usar este projeto?

No Windows, ambientes de desenvolvimento frequentemente sofrem com:
* **Poluição do diretório pessoal (`%USERPROFILE%` / `$HOME`)**: Dezenas de ferramentas CLI (Git, AWS, Python, Node, Claude, Docker) criam arquivos e pastas ocultas na raiz do seu perfil.
* **Arquivos `.bashrc` monolíticos**: Centenas de linhas desordenadas misturando variáveis de ambiente, aliases pessoais, certificados e configurações de runtime.
* **Pressão de espaço no disco de sistema (`C:`)**: O acúmulo de caches de compiladores, dependências e dados de CLIs sobrecarrega o drive do sistema operacional.

### O que o `bashrc-for-devs` resolve:
* **Conformidade XDG**: Configurações em `~/.config`, dados em `~/.local/share`, logs/sessões em `~/.local/state` e caches temporários em `~/.cache`.
* **Separação por Unidade de Disco**: Permite que o `$HOME` e as aplicações (`APPS_BASE`) fiquem em um drive dedicado (ex.: `D:\<USUARIO>\home` e `D:\<USUARIO>\Apps`), reservando o drive `C:` exclusivamente para o Windows.
* **Junções NTFS Transparentes**: Aplicações Windows que insistem em gravar em `C:\Users\%USERNAME%\.aws` ou `.claude` são redirecionadas silenciosamente para o seu `$HOME` sem necessidade de privilégios de Administrador.
* **Suíte de Utilitários Prontos**: Comandos integrados ao terminal para gerenciamento leve de versões do Node.js, scaffolding de projetos Python modernos com `uv`, diagnóstico de ambiente e helpers de Git.

---

## 📋 Pré-requisitos

* **Sistema Operacional**: Windows 10 ou Windows 11.
* **Shell**: [Git for Windows](https://gitforwindows.org/) (com Git Bash instalado).
* **Variáveis de Ambiente Recomendadas (Opcional, mas Altamente Recomendado)**:
  Caso queira isolar seu `$HOME` e suas ferramentas do drive `C:`, configure as seguintes variáveis no menu *"Editar variáveis de ambiente para sua conta"* do Windows:
  * `HOME`: `D:\%USERNAME%\home` (caminho para seu diretório pessoal)
  * `APPS_BASE`: `D:\%USERNAME%\Apps` (pasta base de aplicativos e CLIs)
  * `XDG_BIN_DIR`: `D:\%USERNAME%\home\bin`
  * `XDG_CACHE_HOME`: `D:\%USERNAME%\home\.cache`
  * `XDG_CONFIG_HOME`: `D:\%USERNAME%\home\.config`
  * `XDG_DATA_HOME`: `D:\%USERNAME%\home\.local\share`
  * `XDG_STATE_HOME`: `D:\%USERNAME%\home\.local\state`

  > [!IMPORTANT]
  > Dependendo de como um processo do shell é invocado, o Windows pode não expandir variáveis dinâmicas aninhadas. Por isso, ao adicionar essas variáveis, **substitua `%USERNAME%` pelo nome real da sua conta de usuário**. 

---

## ⚡ Instalação e Início Rápido

Abra o seu **Git Bash** e execute os passos abaixo a partir da raiz do repositório clonado:

### 1. Fazer Backup Preventivo (Recomendado)
Antes de qualquer alteração, gere um backup seguro de todos os arquivos de configuração atuais que seriam sobrescritos:

```bash
./scripts/backup.sh
```
> [!NOTE]
> Os arquivos são arquivados com data e hora em `$XDG_STATE_HOME/bashrc/backups/` (ou `~/.local/state/bashrc/backups/`). O processo é 100% não-destrutivo.

### 2. Instalar os Arquivos
Execute o script de instalação orientado pelo manifesto de arquivos do projeto:

```bash
./scripts/install.sh
```

O instalador copia a estrutura para o seu `$HOME` e configura:
* `~/.bashrc` e `~/.bash_profile`
* Diretórios de inicialização em `~/.config/bashrc/`
* Utilitários executáveis em `~/bin/`
* Templates e documentação em `~/.local/share/bashrc/`

### 3. Ativar as Configurações
Para que o novo ambiente entre em vigor com todas as variáveis e junções atualizadas, você deve fechar:

   * Todas as sessões abertas do **Git Bash** (avulsas e integradas).
   * Suas **IDEs** (VS Code, PyCharm, OpenCode) e **assistentes de código** (Google Antigravity, Claude Desktop).

Ao iniciar um novo terminal, o fluxo de inicialização normal do bash executará automaticamente os scripts RC deste projeto.

### 4. Validar o Ambiente
Execute o comando de diagnóstico incluído para checar a detecção das suas ferramentas:

```bash
show-versions
```

---

## 🏛️ Como o Ambiente Funciona

### Estrutura de Diretórios no seu `$HOME`

Após a instalação, seus arquivos estarão organizados conforme o padrão XDG/FHS:

| Diretório | Finalidade |
| :--- | :--- |
| `~/.bashrc` | Ponto de entrada central para shells interativos. Define variáveis XDG e carrega os módulos. |
| `~/.bash_profile` | Ponto de entrada para login shells; delega a inicialização diretamente ao `.bashrc`. |
| `~/.config/bashrc/` | Scripts modulares carregados em etapas na abertura do terminal. |
| `~/bin/` | Utilitários do projeto adicionados automaticamente ao `$PATH` pelo Git Bash. |
| `~/.local/bin/` | Binários instalados pelo Windows ou usuário (ex.: `claude.exe`, `jq.exe`). |
| `~/.local/share/bashrc/` | Templates de projetos, exemplos de configuração e documentações auxiliares. |
| `~/.local/state/` | Histórico do Bash, histórico do Python e backups do instalador. |
| `~/.cache/` | Caches de ferramentas como `uv`, gerenciadores de pacotes e linters. |

---

### Junções NTFS Transparentes (`bash-junctions.sh`)

Muitos utilitários e CLIs nativos do Windows não respeitam variáveis XDG ou a variável POSIX `HOME` e tentam criar pastas diretamente em `C:\Users\%USERNAME%`.

Quando seu `$HOME` está configurado em outro caminho (como `D:\...`), o módulo `bash-junctions.sh` cria automaticamente **Junções de Diretório NTFS** (`mklink /J`) para redirecionar essas pastas:

```
C:\Users\%USERNAME%\.aws      ──(Junction)──►  D:\<USUARIO>\home\.aws
C:\Users\%USERNAME%\.claude   ──(Junction)──►  D:\<USUARIO>\home\.config\claude
C:\Users\%USERNAME%\.config   ──(Junction)──►  D:\<USUARIO>\home\.config
C:\Users\%USERNAME%\.local    ──(Junction)──►  D:\<USUARIO>\home\.local
C:\Users\%USERNAME%\.ssh      ──(Junction)──►  D:\<USUARIO>\home\.ssh
```

> [!IMPORTANT]
> **Política Não-Destrutiva**: Se uma pasta já existir em `%USERPROFILE%` como diretório real (e não como junção), o script **não** a apaga nem sobrescreve. Ele emite um aviso no terminal orientando você a migrar os dados e criar a junção com segurança.

---

## 🧰 Utilitários de Linha de Comando Inclusos (`~/bin/`)

O repositório disponibiliza comandos utilitários prontos para o uso diário:

### 🔍 Diagnóstico e Informações
* **`show-versions`**: Exibe um resumo consolidado das versões de runtimes, CLIs de Cloud (AWS, GCP), Docker, Git e ferramentas de desenvolvimento instaladas.
* **`claude-info`**: Exibe o status da instalação, versão, diretório de configuração XDG e estado de autenticação do Claude Code.
* **`git-info`**: Apresenta informações detalhadas do repositório Git local (branch atual, status, commits recentes, remotes).

### 🟢 Gerenciamento de Versões do Node.js
Dispensa gerenciadores pesados quando você utiliza versões descompactadas do Node.js sob `$APPS_BASE`:
* **`node-list`**: Lista todas as versões do Node.js disponíveis em `$NODE_HOME`, indicando qual está marcada como padrão (*default).
* **`node-default <versao>`**: Alterna a versão ativa do Node.js criando ou atualizando a junção para o binário padrão.
* **`node-install <versao>`**: Auxilia na instalação ou configuração de uma nova versão do Node.js.
* **`node-info`**: Detalha os caminhos de execução do `node` e `npm` ativos na sessão.

### 🐍 Automação de Projetos Python com `uv`
Scaffolding instantâneo de projetos seguindo boas práticas de empacotamento:
* **`uv-new-app <nome>`**: Cria uma aplicação Python estruturada em `src layout` com gerenciamento de dependências pelo `uv`.
* **`uv-new-lib <nome>`**: Cria uma biblioteca Python modular empacotada pronta para distribuição.
* **`uv-new-project <nome>`**: Inicializa um projeto Python padrão com `pyproject.toml` e `.python-version`.
* **`uv-new-backend <nome>`**: Cria uma base de backend completa com FastAPI / dependências modernas.
* **`uv-new-poc <nome>`**: Cria rapidamente uma estrutura para Prova de Conceito (PoC) com scripts e notebooks isolados.
* **`uv-info`**: Exibe versões do Python gerenciadas pelo `uv` e detalhes do ambiente virtual ativo.

### 🐙 Helpers de Git e Produtividade
* **`git-branch`**: Visualização formatada e limpa de branches locais e remotas com status de sincronização.
* **`git-config`**: Valida e exibe as configurações globais ativas do Git (`user.name`, `user.email`, `core.editor`).
* **`git-merge-tests`**: Auxilia na validação e merge seguro de branches de teste.
* **`urlencode <texto>` / `urldecode <texto>`**: Utilitários rápidos para codificar e decodificar strings no padrão URL.
* **`echodo <comando>`**: Exibe o comando formatado antes de executá-lo (ótimo para scripts de automação e tutoriais).

---

## 📑 Templates de Configuração

Localizados em `~/.local/share/bashrc/templates/`, esses modelos ajudam a padronizar seus projetos e ferramentas:

* **Python e uv**:
  * `python/pyproject.toml.example`: Configuração base completa com metadados do projeto e ferramentas.
  * `python/ruff.toml.example`: Regras recomendadas de linting e formatação com Ruff.
  * `python/uv.toml.example`: Preferências de resolução e cache do `uv`.
  * `dot-env.example`: Modelo para variáveis de ambiente `.env`.
* **Editores e Assistentes**:
  * `vscode/settings.json`: Configurações recomendadas para o VS Code integrado ao Git Bash e runtimes XDG.
  * `claude/home-dot-claude-settings.json`: Configurações globais para o Claude Code.
  * `claude/project-dot-claude-settings.json`: Configurações locais para projetos assistidos por IA.

---

## 🔄 Manutenção e Atualizações

### Atualizando seu Ambiente
Quando novas melhorias ou utilitários forem adicionados ao repositório:

1. Atualize o repositório local:
   ```bash
   git pull origin main
   ```
2. Reexecute a instalação para sincronizar os arquivos atualizados em seu `$HOME`:
   ```bash
   ./scripts/install.sh
   ```

### Adicionando Suas Próprias Configurações Pessoais
Para manter sua instalação fácil de atualizar sem criar conflitos com futuras atualizações do repositório:
* Adicione novos scripts customizados em `~/.config/bashrc/meus-aliases-envs.sh`.
* O `.bashrc` carrega automaticamente qualquer arquivo `.sh` existente nessa pasta em ordem alfabética.

---

## ❓ Perguntas Frequentes (FAQ)

**1. O Git Bash reclama de erro de formato de caminhos?**  
No Git Bash, utilize sempre caminhos no formato POSIX (ex.: `/c/Users/nome` ou `/d/nome/home`). Evite o formato Windows com barras invertidas (`C:\...`) em scripts e no `.bashrc`.

**2. As Junções NTFS exigem privilégios de Administrador?**  
Não. No Windows, Junções de Diretório (`mklink /J`) podem ser criadas por qualquer usuário padrão, sem necessidade de privilégios elevados ou Modo de Desenvolvedor.

**3. O que fazer se o script acusar conflito em uma pasta de `%USERPROFILE%`?**  
Se você já tinha uma pasta como `C:\Users\%USERNAME%\.aws`, o script avisará que ela precisa virar uma junção. Basta mover o conteúdo dessa pasta para o destino real correspondente (`D:\<USUARIO>\home\.aws`) e reabrir o terminal. O `bash-junctions.sh` criará a junção automaticamente.
