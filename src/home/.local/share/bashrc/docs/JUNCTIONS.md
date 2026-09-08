# Instalação de Aplicativos e Utilitários DevSecOps

## Pressupostos

As instalações de aplicativos no Windows 11 serão feitas com um usuário comum que:
- não tem privilégios administrativos, nem capacidade de obter elevação de privilégios;
- está proibido de usar o PowerShell, editores do Registry (tais como `reg.exe` e `regedit.exe`);
- não pode baixar nada via Windows Store;
- não pode usar winget e outros instaladores normalmente recomendados no Windows.

Todas as instalações pressupõem que as seguintes variáveis de ambiente foram adicionadas em "Editar variáveis de ambiente para sua conta":
- `HOME` aponta para `D:\<USUÁRIO>\home`
- `APPS_BASE` aponta para `D:\<USUÁRIO>\Apps`

Os motivadores são os seguintes:
- O drive `C:` deve estar, na medida do possível, reservado para o Windows.
- A instalação de aplicações apenas para meu `<USUÁRIO>` devem ter como destino pastas sob `%APPS_BASE%`.

## Instalar o Python

Use `uv` (veja a seção correspondente no `uv-envs.sh`). Não instale Python diretamente via python.org, winget ou Microsoft Store.

## Instalar o AWS CLI v2

Mesmo sem privilégios administrativos e com restrições severas, é possível instalar o AWS CLI v2 no Windows 11 utilizando um método de extração administrativa (`msiexec /a`). Isso permite "instalar" o software em uma pasta de usuário sem modificar o registro do Windows ou diretórios de sistema.

Para maiores informações, consulte:
- Documentação de instalação: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
- Instalador: https://awscli.amazonaws.com/AWSCLIV2.msi

Executar a instalação, direcionando o local de instalação para `%APPS_BASE%`:
```
msiexec /a "AWSCLIV2.msi" /qb TARGETDIR="%APPS_BASE%"
```

Esse comando irá criar o diretório `%APPS_BASE%\Amazon\AWSCLIV2` e extrair o AWS CLI v2 para lá.

Ao final da instalação, você deve:
- Adicionar esse diretório ao PATH do Windows (Editar as variáveis de ambiente para sua conta).
- Mover o diretório `C:\Users\<USUÁRIO>\AppData\Local\Microsoft\WindowsApps` para último lugar no PATH

## Google Cloud CLI

O Google Cloud CLI requer o Python. Antes de instalar o Google Cloud CLI, definir a variável de ambiente `CLOUDSDK_PYTHON` em "Editar as variáveis de ambiente para sua conta" apontando para `D:\<USUÁRIO>\Apps\Python\bin\python.exe`.

Faça download do instalador do Google Cloud CLI a partir de https://docs.cloud.google.com/sdk/docs/install-sdk?hl=pt-br#latest-version.

Executar a instalação, direcionando o local de instalação para `%APPS_BASE%`:
```
GoogleCloudSDKInstaller.exe /singleuser /D="%APPS_BASE%\Google\Cloud SDK"
```

Esse comando irá:
- Criar o diretório `%APPS_BASE%\Google\Cloud SDK` e extrair o Google Cloud CLI para lá.
- Adicionar `D:\<USUÁRIO>\Apps\Google\Cloud SDK\google-cloud-sdk\bin` ao PATH do Windows.

Ao final da instalação, você deve:
- Mover o diretório `C:\Users\<USUÁRIO>\AppData\Local\Microsoft\WindowsApps` para último lugar no PATH

---

# Junções de diretórios do Windows

## Motivação

Aplicativos do Windows (AWS CLI, SSH, Claude Code, etc.) gravam seus arquivos de configuração em diretórios *dotfiles* dentro de `%USERPROFILE%` (`C:\Users\%USERNAME%`). Já no Git Bash, este projeto adota `$HOME` apontando para outro local — tipicamente `D:\%USERNAME%\home` — para manter o drive `C:` reservado para o Windows.

