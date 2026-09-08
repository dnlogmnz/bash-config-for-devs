#
# Projeto: bashrc-for-devs
#
# Script: ~/.config/bashrc/bash-junctions.sh
# Objetivo: criar junctions em %USERPROFILE% para diretórios reais em $HOME.
# =============================================================================================

# Garantir que USERPROFILE exista antes de prosseguir.
[[ -z "$USERPROFILE" ]] && { return 0 2>/dev/null || exit 0; }

# Converter USERPROFILE para o formato de caminho usado pelo Git Bash.
_usr_profile="$(cygpath -u -- "$USERPROFILE")"

# Evitar junctions quando HOME já é o próprio USERPROFILE.
_home_cmp="${HOME%/}"
_profile_cmp="${_usr_profile%/}"
if [[ "${_home_cmp,,}" == "${_profile_cmp,,}" ]]; then
    unset _usr_profile _home_cmp _profile_cmp
    return 0 2>/dev/null || exit 0
fi

# Se HOME/.local/bin não existir, criar o diretório para armazenar binários do usuário.
[ -d "$HOME/.local/bin" ] || mkdir -p "$HOME/.local/bin"

# Manter os binários em HOME/.local/bin; a junction .local também os expõe em USERPROFILE.
# Checagem case-insensitive e tolerante a barra final para compatibilidade Windows.
_path_cmp=":${PATH,,}:"
_expected_bin="${_usr_profile,,}/.local/bin"
if [[ "$_path_cmp" != *":$_expected_bin:"* && "$_path_cmp" != *":$_expected_bin/:"* ]]; then
    displayFailure \
        "Windows" \
        "Variáveis de ambiente para sua conta: adicionar \"$(cygpath -w "$_usr_profile/.local/bin")\" ao PATH"
    export PATH="$_usr_profile/.local/bin:$PATH"
fi
unset _path_cmp _expected_bin

# Redirecionar caminhos legados de ferramentas Windows para seus diretórios reais.
ensure_junction() {
    # Parâmetros:
    #   $1: diretório em $USERPROFILE que deve ser uma junction (ex: ".aws")
    #   $2: diretório real em $HOME (ex: "$HOME/.aws")
    local src="$_usr_profile/$1"
    local tgt="$2"
    [[ -z "$tgt" ]] && return 0
    [ -d "$tgt" ] || mkdir -p "$tgt"

    # Testar se a origem já é uma junction ou symlink (reparse point NTFS mapeado como S_IFLNK no MSYS2).
    # IMPORTANTE: Este teste deve anteceder '[ -e "$src" ]', pois '[ -L ]' avalia o link em si e
    # detecta com segurança inclusive junctions quebradas (dangling), sem seguir para o destino.
    if [ -L "$src" ]; then
        # Resolver os caminhos canônicos reais de origem e destino para comparação justa.
        local actual expected actual_cmp expected_cmp
        actual="$(readlink -f -- "$src" 2>/dev/null)"
        expected="$(readlink -f -- "$tgt" 2>/dev/null)"
        actual_cmp="${actual%/}"
        expected_cmp="${expected%/}"

        # Comparação em minúsculas (case-insensitive): essencial no Windows (NTFS).
        # Evita falsos positivos causados por letras de unidade ou caminhos com caixas distintas.
        # Se o destino já for o esperado, encerra imediatamente (caminho rápido e idempotente).
        if [[ -n "$actual_cmp" && "${actual_cmp,,}" == "${expected_cmp,,}" ]]; then
            return 0
        fi

        # Contrato do projeto: política estritamente não-destrutiva.
        # Se a junction existe mas aponta para outro local, emite apenas um alerta informativo.
        # NUNCA recria ou altera a junction automaticamente para evitar quebra de ambientes customizados.
        local src_w actual_w expected_w
        src_w="$(cygpath -w -- "$src")"
        expected_w="$(cygpath -w -- "$tgt")"
        if [[ -n "$actual" ]]; then
            actual_w="$(cygpath -w -- "$actual")"
        else
            actual_w="destino não resolvido"
        fi
        displayWarning \
            "Windows" \
            "A junction '$src_w' aponta para '$actual_w'; esperado: '$expected_w'. Nenhuma alteração foi feita."
        return 0
    fi

    # Preservar arquivos e diretórios reais existentes para evitar perda de dados.
    if [ -e "$src" ]; then
        displayFailure "Windows"      "Remover diretório ou arquivo '$(cygpath -w "$src")'"
        displayInfo    "Por que?"     "Em USERPROFILE, esse path deve ser uma JUNCTION no Windows"
        displayInfo    "O que é?"     "$(stat -c '%F' "$src" 2>/dev/null || echo 'desconhecido')"
        displayInfo    "O que fazer?" "Após remover manualmente, reinicie a sessão"
        displayInfo    "Sugestão"     "Combine o conteúdo com '$(cygpath -w "$tgt")' antes de remover"
        echo
    else
        # Converter caminhos Unix para Windows nativo (C:\... e D:\...), exigidos pelo cmd.exe.
        local src_w tgt_w err
        src_w="$(cygpath -w "$src")"
        tgt_w="$(cygpath -w "$tgt")"

        # Criar a junction NTFS no Windows via utilitário interno do cmd.exe (mklink /J).
        err="$(MSYS_NO_PATHCONV=1 cmd //c "mklink /J \"$src_w\" \"$tgt_w\"" 2>&1)"
        if [ $? -eq 0 ]; then
            displaySuccess "Windows" "Junção criada: $src_w <<===>> $tgt_w"
        else
            # Normalizar saída de erro removendo retorno de carro Windows (\r) e linhas em branco.
            err="$(printf '%s\n' "$err" | sed 's/\r$//' | grep -av '^$' | head -1)"
            displayFailure \
                "Windows" \
                "Erro ao criar junção para '$src_w': ${err:-comando falhou}"
        fi
    fi
}

# Pastas dotfile mantidas como diretórios reais em $HOME; junctions em %USERPROFILE%
ensure_junction ".local"                  "$HOME/.local"
ensure_junction ".config"                 "$XDG_CONFIG_HOME"
ensure_junction ".cache"                  "$XDG_CACHE_HOME"
ensure_junction ".aws"                    "$HOME/.aws"
ensure_junction ".certs"                  "$XDG_CONFIG_HOME/certs"
ensure_junction ".ssh"                    "$HOME/.ssh"
ensure_junction ".claude"                 "$CLAUDE_CONFIG_DIR"
ensure_junction ".gemini\config"          "$XDG_CONFIG_HOME/gemini"
ensure_junction ".gemini\bin"             "$XDG_BIN_HOME/gemini"
ensure_junction ".gemini\antigravity-cli" "$XDG_STATE_HOME/antigravity-cli"
ensure_junction ".gemini\antigravity-ide" "$XDG_STATE_HOME/antigravity-ide"
ensure_junction ".gemini\antigravity"     "$XDG_STATE_HOME/antigravity"


# Limpa variáveis do escopo global
unset _usr_profile _home_cmp _profile_cmp

# Limpar funções auxiliares do escopo global
unset -f ensure_junction

#----------------------------------------------------------------------------------------------
#--- Final do script bash-junctions.sh
#----------------------------------------------------------------------------------------------