# Scripts

> Funcoes auxiliares, configuracao e automacao para o ciclo de desenvolvimento.

---

## Inicio Rapido

```bash
# Carregar todas as funcoes e configuracoes
source scripts/helper.sh

# Pronto! Agora voce pode usar todas as funcoes abaixo.
```

---

## Arquivos

| Arquivo | Descricao | Commitado |
|:--|:--|:--:|
| [`helper.sh`](#helpersh) | Funcoes auxiliares usadas por todos os scripts | Sim |
| [`project-config.sh`](#project-configsh) | Configuracao do projeto (schema, apps APEX) | Sim |
| [`user-config.sh`](#user-configsh) | Configuracao do usuario (conexao, senhas) | **Nao** |
| [`apex_export.sql`](#apex_exportsql) | Script SQLcl para exportar aplicacao APEX | Sim |
| [`apex_install.sql`](#apex_installsql) | Script SQLcl para instalar aplicacao APEX | Sim |
| [`apex_disable.sql`](#apex_disablesql) | Desabilita aplicacoes APEX durante release | Sim |

---

## `helper.sh`

Biblioteca principal de funcoes. Carregue com `source scripts/helper.sh` a partir da raiz do projeto.

### Variaveis de Ambiente

| Variavel | Exemplo | Descricao |
|:--|:--|:--|
| `SCRIPT_DIR` | `/home/user/projeto/scripts` | Diretorio do helper.sh |
| `PROJECT_DIR` | `/home/user/projeto` | Raiz do repositorio |

### Funcoes

---

#### `export_apex_app`

Exporta aplicacoes APEX para a pasta `apex/`.

```bash
# Sem versao
export_apex_app

# Com versao (substitui %RELEASE_VERSION% no arquivo exportado)
export_apex_app 1.2.3
```

| Parametro | Obrigatorio | Descricao |
|:--|:--:|:--|
| `$1` | Nao | Numero da versao para injetar na aplicacao |

---

#### `gen_object`

Cria novos arquivos a partir de templates, substituindo `CHANGEME` pelo nome informado.

```bash
# Criar package
gen_object package pkg_pedidos
# -> packages/pkg_pedidos.pks
# -> packages/pkg_pedidos.pkb

# Criar view
gen_object view vw_pedidos
# -> views/vw_pedidos.sql

# Criar script de dados (array)
gen_object data_array data_tipos_pagamento
# -> data/data_tipos_pagamento.sql

# Criar script de dados (JSON)
gen_object data_json data_categorias
# -> data/data_categorias.sql
```

| Parametro | Obrigatorio | Descricao |
|:--|:--:|:--|
| `$1` | Sim | Tipo: `package`, `view`, `data_array`, `data_json` |
| `$2` | Sim | Nome do objeto |

> Os tipos disponiveis sao configurados em [`project-config.sh`](project-config.sh) na variavel `OBJECT_FILE_TEMPLATE_MAP`.

---

#### `list_all_files`

Lista arquivos de uma pasta e gera referencias SQL. Chamada automaticamente pelo [`build.sh`](../build/build.sh).

```bash
# Listar views
list_all_files views release/all_views.sql sql

# Listar packages (spec antes do body)
list_all_files packages release/all_packages.sql pks,pkb
```

| Parametro | Obrigatorio | Descricao |
|:--|:--:|:--|
| `$1` | Sim | Pasta relativa a raiz (ex: `views`) |
| `$2` | Sim | Arquivo de saida (ex: `release/all_views.sql`) |
| `$3` | Nao | Extensoes separadas por virgula. Padrao: `sql` |

> **Dica:** A ordem das extensoes importa. Use `pks,pkb` para compilar specs antes dos bodies.

---

#### `reset_release`

Limpa a pasta `release/code/` e reseta `_run_code.sql` apos um release.

```bash
# O parametro deve ser o nome da pasta raiz do projeto
reset_release template_apex

# Resultado:
#   release/code/*.sql   -> removidos
#   release/code/_run_code.sql -> resetado com conteudo padrao
```

| Parametro | Obrigatorio | Descricao |
|:--|:--:|:--|
| `$1` | Sim | Nome da pasta raiz do projeto (seguranca contra exclusao acidental) |

---

#### `merge_sql_files`

Mescla multiplos arquivos SQL em um unico arquivo, expandindo referencias `@arquivo.sql` recursivamente. Util para deploys no apex.oracle.com.

```bash
cd release
merge_sql_files _release.sql merged_release.sql
```

| Parametro | Obrigatorio | Descricao |
|:--|:--:|:--|
| `$1` | Sim | Arquivo de entrada |
| `$2` | Sim | Arquivo de saida (mesclado) |

<details>
<summary>Exemplo de expansao</summary>

<br>

**Entrada:** `_release.sql`
```sql
update config set release_date = sysdate;
@all_packages.sql
```

**`all_packages.sql`** referencia:
```sql
@../packages/pkg_emp.pks
@../packages/pkg_emp.pkb
```

**Saida:** `merged_release.sql`
```sql
-- _release.sql
update config set release_date = sysdate;
-- referenciando @all_packages.sql
-- referenciando @../packages/pkg_emp.pks
create or replace package pkg_emp ...
-- referenciando @../packages/pkg_emp.pkb
create or replace package body pkg_emp ...
```

</details>

---

## `project-config.sh`

Configuracao compartilhada do projeto. **Commitada no git.**

```bash
# Exemplo de configuracao
SCHEMA_NAME=VENDAS
APEX_WORKSPACE=WORKSPACE_VENDAS
APEX_APP_IDS=100,200

# Extensoes de arquivo
EXT_PACKAGE_SPEC=pks
EXT_PACKAGE_BODY=pkb
EXT_VIEW=sql
```

> **Nunca** coloque informacoes sensiveis neste arquivo.

---

## `user-config.sh`

Configuracao individual do desenvolvedor. **NAO commitada no git** (esta no `.gitignore`).

Gerada automaticamente na primeira execucao de qualquer script bash.

```bash
# Exemplo de configuracao
DB_CONN="vendas_dev/minha_senha@localhost:1521/xe"
SQLCL=sql
SQLPLUS=sqlplus
VSCODE_TASK_COMPILE_BIN=$SQLPLUS
```

---

## `apex_export.sql`

Exporta uma aplicacao APEX via SQLcl.

```bash
# Exportar aplicacao 100 como arquivo unico
echo exit | sqlcl usuario/senha@servidor:1521/xe @apex_export.sql 100

# Exportar como arquivos divididos
echo exit | sqlcl usuario/senha@servidor:1521/xe @apex_export.sql 100 -split
```

| Parametro | Descricao |
|:--|:--|
| `1` | ID da aplicacao |
| `2` | Opcoes de exportacao (ex: `-split`). Opcional |

---

## `apex_install.sql`

Instala uma aplicacao APEX no banco.

| Parametro | Descricao |
|:--|:--|
| `1` | Schema de destino |
| `2` | Workspace de destino |
| `3` | ID da aplicacao |

---

## `apex_disable.sql`

Desabilita aplicacoes APEX (status "Indisponivel") durante o release. Executa `commit` ao final.

```bash
echo exit | sqlcl usuario/senha@servidor:1521/xe @apex_disable.sql 100,200
```

| Parametro | Descricao |
|:--|:--|
| `1` | IDs separados por virgula (ex: `100,200`) |

> **Nota:** Se receber erro `ORA-20987`, habilite "Modificar Esta Aplicacao" em:
> Componentes Compartilhados > Atributos de Seguranca > Uso de API em Tempo de Execucao

---

<sub>Mantido por <a href="https://github.com/maxwbh">@maxwbh</a> — Maxwell da Silva Oliveira — M&S do Brasil LTDA</sub>