A solução é criar **junctions de diretório** (`mklink /J`) em `%USERPROFILE%` apontando para os diretórios reais sob `$HOME`. Assim, os aplicativos do Windows continuam funcionando normalmente (gravam em `C:\Users\%USERNAME%\.aws`), enquanto os arquivos físicos vivem no seu `$HOME` versionável.

## Junções criadas pelo `bash-junctions.sh`

Toda vez que um novo Git Bash é aberto, o script `bash-junctions.sh` verifica e cria (se necessário) as seguintes junctions, desde que `$HOME` e `%USERPROFILE%` sejam locais diferentes:

| Origem (`%USERPROFILE%`)       | Destino (`$HOME`)                    | Uso típico                              |
|--------------------------------|--------------------------------------|-----------------------------------------|
| `C:\Users\%USERNAME%\.aws`     | `$HOME/.aws`                         | AWS CLI v2 (perfis, SSO)                |
| `C:\Users\%USERNAME%\.cache`   | `$XDG_CACHE_HOME`                    | Caches XDG                              |
| `C:\Users\%USERNAME%\.certs`   | `$XDG_CONFIG_HOME/certs`             | Certificados raiz para `NODE_EXTRA_CA_CERTS` |
| `C:\Users\%USERNAME%\.claude`  | `$CLAUDE_CONFIG_DIR`                 | Claude Code (credenciais OAuth, sessões)|
| `C:\Users\%USERNAME%\.config`  | `$XDG_CONFIG_HOME`                   | Configurações XDG                       |
| `C:\Users\%USERNAME%\.local`   | `$HOME/.local`                       | Binários do usuário e dados XDG         |
| `C:\Users\%USERNAME%\.ssh`     | `$HOME/.ssh`                         | Chaves e config SSH                     |

> **Nota sobre `.aws`:**<br> O script aponta `.aws` diretamente para `$HOME/.aws` (e não para `$XDG_CONFIG_HOME/aws`) porque o AWS CLI v2 ainda não suporta XDG nativamente — ele lê de `~/.aws/config` de forma rígida.

## Como o script se comporta

`HOME`, `XDG_*` e `CLAUDE_CONFIG_DIR` são definidos antes pelo `.bashrc` e pelos scripts de ambiente. O `bash-junctions.sh` não altera essas variáveis: ele usa exatamente os caminhos recebidos. Se `$HOME` e `%USERPROFILE%` representarem o mesmo local, o script termina imediatamente sem alterar o `PATH`, criar diretórios ou executar `mklink`.

Para cada junction, a função `ensure_junction()` segue este fluxo:

1. **Caminho rápido (estado estável):** se a origem já é uma junction (`[ -L "$src" ]`), retorna imediatamente sem conversões ou `cmd.exe`.
2. **Se a origem não existe:** cria o destino (caso falte) e executa `mklink /J "$src_w" "$tgt_w"` via `cmd.exe`. Em sucesso, emite `displaySuccess`; em falha, emite `displayFailure` com a mensagem de erro do Windows.
3. **Se a origem existe mas não é uma junction** (é um diretório/arquivo real): emite mensagens orientando o usuário a:
   - Combinar manualmente o conteúdo com o destino;
   - Remover a origem;
   - Reiniciar a sessão para que a junction seja criada.

O script **não remove nada automaticamente** — qualquer ação destrutiva sobre arquivos existentes é deixada para o usuário.

## Criação manual (debug ou primeira instalação)

Se você quiser criar uma junction manualmente (fora do script), abra um `cmd.exe` (não precisa de Administrador):

```cmd
mklink /J "C:\Users\%USERNAME%\.aws" "D:\%USERNAME%\home\.aws"
```

Para verificar se um caminho já é uma junction, no Git Bash:

```bash
[ -L "/c/Users/$USERNAME/.aws" ] && echo "É junction" || echo "Não é junction"
```

Ou, usando o Windows:

```cmd
dir /AL "C:\Users\%USERNAME%"
```

(diretórios com `<JUNCTION>` na coluna são junctions)
