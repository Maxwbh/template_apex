#!/bin/bash

# Variáveis globais
# Encontrar o caminho atual onde este script está
# Isso precisa ser executado fora de qualquer função, pois $0 tem significado diferente dentro de uma função
# Se este script está sendo chamado usando "source ...", então ${BASH_SOURCE[0]} é avaliado como nulo. Use $0 nesse caso
if [ -z "${BASH_SOURCE[0]}" ] ; then
  SCRIPT_DIR="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
else
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
fi
# Pasta raiz do diretório do projeto
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
# echo "SCRIPT_DIR: $SCRIPT_DIR"
# echo "PROJECT_DIR: $PROJECT_DIR"


# Carregar cores
# Para usar cores:
# echo -e "${COLOR_RED}isto é vermelho${COLOR_RESET}"
load_colors(){
  # Cores para bash. Veja: http://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
  COLOR_LIGHT_GREEN='\033[0;92m'
  COLOR_ORANGE='\033[0;33m'
  COLOR_RED='\033[0;31m'
  COLOR_RESET='\033[0m' # Sem cor

  FONT_BOLD='\033[1m'
  FONT_RESET='\033[22m'
} # load_colors

# Carregar o arquivo de configuração armazenado em scripts/config
load_config(){
  USER_CONFIG_FILE=$PROJECT_DIR/scripts/user-config.sh
  PROJECT_CONFIG_FILE=$PROJECT_DIR/scripts/project-config.sh
  # echo "USER_CONFIG_FILE: $USER_CONFIG_FILE"
  # echo "PROJECT_CONFIG_FILE: $PROJECT_CONFIG_FILE"

  if [[ ! -f $USER_CONFIG_FILE ]] ; then
    echo -e "${COLOR_RED}Aviso: configuração de conexão com banco de dados ausente ${COLOR_RESET}"
    echo -e "${FONT_BOLD}Modifique $USER_CONFIG_FILE${FONT_RESET} com sua string de conexão do banco e aplicações APEX"
    cat > $USER_CONFIG_FILE <<EOL
#!/bin/bash

# Se você precisar registrar aliases no bash, descomente estas linhas
# shopt -s expand_aliases
# Isso deve referenciar onde você armazena aliases (ou defini-los manualmente)
# source ~/.aliases.sh

# String de conexão para o ambiente de desenvolvimento
DB_CONN="ALTERE_USUARIO/ALTERE_SENHA@ALTERE_SERVIDOR:ALTERE_PORTA/ALTERE_SID"

# Binário do SQLcl (sql ou sqlcl dependendo se você alterou algo)
# Se usar um container Docker para SQLcl, certifique-se de que o alias de execução não inclui a opção "-it", pois TTY não é necessário para estes scripts
SQLCL=sql

# Binário do sql*plus
# Se usar um container Docker para sqlplus, certifique-se de que o alias de execução não inclui a opção "-it", pois TTY não é necessário para estes scripts
SQLPLUS=sqlplus


# *** Configurações do VSCode ***

# Compilar arquivo: escolha \$SQLCL ou \$SQLPLUS
# Recomendado usar \$SQLPLUS pois é mais rápido
VSCODE_TASK_COMPILE_BIN=\$SQLPLUS

# Arquivo para compilar. Opções:
# \\\$FILE_RELATIVE_PATH: Será avaliado como caminho relativo ao projeto. Ex: views/minha_view.sql
# \\\$FILE_FULL_PATH: Será avaliado como caminho completo do arquivo. Ex:
#
# Se usar sqlplus via docker, um exemplo seria:
# VSCODE_TASK_COMPILE_FILE=/sqlplus/\\\$FILE_RELATIVE_PATH
# Nota: Você precisa escapar o "\$" aqui, então deve ser "\\\$FILE_FULL_PATH"
VSCODE_TASK_COMPILE_FILE=\\\$FILE_FULL_PATH

# Este código será executado antes do arquivo ser executado
read -d '' VSCODE_TASK_COMPILE_SQL_PREFIX << EOF
-- Adicione quaisquer instruções alter session customizadas aqui
-- alter session set plsql_warnings = 'ENABLE:ALL';
EOF

EOL
    chmod 755 $USER_CONFIG_FILE
    exit
  fi

  # Carregar configuração do projeto
  source $PROJECT_CONFIG_FILE
  # Carregar configuração do usuário
  source $USER_CONFIG_FILE
} # load_config


