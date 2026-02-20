# Scripts de Inicialização (RC) para Bash

Este repositório oferece uma coleção modular de scripts Bash projetados para configurar e otimizar o ambiente de desenvolvimento local, garantindo uma estrutura robusta, organizada e compatível com os padrões modernos de sistemas Unix-like e Git Bash.

## 🎯 Objetivo do Projeto

Um desenvolvedor de aplicações utiliza diversos ecossistemas que exigem variáveis de ambiente e configurações específicas no terminal `bash`. Seguem alguns exemplos de ferramentas comuns:

  * **Runtimes e Linters**: você pode desenvolver aplicações usando `node`, ou então `python` (e com este último, você pode também querer usar `uv` e `ruff`).

  * **Cloud CLIs**: `aws.exe` (AWS CLI v2), `az.exe` (Azure CLI) e `gcloud.exe` (GCP CLI).

  * **Versionamento**: `git.exe` (Git CLI) e `gh.cli` (GitHub CLI).

  * **Virtualização**: Docker Desktop para Windows (assinatura Docker Personal).

  * Entre outros...

Frequentemente, isso resulta em um arquivo `~/.bashrc` desorganizado e difícil de manter. Além disso, algumas dessas ferramentas criam seus próprios arquivos *dotfiles* na raiz do seu `$HOME`, tornando o backup e transferência de suas configurações para outro equipamento um exercício bastante complexo.

Este projeto propõe uma **arquitetura modular**: em vez de um único arquivo gigante, as configurações são separadas por responsabilidade (ambiente, funções e aliases) e por ferramenta (AWS, Git, Docker, etc), facilitando o versionamento e a portabilidade de seus *dotfiles*.

---

## 🏛️ Fundamentação: O Padrão XDG/FHS

Para manter o diretório `$HOME` limpo e organizado, este projeto adota a **XDG Base Directory Specification** em conjunto com o **FHS (Filesystem Hierarchy Standard)**. Este é o padrão contemporâneo para sistemas Unix-like (Linux, macOS e Git Bash), projetado para evitar a poluição da raiz do diretório de usuário com arquivos ocultos (os chamados *dotfiles*).

### O Padrão XDG na Prática (Referência 2026)

O padrão XDG define variáveis de ambiente que apontam para locais específicos para cada tipo de arquivo gerado por aplicações ou pelo usuário:

*   **`$XDG_CONFIG_HOME` (`$HOME/.config/`)**: Destinado a arquivos de configuração (ex: aliases, preferências de editores, envs).
*   **`$XDG_DATA_HOME` (`$HOME/.local/share/`)**: Destinado a dados persistentes que não são configurações (ex: bancos de dados locais, ícones, fontes).
*   **`$XDG_STATE_HOME` (`$HOME/.local/state/`)**: Destinado a arquivos de estado que não devem persistir entre migrações (ex: logs, histórico de comandos, estados de sessões).
*   **`$XDG_CACHE_HOME` (`$HOME/.cache/`)**: Destinado a dados não essenciais que podem ser apagados para liberar espaço (ex: caches de compiladores ou gerenciadores de pacotes).
*   **Binários do Usuário (`$HOME/.local/bin/`)**: Embora não seja estritamente parte da especificação XDG original, o FHS recomenda este local para scripts customizados e executáveis instalados pelo usuário que devem ser incluídos no `$PATH`.

> [!TIP]
> Evite a prática antiga de criar arquivos ocultos (`.arquivo`) diretamente na raiz do seu `$HOME`. Seguir o padrão XDG torna seu ambiente modular, facilita o backup seletivo e simplifica a migração de *dotfiles* entre diferentes máquinas.


---


### 📦 Como este projeto utiliza essa estrutura

Neste repositório, focamos na organização do seu ambiente Bash dentro dos diretórios preconizados acima:

1.  **Ponto de Entrada**: O Bash utiliza arquivos na raiz do `$HOME` para iniciar a sessão. Este projeto recomenda centralizar a lógica de carregamento no `~/.bashrc`, garantindo que tanto *interactive shells* quanto *login shells* (através do `~/.bash_profile` ou `~/.profile`) carreguem as configurações modulares.
2.  **Configurações**: Todos os scripts de inicialização, aliases e funções serão armazenados de forma organizada em `~/.config/bash/`.
3.  **Executáveis**: Scripts utilitários e wrappers (como os do `uv`) devem residir em `~/.local/bin/`, que é adicionado ao seu `$PATH`.
4.  **Ambiente**: Variáveis de ambiente são definidas nos scripts `envs` para redirecionar ferramentas (como Terraform e Python) a usarem `~/.local/share` e `~/.local/state`, mantendo o raiz de seu diretório pessoal sempre limpo.

