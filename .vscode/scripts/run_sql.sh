#!/bin/bash
# Variáveis de ambiente $1, $2, etc. vêm do array args do tasks.json

# Diretório deste arquivo
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Carregar helper
source $SCRIPT_DIR/../../scripts/helper.sh

# O arquivo pode ser referenciado como caminho completo ou caminho relativo
FILE_FULL_PATH=$2
FILE_RELATIVE_PATH=$1

# VSCODE_TASK_COMPILE_FILE deve ser definido em user-config.sh
if [ -z "$VSCODE_TASK_COMPILE_FILE" ]; then
  echo -e "${COLOR_ORANGE} Aviso: VSCODE_TASK_COMPILE_FILE não está definido.${COLOR_RESET}\nDefina VSCODE_TASK_COMPILE_FILE em $USER_CONFIG_FILE"
  echo -e "Usando caminho completo como padrão"
  VSCODE_TASK_COMPILE_FILE=$FILE_FULL_PATH
fi
# Como VSCODE_TASK_COMPILE_FILE contém a referência da variável, é necessário avaliá-la aqui
VSCODE_TASK_COMPILE_FILE=$(eval "echo $VSCODE_TASK_COMPILE_FILE")

echo -e "Processando arquivo: ${COLOR_LIGHT_GREEN}$VSCODE_TASK_COMPILE_FILE${COLOR_RESET}"
echo -e "pwd: $PWD"

# Executar sqlplus, executar o script e então obter a lista de erros e sair
# VSCODE_TASK_COMPILE_BIN é definido no arquivo config.sh (sqlplus ou sqlcl)
$VSCODE_TASK_COMPILE_BIN $DB_CONN << EOF
set define off
--
-- Defina quaisquer instruções alter session aqui (exemplos abaixo)
-- alter session set plsql_ccflags = 'dev_env:true';
-- alter session set plsql_warnings = 'ENABLE:ALL';
--
-- #38: Isso gerará uma mensagem de aviso no SQL*Plus mas vale manter para incentivar o uso se estiver usando SQLcl para compilar
set codescan all
--
-- Carregar comandos específicos do usuário aqui
$VSCODE_TASK_COMPILE_SQL_PREFIX
--
--
-- Executar arquivo
@$VSCODE_TASK_COMPILE_FILE
--
set define on
show errors
exit;
EOF