# Verificar configuração
verify_config(){
  # SCHEMA_NAME é obrigatório
  if [[ $SCHEMA_NAME = "CHANGEME" ]] || [[ -z "$SCHEMA_NAME" ]]; then
    echo -e "${COLOR_RED}SCHEMA_NAME não está configurado.${COLOR_RESET} Modifique $PROJECT_CONFIG_FILE"
    exit
  fi

  # APEX_APP_IDS deve estar vazio ou ser uma lista de IDs, e não o valor padrão fornecido
  if [[ $APEX_APP_IDS = "CHANGEME" ]]; then
    echo -e "${COLOR_RED}APEX_APP_IDS não está configurado.${COLOR_RESET} Modifique $PROJECT_CONFIG_FILE"
    exit
  fi

  # APEX_WORKSPACE deve estar vazio ou ser uma lista de IDs, e não o valor padrão fornecido
  if [[ $APEX_WORKSPACE = "CHANGEME" ]]; then
    echo -e "${COLOR_RED}APEX_WORKSPACE não está configurado.${COLOR_RESET} Modifique $PROJECT_CONFIG_FILE"
    exit
  fi

  # Verificar se a string de conexão do banco está definida
  if [[ $DB_CONN == *"ALTERE_USUARIO"* ]]; then
    echo -e "${COLOR_RED}DB_CONN não está configurado.${COLOR_RESET} Modifique $USER_CONFIG_FILE"
    exit
  fi
} # verify_config


# Exportar aplicações APEX
# Parâmetros
# $1 Número da versão
export_apex_app(){

  local APEX_APP_VERSION=$1

  for APEX_APP_ID in $(echo $APEX_APP_IDS | sed "s/,/ /g")
  do
    echo "Exportação APEX: $APEX_APP_ID"

    # Exportar arquivo único da aplicação
    # É necessário iniciar no diretório raiz do projeto, pois a exportação armazenará automaticamente os arquivos na pasta apex
    cd $PROJECT_DIR
    echo "PROJECT_DIR=$PROJECT_DIR"

    echo exit | $SQLCL $DB_CONN @scripts/apex_export.sql $APEX_APP_ID

    if [ ! -z "$APEX_APP_VERSION" ]; then
      # Adicionar número da versão à aplicação
      # Para suportar as várias versões do sed, é necessário adicionar o "-bak"
      # Veja: https://unix.stackexchange.com/questions/13711/differences-between-sed-on-mac-osx-and-other-standard-sed/131940#131940
      echo "APEX_APP_VERSION: $APEX_APP_VERSION detectada, injetando na aplicação APEX"
      echo "APEX_APP_ID=$APEX_APP_ID"

      sed - i-bak "s/%RELEASE_VERSION%/$VERSION/" apex/f$APEX_APP_ID.sql
      # Remover a versão de backup do arquivo (veja acima)
      rm apex/f$APEX_APP_ID.sql-bak
    fi
    # Exportar aplicação dividida (ou APEXcl)
    # echo exit | $SQLCL $DB_CONN @scripts/apex_export.sql $APEX_APP_ID -split

  done
}


