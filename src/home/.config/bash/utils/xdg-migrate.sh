#!/bin/bash
# Script: ~/.config/bash/utils/xdg-migrate.sh
# Migrar arquivos de configuração e históricos para os diretórios XDG
# =============================================================================

# Função para mover arquivos
display_move() {
    if [ -f "$1" ]; then

        # Garante que o diretório de destino existe
        mkdir -p "$(dirname "$2")"

        # Evita sobrescrever arquivos existentes
        if [ ! -f "$2" ]; then
            mv "$1" "$2"
            echo "[OK] Movido: $1 -> $2"
        else
            echo "[AVISO] Destino já existe, não movido: $2"
        fi

    fi
}

# Exibir mensagem de migração de arquivos
echo "Iniciando migração de arquivos..."

# Git
display_move "$HOME/.gitconfig" "$HOME/.config/git/config"

# Vim
display_move "$HOME/.vimrc" "$HOME/.config/vim/vimrc"
line='set viminfo+=n~/.local/state/vim/viminfo'
file="$HOME/.config/vim/vimrc"
grep -Fxq "$line" "$file" || echo -e "\n$line" >> "$file"

# Históricos (opcional, você pode apenas deletar os antigos)
display_move "$HOME/.node_repl_history" "$HOME/.local/state/node_repl_history"
display_move "$HOME/.lesshst" "$HOME/.local/state/less/history"

echo "---------------------------------------------------"
echo "Migração concluída. Certifique-se de ter adicionado"
echo "os 'exports' ao seu arquivo de inicialização."
