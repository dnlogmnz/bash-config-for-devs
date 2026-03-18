# Templates de Configuração

Esta pasta contém templates editáveis para os scripts helper em `../bash/helpers/`.

## Como Customizar Templates

Os templates usam placeholders no formato `{{VARIABLE_NAME}}` que são substituídos dinamicamente pelos scripts.

### Templates Disponíveis

- `dot-env.template`: Template para arquivo `.env` com variáveis de ambiente
- `poc-env.template`: Template para arquivos de ambiente em `envs/`
- `pyproject.toml.template`: Template para arquivo `pyproject.toml`
- `ruff.toml.template`: Template para arquivo `ruff.toml`
- `uv.toml.template`: Template para arquivo `uv.toml` global

### Customização

1. Edite os arquivos `.template` nesta pasta
2. Os scripts helper usarão automaticamente suas versões customizadas
3. **Importante**: Os scripts seguem versioning conservador - se um arquivo de configuração já existir, ele não será sobrescrito

### Placeholders por Template

#### dot-env.template
- Nenhum placeholder (cópia direta)

#### poc-env.template
- `{{PRODUCT_NAME}}`: Nome do ambiente (prod-a, prod-b, etc.)

#### pyproject.toml.template
- `{{PROJECT_NAME}}`: Nome do projeto
- `{{PYTHON_VERSION}}`: Versão mínima do Python
- `{{AUTHOR_NAME}}`: Nome do autor (do git config)
- `{{AUTHOR_EMAIL}}`: Email do autor (do git config)

#### ruff.toml.template
- `{{PYTHON_VERSION}}`: Versão target do Python
- `{{LINE_LENGTH}}`: Comprimento máximo da linha
- `{{PROJECT_NAME}}`: Nome do projeto

#### uv.toml.template
- `{{UV_CONF_FILE}}`: Caminho para o arquivo de configuração
- `{{UV_CACHE_DST}}`: Caminho para o cache do uv

### Exemplo de Customização

Para modificar o template `.env`, edite `dot-env.template`:

```bash
# Este arquivo possui secrets, manter sempre no .gitignore
# secrets:
# API_KEY="xxx"
# MY_CUSTOM_VAR="valor personalizado"

#configmap:

# Biblioteca 'logger' - definir o nível de detalhe nos logs
LOG_LEVEL="INFO"
```