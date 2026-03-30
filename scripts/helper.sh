#!/bin/bash
# =============================================================================
# Funções Auxiliares — Oracle 19-26 / APEX 24.2
# Template: github.com/maxwbh/template_apex
# Guideline: Insum PL/SQL and SQL Coding Guidelines 4.4
# =============================================================================

# Variáveis globais
if [ -z "${BASH_SOURCE[0]}" ] ; then
  SCRIPT_DIR="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
else
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
fi
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

load_colors(){
  COLOR_LIGHT_GREEN='\033[0;92m'
  COLOR_ORANGE='\033[0;33m'
  COLOR_RED='\033[0;31m'
  COLOR_RESET='\033[0m'
  FONT_BOLD='\033[1m'
  FONT_RESET='\033[22m'
}

load_config(){
  USER_CONFIG_FILE=$PROJECT_DIR/scripts/user-config.sh
  PROJECT_CONFIG_FILE=$PROJECT_DIR/scripts/project-config.sh

  if [[ ! -f $USER_CONFIG_FILE ]] ; then
    echo -e "${COLOR_RED}Aviso: configuração de conexão com banco de dados ausente ${COLOR_RESET}"
    echo -e "${FONT_BOLD}Modifique $USER_CONFIG_FILE${FONT_RESET} com sua string de conexão do banco e aplicações APEX"
    cat > $USER_CONFIG_FILE <<EOL
#!/bin/bash

DB_CONN="ALTERE_USUARIO/ALTERE_SENHA@ALTERE_SERVIDOR:ALTERE_PORTA/ALTERE_SID"
SQLCL=sql
SQLPLUS=sqlplus
VSCODE_TASK_COMPILE_BIN=\$SQLPLUS
VSCODE_TASK_COMPILE_FILE=\\\$FILE_FULL_PATH

read -d '' VSCODE_TASK_COMPILE_SQL_PREFIX << EOF
-- Guideline Insum 4.4: habilitar warnings PL/SQL
alter session set plsql_warnings = 'ENABLE:ALL';
-- alter session set plsql_optimize_level = 3;
EOF

EOL
    chmod 755 $USER_CONFIG_FILE
    exit
  fi

  source $PROJECT_CONFIG_FILE
  source $USER_CONFIG_FILE
}

verify_config(){
  if [[ $SCHEMA_NAME = "CHANGEME" ]] || [[ -z "$SCHEMA_NAME" ]]; then
    echo -e "${COLOR_RED}SCHEMA_NAME não está configurado.${COLOR_RESET} Modifique $PROJECT_CONFIG_FILE"
    exit
  fi
  if [[ $APEX_APP_IDS = "CHANGEME" ]]; then
    echo -e "${COLOR_RED}APEX_APP_IDS não está configurado.${COLOR_RESET} Modifique $PROJECT_CONFIG_FILE"
    exit
  fi
  if [[ $APEX_WORKSPACE = "CHANGEME" ]]; then
    echo -e "${COLOR_RED}APEX_WORKSPACE não está configurado.${COLOR_RESET} Modifique $PROJECT_CONFIG_FILE"
    exit
  fi
  if [[ $DB_CONN == *"ALTERE_USUARIO"* ]]; then
    echo -e "${COLOR_RED}DB_CONN não está configurado.${COLOR_RESET} Modifique $USER_CONFIG_FILE"
    exit
  fi
}

export_apex_app(){
  local APEX_APP_VERSION=$1
  for APEX_APP_ID in $(echo "$APEX_APP_IDS" | sed "s/,/ /g")
  do
    echo "Exportação APEX: $APEX_APP_ID"
    cd "$PROJECT_DIR"
    echo "PROJECT_DIR=$PROJECT_DIR"
    echo exit | $SQLCL $DB_CONN @scripts/apex_export.sql $APEX_APP_ID
    if [ ! -z "$APEX_APP_VERSION" ]; then
      echo "APEX_APP_VERSION: $APEX_APP_VERSION detectada, injetando na aplicação APEX"
      echo "APEX_APP_ID=$APEX_APP_ID"
      sed -i-bak "s/%RELEASE_VERSION%/$VERSION/" "apex/f$APEX_APP_ID.sql"
      rm apex/f$APEX_APP_ID.sql-bak
    fi
  done
}

reset_release(){
  local CONFIRMATION_DIR=$1
  local PROJECT_DIR_FOLDER_NAME=${PROJECT_DIR##*/}
  if [[ $CONFIRMATION_DIR != $PROJECT_DIR_FOLDER_NAME ]]; then
    echo -e "${COLOR_RED}Erro: ${COLOR_RESET} diretório de confirmação ausente ou não correspondente. O valor correto é: $PROJECT_DIR_FOLDER_NAME"
    return 1
  else
    rm "$PROJECT_DIR"/release/code/*.sql
    echo "-- Referências específicas do release para arquivos nesta pasta" > "$PROJECT_DIR/release/code/_run_code.sql"
    echo "-- Este arquivo é executado automaticamente a partir do arquivo /release/_release.sql" >> "$PROJECT_DIR/release/code/_run_code.sql"
    printf "-- \n-- Ex: @code/issue-123.sql \n" >> "$PROJECT_DIR/release/code/_run_code.sql"
  fi
}

list_all_files(){
  local FOLDER_NAME=$1
  local OUTPUT_FILE=$2
  local FILE_EXTENSION_ARR=$3
  if [ -z "$FOLDER_NAME" ] || [ -z "$OUTPUT_FILE" ]; then
    return 1
  fi
  if [ -z "$FILE_EXTENSION_ARR" ]; then
    FILE_EXTENSION_ARR="sql"
  fi
  echo "-- GERADO pelo build/build.sh NÃO modifique este arquivo diretamente, pois todas as alterações serão sobrescritas no próximo build" > "$PROJECT_DIR/$OUTPUT_FILE"
  echo "-- Listagem automática para $FOLDER_NAME" >> "$PROJECT_DIR/$OUTPUT_FILE"
  for FILE_EXT in $(echo "$FILE_EXTENSION_ARR" | sed "s/,/ /g"); do
    echo "Listando arquivos em: $PROJECT_DIR/$FOLDER_NAME extensão: $FILE_EXT"
    for file in "$PROJECT_DIR/$FOLDER_NAME"/*."."$FILE_EXT"; do
      echo "prompt @../$FOLDER_NAME/${file##*/}" >> "$PROJECT_DIR/$OUTPUT_FILE"
      echo "@../$FOLDER_NAME/${file##*/}" >> "$PROJECT_DIR/$OUTPUT_FILE"
    done
  done
}

