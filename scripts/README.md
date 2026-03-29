# Scripts

> Funções auxiliares, configuração e automação para o ciclo de desenvolvimento.

---

## Início Rápido

```bash
# Carregar todas as funções e configurações
source scripts/helper.sh

# Pronto! Agora você pode usar todas as funções abaixo.
```

---

## Arquivos

| Arquivo | Descrição | Commitado |
|:--|:--|:--:|
| [`helper.sh`](#helpersh) | Funções auxiliares usadas por todos os scripts | Sim |
| [`project-config.sh`](#project-configsh) | Configuração do projeto (schema, apps APEX) | Sim |
| [`user-config.sh`](#user-configsh) | Configuração do usuário (conexão, senhas) | **Não** |
| [`apex_export.sql`](#apex_exportsql) | Script SQLcl para exportar aplicação APEX | Sim |
| [`apex_install.sql`](#apex_installsql) | Script SQLcl para instalar aplicação APEX | Sim |
| [`apex_disable.sql`](#apex_disablesql) | Desabilita aplicações APEX durante release | Sim |

---

## `helper.sh`

Biblioteca principal de funções. Carregue com `source scripts/helper.sh` a partir da raiz do projeto.

### Variáveis de Ambiente

| Variável | Exemplo | Descrição |
|:--|:--|:--|
| `SCRIPT_DIR` | `/home/user/projeto/scripts` | Diretório do helper.sh |
| `PROJECT_DIR` | `/home/user/projeto` | Raiz do repositório |

### Funções

---

#### `export_apex_app`

Exporta aplicações APEX para a pasta `apex/`.

```bash
# Sem versão
export_apex_app

# Com versão (substitui %RELEASE_VERSION% no arquivo exportado)
export_apex_app 1.2.3
```

| Parâmetro | Obrigatório | Descrição |
|:--|:--:|:--|
| `$1` | Não | Número da versão para injetar na aplicação |

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

| Parâmetro | Obrigatório | Descrição |
|:--|:--:|:--|
| `$1` | Sim | Tipo: `package`, `view`, `data_array`, `data_json` |
| `$2` | Sim | Nome do objeto |

> Os tipos disponíveis são configurados em [`project-config.sh`](project-config.sh) na variável `OBJECT_FILE_TEMPLATE_MAP`.

---

#### `list_all_files`

Lista arquivos de uma pasta e gera referências SQL. Chamada automaticamente pelo [`build.sh`](../build/build.sh).

```bash
# Listar views
list_all_files views release/all_views.sql sql

# Listar packages (spec antes do body)
list_all_files packages release/all_packages.sql pks,pkb
```

| Parâmetro | Obrigatório | Descrição |
|:--|:--:|:--|
| `$1` | Sim | Pasta relativa à raiz (ex: `views`) |
| `$2` | Sim | Arquivo de saída (ex: `release/all_views.sql`) |
| `$3` | Não | Extensões separadas por vírgula. Padrão: `sql` |

> **Dica:** A ordem das extensões importa. Use `pks,pkb` para compilar specs antes dos bodies.

---

#### `reset_release`

Limpa a pasta `release/code/` e reseta `_run_code.sql` após um release.

```bash
# O parâmetro deve ser o nome da pasta raiz do projeto
reset_release template_apex

# Resultado:
#   release/code/*.sql   -> removidos
#   release/code/_run_code.sql -> resetado com conteúdo padrão
```

| Parâmetro | Obrigatório | Descrição |
|:--|:--:|:--|
| `$1` | Sim | Nome da pasta raiz do projeto (segurança contra exclusão acidental) |

---

#### `merge_sql_files`

Mescla múltiplos arquivos SQL em um único arquivo, expandindo referências `@arquivo.sql` recursivamente. Útil para deploys no apex.oracle.com.

```bash
cd release
merge_sql_files _release.sql merged_release.sql
```

| Parâmetro | Obrigatório | Descrição |
|:--|:--:|:--|
| `$1` | Sim | Arquivo de entrada |
| `$2` | Sim | Arquivo de saída (mesclado) |

<details>
<summary>Exemplo de expansão</summary>

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

**Saída:** `merged_release.sql`
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

Configuração compartilhada do projeto. **Commitada no git.**

```bash
# Exemplo de configuração
SCHEMA_NAME=VENDAS
APEX_WORKSPACE=WORKSPACE_VENDAS
APEX_APP_IDS=100,200

# Extensões de arquivo
EXT_PACKAGE_SPEC=pks
EXT_PACKAGE_BODY=pkb
EXT_VIEW=sql
```

> **Nunca** coloque informações sensíveis neste arquivo.

---

## `user-config.sh`

Configuração individual do desenvolvedor. **NÃO commitada no git** (está no `.gitignore`).

Gerada automaticamente na primeira execução de qualquer script bash.

```bash
# Exemplo de configuração
DB_CONN="vendas_dev/minha_senha@localhost:1521/xe"
SQLCL=sql
SQLPLUS=sqlplus
VSCODE_TASK_COMPILE_BIN=$SQLPLUS
```

---

## `apex_export.sql`

Exporta uma aplicação APEX via SQLcl.

```bash
# Exportar aplicação 100 como arquivo único
echo exit | sqlcl usuario/senha@servidor:1521/xe @apex_export.sql 100

# Exportar como arquivos divididos
echo exit | sqlcl usuario/senha@servidor:1521/xe @apex_export.sql 100 -split
```

| Parâmetro | Descrição |
|:--|:--|
| `1` | ID da aplicação |
| `2` | Opções de exportação (ex: `-split`). Opcional |

---

## `apex_install.sql`

Instala uma aplicação APEX no banco.

| Parâmetro | Descrição |
|:--|:--|
| `1` | Schema de destino |
| `2` | Workspace de destino |
| `3` | ID da aplicação |

---

## `apex_disable.sql`

Desabilita aplicações APEX (status "Indisponível") durante o release. Executa `commit` ao final.

```bash
echo exit | sqlcl usuario/senha@servidor:1521/xe @apex_disable.sql 100,200
```

| Parâmetro | Descrição |
|:--|:--|
| `1` | IDs separados por vírgula (ex: `100,200`) |

> **Nota:** Se receber erro `ORA-20987`, habilite "Modificar Esta Aplicação" em:
> Componentes Compartilhados > Atributos de Segurança > Uso de API em Tempo de Execução

---

<sub>Mantido por <a href="https://github.com/maxwbh">@maxwbh</a> — Maxwell da Silva Oliveira — M&S do Brasil LTDA</sub>