# Reseta release/code/_run_code.sql e exclui todos os arquivos na pasta release/code
#
# Parâmetros
# $1 nome da pasta raiz para confirmação. Como isso excluirá arquivos na pasta release, queremos garantir que estamos excluindo arquivos no local esperado.
#  Por exemplo, este projeto inicial existe em /users/maxwell/git/template_apex
#  Para esta função funcionar, você deve chamar: reset_release template_apex
reset_release(){
  local CONFIRMATION_DIR=$1
  local PROJECT_DIR_FOLDER_NAME=${PROJECT_DIR##*/}

  if [[ $CONFIRMATION_DIR != $PROJECT_DIR_FOLDER_NAME ]]; then
    echo -e "${COLOR_RED}Erro: ${COLOR_RESET} diretório de confirmação ausente ou não correspondente. O valor correto é: $PROJECT_DIR_FOLDER_NAME"
    # exit 1
  else
    # Limpar código específico do release
    rm $PROJECT_DIR/release/code/*.sql
    # Resetar arquivo _run_code.sql
    echo "-- Referências específicas do release para arquivos nesta pasta" > $PROJECT_DIR/release/code/_run_code.sql
    echo "-- Este arquivo é executado automaticamente a partir do arquivo /release/_release.sql" >>$PROJECT_DIR/release/code/_run_code.sql
    echo "-- \n-- Ex: @code/issue-123.sql \n" >>$PROJECT_DIR/release/code/_run_code.sql
  fi
} # reset_release



# Listar todos os arquivos em um diretório
#
# Parâmetros
# $1: Pasta (relativa à pasta raiz do projeto) para listar todos os arquivos. Ex: views
# $2: Arquivo (relativo à pasta raiz do projeto) para armazenar a lista de arquivos. Ex: release/all_views.sql
# $3: Lista de extensões de arquivo separadas por vírgula para buscar. Ex: pks,pkb. Padrão: sql
list_all_files(){

  local FOLDER_NAME=$1
  local OUTPUT_FILE=$2
  local FILE_EXTENSION_ARR=$3

  local RUN_HELP="get_all_files <nome_pasta_relativo> <arquivo_saida_relativo> <opcional: lista_extensoes_arquivo>
O exemplo a seguir listará todos os arquivos .sql em ./views e os referenciará em release/all_views.sql

get_all_files views release/all_views.sql sql

Para packages é útil listar as extensões na ordem em que devem ser compiladas. Ex: pks,pkb para compilar spec antes do body
"

  # Validação
  if [ -z "$FOLDER_NAME" ]; then
    echo "${COLOR_RED}Erro: ${COLOR_RESET} Nome da pasta ausente"
    echo "\n$RUN_HELP"
    return 1
  elif [ -z "$OUTPUT_FILE" ]; then
    echo "${COLOR_RED}Erro: ${COLOR_RESET} Arquivo de saída ausente"
    echo "\n$RUN_HELP"
    return 1
  fi

  # Definindo extensões padrão
  if [ -z "$FILE_EXTENSION_ARR" ]; then
    FILE_EXTENSION_ARR="sql"
  fi

  echo "-- GERADO pelo build/build.sh NÃO modifique este arquivo diretamente, pois todas as alterações serão sobrescritas no próximo build" > $PROJECT_DIR/$OUTPUT_FILE
  echo "-- Listagem automática para $FOLDER_NAME" >> $PROJECT_DIR/$OUTPUT_FILE
  for FILE_EXT in $(echo $FILE_EXTENSION_ARR | sed "s/,/ /g"); do

    echo "Listando arquivos em: $PROJECT_DIR/$FOLDER_NAME extensão: $FILE_EXT"
    for file in $PROJECT_DIR//$FOLDER_NAME//*.$FILE_EXT; do
    # for file in $PROJECT_DIR/$FOLDER_NAME/*.sql; do
    # for file in $(ls $PROJECT_DIR/$FOLDER_NAME/*.sql ); do
      echo "prompt @../$FOLDER_NAME/${file##*/}" >> $PROJECT_DIR/$OUTPUT_FILE
      echo "@../$FOLDER_NAME/${file##*/}" >> $PROJECT_DIR/$OUTPUT_FILE
    done
  done

} # list_all_files



# Constrói os arquivos necessários para o release
# Deve ser chamado em build/build.sh
#
# Issue: #28
gen_release_sql(){
  local loc_env_vars="$PROJECT_DIR/release/load_env_vars.sql"
  local loc_apex_install_all="$PROJECT_DIR/release/all_apex.sql"
  # Construir arquivo SQL auxiliar para carregar variáveis de ambiente específicas na sessão SQL*Plus
  echo "-- GERADO pelo build/build.sh NÃO modifique este arquivo diretamente, pois todas as alterações serão sobrescritas no próximo build\n\n" > $loc_env_vars
  echo "define env_schema_name=$SCHEMA_NAME" >> $loc_env_vars
  echo "define env_apex_app_ids=$APEX_APP_IDS" >> $loc_env_vars
  echo "define env_apex_workspace=$APEX_WORKSPACE" >> $loc_env_vars
  echo "" >> $loc_env_vars
  echo "
prompt Variáveis de ambiente
select
  '&env_schema_name.' env_schema_name,
  '&env_apex_app_ids.' env_apex_app_ids,
  '&env_apex_workspace.' env_apex_workspace
from dual;

" >> $loc_env_vars

  # Construir arquivo auxiliar para instalar todas as aplicações APEX
  echo "-- GERADO pelo build/build.sh NÃO modifique este arquivo." > $loc_apex_install_all
  echo "prompt *** Instalação APEX ***" >> $loc_apex_install_all
  for APEX_APP_ID in $(echo $APEX_APP_IDS | sed "s/,/ /g"); do
    echo "prompt *** App: $APEX_APP_ID ***" >> $loc_apex_install_all
    echo "@../scripts/apex_install.sql $SCHEMA_NAME $APEX_WORKSPACE $APEX_APP_ID" >> $loc_apex_install_all
  done
} #gen_release_sql



