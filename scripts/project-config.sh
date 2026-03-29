#!/bin/bash

# =============================================================================
# Configuracao do Projeto — Oracle 19-26 / APEX 24.2
# Template: github.com/maxwbh/template_apex
# Guideline: Insum PL/SQL and SQL Coding Guidelines 4.4
# =============================================================================

# Nome do Schema
SCHEMA_NAME=CHANGE_ME
# Nome do workspace padrao das aplicacoes
APEX_WORKSPACE=CHANGE_ME
# Lista separada por virgula de Aplicacoes APEX para exportar. Ex: 100,200
APEX_APP_IDS=CHANGE_ME

# Versao minima do Oracle Database suportada
ORACLE_DB_MIN_VERSION=19
# Versao minima do APEX suportada
APEX_MIN_VERSION=24.2


# Extensoes de arquivo
# Usadas em todos os scripts para gerar listas de packages, views, etc.
EXT_PACKAGE_SPEC=pks
EXT_PACKAGE_BODY=pkb
EXT_VIEW=sql


# Mapeamento de arquivos para geracao via template
# Formato: <nome>:<prefixo_template (sem extensao)>:<extensoes ; delimitado>:<diretorio destino>
#
# Definicoes:
# - nome: identificador do tipo de objeto
# - prefixo_template: caminho do arquivo de template (sem extensao)
# - extensoes: lista ";" delimitada de extensoes de arquivo
# - diretorio destino: onde armazenar o novo arquivo
OBJECT_FILE_TEMPLATE_MAP=""
OBJECT_FILE_TEMPLATE_MAP="$OBJECT_FILE_TEMPLATE_MAP,package:templates/template_pkg:$EXT_PACKAGE_SPEC;$EXT_PACKAGE_BODY:packages"
OBJECT_FILE_TEMPLATE_MAP="$OBJECT_FILE_TEMPLATE_MAP,view:templates/template_view:$EXT_VIEW:views"
OBJECT_FILE_TEMPLATE_MAP="$OBJECT_FILE_TEMPLATE_MAP,data_array:templates/template_data_array:sql:data"
OBJECT_FILE_TEMPLATE_MAP="$OBJECT_FILE_TEMPLATE_MAP,data_json:templates/template_data_json:sql:data"
