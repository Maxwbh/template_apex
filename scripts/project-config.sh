#!/bin/bash

# Nome do Schema
SCHEMA_NAME=CHANGE_ME
# Nome do workspace padrão ao qual as aplicações estão associadas
APEX_WORKSPACE=CHANGE_ME
# Lista separada por vírgula de Aplicações APEX para exportar. Ex: 100,200
APEX_APP_IDS=CHANGE_ME


# Extensões de arquivo
# Serão usadas em todos os scripts para gerar listas de packages, views, etc. a partir do sistema de arquivos
EXT_PACKAGE_SPEC=pks
EXT_PACKAGE_BODY=pkb
EXT_VIEW=sql


# Mapeamento de arquivos
# Será usado no VSCode para permitir a geração rápida de um arquivo baseado em dados de template
# Formato:
# <nome>:<prefixo_arquivo_template (sem extensão)>:<extensões de arquivo (; delimitado)>:<diretório destino>
#
# Definições:
# - nome: Nome que será mapeado para a tarefa do VSCode
# - arquivo de template: Prefixo do arquivo de template a usar (sem extensão)
# - extensões de arquivo: Lista delimitada por ";" de extensões de arquivo para referenciar cada arquivo de template
# - diretório destino: onde armazenar o novo arquivo
OBJECT_FILE_TEMPLATE_MAP=""
OBJECT_FILE_TEMPLATE_MAP="$OBJECT_FILE_TEMPLATE_MAP,package:templates/template_pkg:$EXT_PACKAGE_SPEC;$EXT_PACKAGE_BODY:packages"
OBJECT_FILE_TEMPLATE_MAP="$OBJECT_FILE_TEMPLATE_MAP,view:templates/template_view:$EXT_VIEW:views"
OBJECT_FILE_TEMPLATE_MAP="$OBJECT_FILE_TEMPLATE_MAP,data_array:templates/template_data_array:sql:data"
OBJECT_FILE_TEMPLATE_MAP="$OBJECT_FILE_TEMPLATE_MAP,data_json:templates/template_data_json:sql:data"