> **Nota sobre arquivos de inicialização**:
> *   **`~/.bashrc`**: Executado em sessões interativas que não são de login (o padrão ao abrir um novo terminal).
> *   **`~/.bash_profile`**: Executado em *login shells* (ex: via SSH ou no startup do Git Bash). Geralmente, ele deve conter um comando para carregar o `~/.bashrc`, e nada mais.
> *   **`~/.profile`**: Um fallback genérico para shells compatíveis com o padrão POSIX (caso o `~/.bash_profile` não exista). Não utilizado neste projeto.


---



## 📂 Estrutura do Repositório e Scripts

Este projeto mantém os scripts em `src/home/.config/bash`. A numeração dos arquivos garante que as dependências sejam carregadas na ordem correta (ex: carregar variáveis de ambiente antes de funções que dependem delas).


### 🛠️ Scripts de Configuração de Ambiente (`envs`)

Os scripts terminados em `-envs.sh` configuram variáveis de sistema, caminhos de cache e ajustes de binários. Exemplos:

*   **00-bash-envs.sh**: Variáveis básicas do Bash e ajuste inicial do `$PATH`.
*   **12-terraform-envs.sh**: Configurações para Terraform/OpenTofu (cache de plugins e diretórios).
*   **23-gemini-cli-envs.sh**: Variáveis para o Google Gemini CLI, incluindo autenticação e modelos.
*   **41-uv-envs.sh**: Configurações para o gerenciador de pacotes Python `uv`.


### ⚡ Scripts de Funções (`functions`)

Os scripts terminados em `-functions.sh` declaram funções complexas para automação de tarefas.

*   **00-bash-functions.sh**: Funções de exibição de mensagens e visualização de versões (DevSecOps stack).
*   **11-git-functions.sh**: Utilitários para Git CLI, como `git-info` e `git-config`.
*   **21-aws-functions.sh**: Facilita o uso do AWS CLI (`aws-info`, `aws-use`, `aws-setup`).
*   **31-mongodb-functions.sh**: Interação com MongoDB Atlas CLI.
*   **41-uv-functions.sh** & **42-python-functions.sh**: Gestão de projetos e ambientes Python gerenciados pelo `uv`.

> **[TIP]**: Para cada script terminado em `-envs.sh` você pode criar o correspondente script terminado em `-functions.sh`.


### ⌨️ Scripts de Aliases

> **[TIP]**: você pode declarar nestes scripts todos os aliases que você está acostumado a criar para seu uso próprio. 

*   **14-docker-aliases.sh**: Atalhos úteis como `docker-clean`, `docker-stop-all` e logs rápidos.

---

## 💡 Implementação Passo a Passo

### 1. Criar a estrutura de diretórios
No seu terminal, execute:
```bash
mkdir -p ~/.config/bash/
mkdir -p ~/.local/bin
```

### 2. Configurar o .bashrc Principal
No seu `~/.bashrc` (ou `~/.bash_profile`) do seu Git Bash, adicione a lógica para carregar automaticamente os arquivos organizados:
```bash
# ~/.bashrc

# Configurações de locale
export LANG=pt_BR.UTF-8
export LC_ALL=pt_BR.UTF-8

# Padrão FHS (Filesystem Hierarchy Standard) / XDG (X Desktop Group)
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# Carga (source) dos scripts de inicialização do shell (run command files)
if [ -d $XDG_CONFIG_HOME/bash ]; then
    for rc in $XDG_CONFIG_HOME/bash/*.sh; do
        [ -f "$rc" ] && source "$rc"
    done
fi

# Limpa a variável rc do escopo global
unset rc
```


---


## 🚀 Você está pronto!!

Seguem algumas dicas finais:

* **Caminhos (Paths)**: O Git Bash simula Unix. Ao definir variáveis, prefira caminhos no formato `/c/Users/nome` em vez de `C:\Users\nome`.
* **Backup**: Graças à separação modular, você pode copiar apenas o `$HOME/.bashrc` e  diretório `$HOME/.config` para um novo equipamento. Os demais arquivos serão criados automaticamente pelos scripts deste projeto no destino.