gen_release_sql(){
  local loc_env_vars="$PROJECT_DIR/release/load_env_vars.sql"
  local loc_apex_install_all="$PROJECT_DIR/release/all_apex.sql"
  printf "-- GERADO pelo build/build.sh NÃO modifique este arquivo diretamente, pois todas as alterações serão sobrescritas no próximo build\n\n" > "$loc_env_vars"
  echo "define env_schema_name=$SCHEMA_NAME" >> "$loc_env_vars"
  echo "define env_apex_app_ids=$APEX_APP_IDS" >> "$loc_env_vars"
  echo "define env_apex_workspace=$APEX_WORKSPACE" >> "$loc_env_vars"
  echo "" >> "$loc_env_vars"
  echo "
prompt Variáveis de ambiente
select
  '&env_schema_name.' env_schema_name,
  '&env_apex_app_ids.' env_apex_app_ids,
  '&env_apex_workspace.' env_apex_workspace
from dual;

" >> "$loc_env_vars"
  echo "-- GERADO pelo build/build.sh NÃO modifique este arquivo." > "$loc_apex_install_all"
  echo "prompt *** Instalação APEX ***" >> "$loc_apex_install_all"
  for APEX_APP_ID in $(echo "$APEX_APP_IDS" | sed "s/,/ /g"); do
    echo "prompt *** App: $APEX_APP_ID ***" >> "$loc_apex_install_all"
    echo "@../scripts/apex_install.sql $SCHEMA_NAME $APEX_WORKSPACE $APEX_APP_ID" >> "$loc_apex_install_all"
  done
}

gen_object(){
  local p_object_type=$1
  local p_object_name=$2
  local object_type_arr
  local object_type
  local object_template
  local object_dest_folder
  local object_dest_file
  for object_type in $(echo "$OBJECT_FILE_TEMPLATE_MAP" | sed "s/,/ /g"); do
    object_type_arr=(`echo "$object_type" | sed 's/:/ /g'`)
    object_type=${object_type_arr[@]:0:1}
    object_template=${object_type_arr[@]:1:1}
    object_file_exts=${object_type_arr[@]:2:1}
    object_dest_folder=${object_type_arr[@]:3:1}
    if [[ "$p_object_type" == "$object_type" ]]; then
      for file_ext in $(echo $object_file_exts | sed "s/;/ /g"); do
        object_dest_file=$PROJECT_DIR/$object_dest_folder/$p_object_name.$file_ext
        if [[ -f $object_dest_file ]]; then
          echo "${COLOR_ORANGE}Arquivo já existe:${COLOR_RESET} $object_dest_file"
        else
          cp "$object_template.$file_ext" "$object_dest_file"
          sed -i-bak "s/CHANGEME/$p_object_name/g" "$object_dest_file"
          rm "$object_dest_file-bak"
          echo "Criado: $object_dest_file"
          code $object_dest_file
        fi
      done
      break
    fi
  done
}

merge_sql_files(){
  local IN_FILE=$1
  local OUT_FILE=$2
  logger() {
    echo "`date`: $1"
  }
  process_line () {
    local FILE_LINE=$1
    if [ -f "${FILE_LINE:1}" ]
    then
      logger "Expandindo arquivo: ${FILE_LINE:1}"
      echo "-- $FILE_LINE" >> $OUT_FILE
      process_file ${FILE_LINE:1}
      echo >> $OUT_FILE
      echo >> $OUT_FILE
    else
      echo "$line" >> $OUT_FILE
    fi
  }
  process_file(){
    echo "Processando: $file_name"
    local file_name=$1
    while IFS='' read -r line || [[ -n "$line" ]]; do
      process_line $line
    done < "$file_name"
  }
  logger "Processando $IN_FILE em $OUT_FILE"
  echo "-- =============================================================================" > $OUT_FILE
  echo "-- ==========================  Arquivo completo $IN_FILE" >> $OUT_FILE
  echo "-- =============================================================================" >> $OUT_FILE
  echo -n >> $OUT_FILE
  process_file $IN_FILE
}

init(){
  local PROJECT_DIR_FOLDER_NAME=$(basename $PROJECT_DIR)
  local VSCODE_TASK_FILE=$PROJECT_DIR/.vscode/tasks.json
  sed -i-bak "s/CHANGEME_TASKLABEL/$PROJECT_DIR_FOLDER_NAME/g" "$VSCODE_TASK_FILE"
  rm "$VSCODE_TASK_FILE-bak"
  load_colors
  load_config
  verify_config
}

init
