#!/bin/bash
# Compilação de arquivo SQL/PL-SQL via VSCode
# Compatível com Oracle 19-26 / APEX 24.2

# Diretório deste arquivo
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Carregar helper
source "$SCRIPT_DIR/../../scripts/helper.sh"

# O arquivo pode ser referenciado como caminho completo ou relativo
FILE_FULL_PATH=$2
FILE_RELATIVE_PATH=$1

# VSCODE_TASK_COMPILE_FILE deve ser definido em user-config.sh
if [ -z "$VSCODE_TASK_COMPILE_FILE" ]; then
  echo -e "${COLOR_ORANGE} Aviso: VSCODE_TASK_COMPILE_FILE não está definido.${COLOR_RESET}\nDefina VSCODE_TASK_COMPILE_FILE em $USER_CONFIG_FILE"
  echo -e "Usando caminho completo como padrão"
  VSCODE_TASK_COMPILE_FILE=$FILE_FULL_PATH
fi
# Avaliar referência de variável
VSCODE_TASK_COMPILE_FILE=$(eval "echo $VSCODE_TASK_COMPILE_FILE")

echo -e "Compilando: ${COLOR_LIGHT_GREEN}$VSCODE_TASK_COMPILE_FILE${COLOR_RESET}"
echo -e "pwd: $PWD"

# Guideline: habilitar warnings PL/SQL para qualidade de código
$VSCODE_TASK_COMPILE_BIN $DB_CONN << EOF
set define off
--
-- Oracle 19+: configurações recomendadas para compilação
alter session set plsql_warnings = 'ENABLE:ALL';
-- alter session set plsql_ccflags = 'dev_env:true';
-- alter session set plsql_optimize_level = 3;
--
-- SQLcl: habilitar codescan para análise estática
set codescan all
--
-- Comandos específicos do usuário
$VSCODE_TASK_COMPILE_SQL_PREFIX
--
-- Executar arquivo
@$VSCODE_TASK_COMPILE_FILE
--
set define on
show errors
exit;
EOF
