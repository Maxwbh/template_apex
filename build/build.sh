#!/bin/bash

# =============================================================================
# Build Script — Oracle 26 / APEX 24.2
# Template: github.com/maxwbh/template_apex
# =============================================================================
# ./build.sh <versao>
# Parametros:
#   versao: Numero da versao incorporado no release APEX.

if [ -z "$1" ]; then
  echo 'Numero de versao ausente. Uso: ./build.sh <versao>'
  echo 'Exemplo: ./build.sh 2.0.0'
  exit 1
fi

VERSION=$1

# Diretorio deste arquivo
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Carregar Helper e configuracao
source "$SCRIPT_DIR/../scripts/helper.sh"


echo -e "=== Build Release v$VERSION ==="
echo -e "Oracle 26 / APEX 24.2 / Guideline Insum 4.4\n"

echo -e "*** Listando todas as views e packages ***\n"
list_all_files views release/all_views.sql "$EXT_VIEW"
list_all_files packages release/all_packages.sql "$EXT_PACKAGE_SPEC,$EXT_PACKAGE_BODY"

# Listar triggers se existirem
if ls "$PROJECT_DIR/triggers"/*.sql 1>/dev/null 2>&1; then
  echo -e "\n*** Listando todos os triggers ***\n"
  list_all_files triggers release/all_triggers.sql sql
fi

# Exportar aplicacoes APEX, definidas em project-config.sh
echo -e "\n*** Exportando aplicacoes APEX ***\n"
export_apex_app "$VERSION"

# Gerar arquivos SQL de suporte ao release
echo -e "\n*** Gerando scripts de release ***\n"
gen_release_sql

echo -e "\n=== Build v$VERSION concluido ==="
