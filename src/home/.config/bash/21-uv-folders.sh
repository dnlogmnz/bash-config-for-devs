#
# Script: ~/.config/bash/uv-folders.sh
# Validar diretórios e PATH para o UV (Python Package Manager)
# Depende de funções definidas em bash-functions.sh
# ==========================================================================================

# Criar Diretórios para python
if [ -d "${APPS_BASE}" ]
    then mkdir -p $UV_PYTHON_INSTALL_DIR $UV_PYTHON_BIN_DIR
    else displayFailure "ERRO" "Diretório '$APPS_BASE' (\$APPS_BASE) não existe"
fi

# Criar Diretórios para uv
if [ -d "${UV_PYTHON_INSTALL_DIR}" ]
    then mkdir -p $UV_HOME $UV_INSTALL_DIR $UV_CACHE_DIR $UV_TOOL_DIR
    else displayFailure "ERRO" "Diretório '$UV_PYTHON_INSTALL_DIR' (\$UV_PYTHON_INSTALL_DIR) não existe"
fi

#  Adicionar diretório dos binários UV ao PATH
if [[ ":$PATH:" != *":${UV_INSTALL_DIR}:"* ]]; then
    displayFailure "Windows" "Variáveis de ambiente para sua conta: adicionar \"$(command path2win "$UV_INSTALL_DIR")\" ao PATH"
    export PATH="${UV_INSTALL_DIR}:$PATH"
fi

#  Adicionar diretório dos binários do Python gerenciado pelo UV ao PATH
if [ -d "${UV_PYTHON_BIN_DIR}" ]; then
    if [[ ":${PATH}:" != *":${UV_PYTHON_BIN_DIR}:"* ]]; then
        displayFailure "Windows" "Variáveis de ambiente para sua conta: adicionar \"$(command path2win "$UV_PYTHON_BIN_DIR")\" ao PATH"
        export PATH="${UV_PYTHON_BIN_DIR}:$PATH"
    fi
fi

# Validar que instaladores do python (Windows Store) estão desabilitados: vamos usar python gerenciado pelo 'uv'
for py_exe in "python" "python3"; do
    py_path=$(which "$py_exe" 2>/dev/null)
    store_path=$(command path2lin "$LOCALAPPDATA/Microsoft/WindowsApps/$py_exe")

    if [[ "$py_path" == "$store_path" ]]; then
        displayFailure "Windows" "Config > Aliases de execução: desabilitar '$py_exe'"
    fi
done

#-------------------------------------------------------------------------------------------
#--- Final do script uv-folders.sh
#-------------------------------------------------------------------------------------------