# #36 Criar novos arquivos rapidamente baseados em arquivos de template
#
# Veja scripts/project-config.sh sobre como definir os vários tipos de objeto
#
# Ações:
# - Criar um novo arquivo na pasta de destino definida
# - Baseado em template
# - Substituir todas as referências a CHANGEME pelo nome do objeto
#
# Parâmetros
# $1 Tipo do objeto
# $2 Nome do objeto
gen_object(){
  # Parâmetros
  local p_object_type=$1
  local p_object_name=$2

  # Variáveis de loop
  local object_type_arr
  local object_type
  local object_template
  local object_dest_folder
  local object_dest_file

  # OBJECT_FILE_TEMPLATE_MAP é definido em scripts/project-config.sh
  for object_type in $(echo $OBJECT_FILE_TEMPLATE_MAP | sed "s/,/ /g"); do

    object_type_arr=(`echo "$object_type" | sed 's/:/ /g'`)

    # Em bash, arrays começam em 0, enquanto em zsh começam em 1
    # A única forma de tornar a referência de array compatível com ambos é especificar o offset e tamanho
    # Veja: https://stackoverflow.com/questions/50427449/behavior-of-arrays-in-bash-scripting-and-zsh-shell-start-index-0-or-1/50433774
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
          cp $object_template.$file_ext $object_dest_file
          sed -i-bak "s/CHANGEME/$p_object_name/g" $object_dest_file
          # Remover versão de backup do arquivo
          rm $object_dest_file-bak
          echo "Criado: $object_dest_file"

          # Abrir arquivo no editor
          code $object_dest_file
        fi
      done

      break # Não é mais necessário iterar pelas outras definições
    fi

  done # OBJECT_FILE_TEMPLATE_MAP

} # gen_object


# Mesclar um arquivo SQL em um único arquivo
# Copiado e modificado de: https://github.com/insum-labs/conference-manager/blob/master/release/build_release_script.sh
#
# Este script recebe um arquivo .sql como entrada e criará um arquivo de saída
# que pode ser processado pelo SQL Workshop no apex.oracle.com
# Isso significa que comandos únicos podem ser executados como estão (por exemplo
# alter, create table, update, inserts, etc.).
# Quando um script é encontrado na forma @../arquivo, ou seja:
# @../views/ks_users_v.sql
# Ele será "expandido" no arquivo de saída (definido por OUT_FILE)
#
# Nota: isso expandirá recursivamente os arquivos.
# Por exemplo, ao chamar "merge_sql_files _release.sql merged_release.sql" e:
# _release.sql referencia _all_packages.sql
# e _all_packages.sql referencia pkg_emp.pks
# Então tanto _all_packages.sql quanto pkg_emp.pks serão expandidos nos pontos em que foram referenciados
#
# Issue: #42
# Exemplo:
# source helper.sh
# merge_sql_files all_packages.sql merged_all_packages.sql
#
# Parâmetros
# $1 Arquivo de entrada
# $2 Arquivo de saída
merge_sql_files(){
  local IN_FILE=$1
  local OUT_FILE=$2

  # Função de log. Chamando "logger" para não conflitar com "log", que é uma função do bash
  logger() {
    echo "`date`: $1"
  } # logger

  #*****************************************************************************
  # Expandir linhas de script ou gerar linhas regulares
  # Parâmetros
  # $1 FILE_LINE: Esta é a linha atual do $IN_FILE
  #******************************************************************************
  process_line (){
    local FILE_LINE=$1

    # logger "É $1 um script?"
    # ${1:1} https://stackoverflow.com/questions/30197247/using-11-in-bash
    # Neste caso, está removendo o "@" de cada linha no script

    if [ -f "${FILE_LINE:1}" ]
    then
      logger "Expandindo arquivo: ${FILE_LINE:1}"
      echo "-- $FILE_LINE" >> $OUT_FILE

      # Abrir recursivamente cada arquivo, pois eles mesmos podem referenciar outros arquivos
      process_file ${FILE_LINE:1}

      # Imprimir linhas em branco
      echo >> $OUT_FILE
      echo >> $OUT_FILE
    else
      echo "$line" >> $OUT_FILE
    fi

  } # process_line


  # Percorrerá um arquivo e processará cada linha
  #
  # Nota: process_line chamará recursivamente esta função
  #
  # Parâmetros
  # $1 nome_do_arquivo
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

  # Iniciar a mesclagem do arquivo original que encontrará recursivamente outros arquivos
  process_file $IN_FILE
} # merge_sql_files


# Inicializar
init(){
  local PROJECT_DIR_FOLDER_NAME=$(basename $PROJECT_DIR)
  local VSCODE_TASK_FILE=$PROJECT_DIR/.vscode/tasks.json


  # #36 Alterar os rótulos do VSCode
  # Veja: https://unix.stackexchange.com/questions/13711/differences-between-sed-on-mac-osx-and-other-standard-sed/131940#131940
  sed -i-bak "s/CHANGEME_TASKLABEL/$PROJECT_DIR_FOLDER_NAME/g" $VSCODE_TASK_FILE
  # Remover versão de backup do arquivo
  rm $VSCODE_TASK_FILE-bak


  # Inicializando Helper
  load_colors
  load_config
  verify_config
}

init
