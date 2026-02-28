#
# Script: ~/.config/bash/extras.sh
# Definições extras
# =============================================================================

# Desativar telemetria das CLIs de Nuvem no Terminal
export AWS_EXECUTION_ENV="CLI-No-Telemetry"
export AZURE_CORE_COLLECT_TELEMETRY=0
export CLOUDSDK_CORE_DISABLE_USAGE_REPORTING=true

# [to-do] Liberar variáveis de ambiente usadas nos RC Shell Scripts
# unset ORIGINAL_PATH ORIGINAL_TEMP ORIGINAL_TMP

#--------------------------------------------------------------------------------
#--- Final do script ~/.config/extras.sh
#--------------------------------------------------------------------------------