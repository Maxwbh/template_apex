#!/bin/bash
# Variáveis de ambiente $1, $2, etc. vêm do array args do tasks.json

# Diretório deste arquivo
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Carregar helper
source $SCRIPT_DIR/../../scripts/helper.sh

# Gerar objeto
gen_object $1  $2
