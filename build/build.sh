#!/bin/bash

# ./build.sh <versão>
# Parâmetros
#   versão: Este valor é incorporado no release da aplicação APEX.

if [ -z "$1" ]; then
  echo 'Número de versão ausente'
  exit 1
fi

VERSION=$1

# Este é o diretório onde este arquivo está localizado
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# echo "Diretório Inicial: $SCRIPT_DIR\n"

# Carregar Helper e configuração
source $SCRIPT_DIR/../scripts/helper.sh


echo -e "*** Listando todas as views e packages ***\n"
list_all_files views release/all_views.sql $EXT_VIEW
list_all_files packages release/all_packages.sql $EXT_PACKAGE_SPEC,$EXT_PACKAGE_BODY

# TODO #10 Configuração do APEX Nitro
# echo -e "*** Publicação APEX Nitro ***\n"
# apex-nitro publish gre

# Exportar aplicações APEX, definidas em project-config.sh
export_apex_app $VERSION

# Gerar arquivos SQL de suporte ao release
gen_release_sql
