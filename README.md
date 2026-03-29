<p align="center">
  <strong>Template APEX v2.0.0</strong><br>
  Template profissional para Oracle 19-26, APEX 24.2 e PL/SQL
</p>

<p align="center">
  <a href="https://github.com/maxwbh/template_apex"><img src="https://img.shields.io/badge/Oracle-19--26-red?style=for-the-badge&logo=oracle" alt="Oracle 19-26"></a>
  <a href="https://github.com/maxwbh/template_apex"><img src="https://img.shields.io/badge/APEX-24.2-orange?style=for-the-badge&logo=oracle" alt="APEX 24.2"></a>
  <a href="https://github.com/insum-labs/plsql-and-sql-coding-guidelines"><img src="https://img.shields.io/badge/Guideline-Insum%204.4-blue?style=for-the-badge" alt="Guideline Insum 4.4"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/licen%C3%A7a-CC0%201.0-green?style=for-the-badge" alt="Licenca"></a>
  <a href="https://github.com/maxwbh"><img src="https://img.shields.io/badge/mantido%20por-%40maxwbh-purple?style=for-the-badge&logo=github" alt="Mantido por @maxwbh"></a>
</p>

---

> **Mantido por** [@maxwbh](https://github.com/maxwbh) — Maxwell da Silva Oliveira — **M&S do Brasil LTDA**
>
> Template para Oracle Database 19-26 / APEX 24.2 seguindo as [Insum PL/SQL and SQL Coding Guidelines 4.4](https://github.com/insum-labs/plsql-and-sql-coding-guidelines). Fornece scripts, processos e estrutura de pastas para acelerar o desenvolvimento e simplificar releases.

---

## Inicio Rapido

```bash
# 1. Clone ou use como template
git clone https://github.com/maxwbh/template_apex.git meu-projeto
cd meu-projeto

# 2. Configure o projeto
nano scripts/project-config.sh        # schema, workspace, app IDs

# 3. Execute qualquer script para gerar a config do usuario
source scripts/helper.sh              # gera scripts/user-config.sh
nano scripts/user-config.sh           # conexao com o banco

# 4. Comece a desenvolver!
```

> **Importante:** Este e um **template**. Ajuste conforme as necessidades do seu projeto. Remova o que nao for necessario.

---

## Visao Geral

<table>
<tr>
<td width="50%">

### O que esta incluido

- **Oracle 19-26** — Identity columns (12c+), `timestamp with local time zone`, DDL `IF NOT EXISTS` (23c+)
- **APEX 24.2** — export com `-skipExportDate`, APIs atualizadas
- **Guideline Insum 4.4** — prefixos `l_`, `p_`, `gc_`, `t_`, Logger, documentacao
- **Build automatizado** — gera scripts de release com um comando
- **Integracao VSCode** — compile PL/SQL com warnings habilitados
- **Templates prontos** — tabelas, packages, views e dados

</td>
<td width="50%">

### Fluxo de trabalho

```
 Desenvolver        Construir         Executar
+-----------+     +-----------+     +-----------+
| packages/ |     |  build.sh |     | _release  |
| views/    | --> |  <versao> | --> |   .sql    |
| data/     |     |           |     |           |
+-----------+     +-----------+     +-----------+
                        |                 |
                        v                 v
                  Gera all_*.sql    Deploy no BD
```

</td>
</tr>
</table>

---

## Configuracao

### Passo 1 — Configuracao do Projeto

Edite [`scripts/project-config.sh`](scripts/project-config.sh) com as informacoes do seu ambiente:

```bash
# scripts/project-config.sh
SCHEMA_NAME=MEU_SCHEMA
APEX_WORKSPACE=MEU_WORKSPACE
APEX_APP_IDS=100,200
```

### Passo 2 — Configuracao do Usuario

Na primeira execucao de qualquer script, o arquivo `scripts/user-config.sh` sera criado automaticamente:

```bash
# scripts/user-config.sh (gerado automaticamente, NAO commitado no git)
DB_CONN="usuario/senha@servidor:1521/xe"
SQLCL=sql
SQLPLUS=sqlplus
```

### Passo 3 — Limpeza

Remova diretorios que nao se aplicam ao seu projeto:

```bash
# Exemplo: projeto sem triggers, synonyms ou assets web
rm -rf synonyms/ triggers/ www/
```

---

## Estrutura de Pastas

```
template_apex/
|
|-- .vscode/              # Configuracoes e tarefas do VSCode
|   |-- scripts/          # Scripts de compilacao e exportacao
|   |-- tasks.json        # Definicao de tarefas
|   +-- settings.json     # Associacoes de arquivos PL/SQL
|
|-- apex/                 # Exportacoes de aplicacoes APEX
|-- build/                # Scripts de build do release
|   +-- build.sh          # Script principal de build
|
|-- data/                 # Scripts de dados re-executaveis (LOVs, seed)
|-- docs/                 # Documentacao do projeto
|-- lib/                  # Bibliotecas (Logger, OOS Utils)
|-- packages/             # Package specs (.pks) e bodies (.pkb)
|
|-- release/              # Framework de release
|   |-- code/             # Codigo nao re-executavel por release
|   |-- _release.sql      # Script principal de release
|   +-- all_*.sql         # Arquivos gerados pelo build
|
|-- scripts/              # Scripts auxiliares e configuracao
|   |-- helper.sh         # Funcoes auxiliares
|   |-- project-config.sh # Config do projeto (commitada)
|   +-- user-config.sh    # Config do usuario (NAO commitada)
|
|-- synonyms/             # Sinonimos do banco
|-- templates/            # Templates de codigo
|-- triggers/             # Triggers do banco
|-- views/                # Views do banco
+-- www/                  # Assets web (CSS, JS, imagens)
    +-- src/
        |-- css/
        |-- img/
        |-- js/
        +-- lib/
```

---

## Exemplo Completo de Uso

O exemplo abaixo mostra o ciclo completo: criar objetos, desenvolver, fazer build e release.

### 1. Criar novos objetos

```bash
# Carregar funcoes auxiliares
source scripts/helper.sh

# Criar um novo package
gen_object package pkg_clientes
# -> Cria: packages/pkg_clientes.pks
# -> Cria: packages/pkg_clientes.pkb

# Criar uma nova view
gen_object view vw_clientes_ativos
# -> Cria: views/vw_clientes_ativos.sql

# Criar um script de dados
gen_object data_array data_status_pedido
# -> Cria: data/data_status_pedido.sql
```

### 2. Desenvolver o codigo

```sql
-- packages/pkg_clientes.pks
create or replace package pkg_clientes as
  procedure inserir_cliente(
    p_nome in varchar2,
    p_email in varchar2
  );
  function buscar_por_email(
    p_email in varchar2
  ) return clientes%rowtype;
end pkg_clientes;
/
```

```sql
-- views/vw_clientes_ativos.sql
create or replace force view vw_clientes_ativos as
  select
    c.cliente_id,
    c.nome,
    c.email,
    c.created_on as data_cadastro
  from clientes c
  where c.status_code = 'ATIVO'
;
```

```sql
-- release/code/issue-42.sql
-- Adicionar coluna de telefone na tabela clientes
alter table clientes add (telefone varchar2(20));
comment on column clientes.telefone is 'Telefone de contato do cliente';
```

### 3. Registrar o codigo do release

```sql
-- release/code/_run_code.sql
@issue-42.sql
```

### 4. Construir o release

```bash
# Gerar todos os arquivos do release
./build/build.sh 1.0.0

# Resultado:
#   release/all_views.sql      -> lista todas as views
#   release/all_packages.sql   -> lista todos os packages
#   release/all_apex.sql       -> comandos de instalacao APEX
#   release/load_env_vars.sql  -> variaveis de ambiente
```

### 5. Executar o release

```bash
# Conectar ao banco e executar
source scripts/helper.sh
cd release
$SQLCL usuario/senha@servidor:1521/xe @_release.sql

# O _release.sql executa na ordem:
#   1. Carrega variaveis de ambiente
#   2. Desabilita aplicacoes APEX
#   3. Executa DDL/DML do release (code/)
#   4. Compila views e packages
#   5. Carrega dados
#   6. Instala aplicacoes APEX
#   7. Recompila objetos invalidos
```

### 6. Limpar apos o release

```bash
source scripts/helper.sh
reset_release template_apex
# -> Limpa release/code/*.sql
# -> Reseta release/code/_run_code.sql
```

---

## Compilacao via VSCode

Use as tarefas integradas para compilar sem sair do editor:

| Atalho | Tarefa | Descricao |
|:--|:--|:--|
| `Ctrl+Shift+B` | `compilar: <projeto>` | Compila o arquivo PL/SQL atual |
| `Ctrl+Shift+B` | `exportar apex: <projeto>` | Exporta aplicacoes APEX |
| `Ctrl+Shift+B` | `gerar objeto: <projeto>` | Cria novo objeto via template |

> Veja detalhes completos em [`.vscode/README.md`](.vscode/README.md)

---

## Padroes de Codigo — Guideline Insum 4.4

Este template segue as [Insum PL/SQL and SQL Coding Guidelines 4.4](https://github.com/insum-labs/plsql-and-sql-coding-guidelines):

### Nomenclatura de Variaveis

| Prefixo | Uso | Exemplo |
|:--|:--|:--|
| `l_` | Variavel local | `l_count`, `l_result` |
| `p_` | Parametro | `p_cliente_id`, `p_nome` |
| `gc_` | Constante global (package) | `gc_scope_prefix`, `gc_status_ativo` |
| `g_` | Variavel global (package) | `g_config_cache` |
| `c_` | Constante local | `c_max_tentativas` |
| `t_` | Tipo definido pelo usuario | `t_rec_data`, `t_tab_clientes` |
| `cur_` | Cursor | `cur_clientes_ativos` |
| `e_` | Excecao | `e_registro_nao_encontrado` |

### Regras Principais

```sql
-- G-2180: usar identity columns
change_me_id number generated always as identity not null

-- G-2340: timestamp com timezone para auditoria
created_on timestamp with local time zone default localtimestamp not null

-- G-4120: listar colunas explicitamente (nunca select *)
select c.cliente_id, c.nome from clientes c

-- G-5010: tratar excecoes no nivel mais proximo
exception when others then
  logger.log_error('Excecao nao tratada', l_scope, null, l_params);
  raise;

-- G-5020: registrar parametros de entrada
logger.append_param(l_params, 'p_cliente_id', p_cliente_id);

-- Oracle 23c+: DDL com IF NOT EXISTS (opcional, nao disponivel em 19/21)
-- create table if not exists minha_tabela (...)
create table minha_tabela (...)
```

> Referencia completa: [github.com/insum-labs/plsql-and-sql-coding-guidelines](https://github.com/insum-labs/plsql-and-sql-coding-guidelines)
> Veja tambem: [`CONTRIBUTING.md`](CONTRIBUTING.md) para convencoes detalhadas.

---

## Fluxos de Trabalho Git

Recomendamos o [GitHub Flow](https://guides.github.com/introduction/flow/) pela simplicidade. Outras opcoes:

| Fluxo | Melhor para | Link |
|:--|:--|:--|
| **GitHub Flow** | Maioria dos projetos Oracle | [Documentacao](https://guides.github.com/introduction/flow/) |
| **git-flow** | Projetos com releases formais | [Documentacao](https://www.git-tower.com/learn/git/ebook/en/command-line/advanced-topics/git-flow) |
| **GitLab Flow** | Equipes usando GitLab | [Documentacao](https://docs.gitlab.com/ee/topics/gitlab_flow.html) |

---

<details>
<summary><strong>Configuracao Windows (WSL / cmder)</strong></summary>

<br>

Todos os scripts sao escritos em bash para Linux/macOS. No Windows, use uma das opcoes:

### Opcao 1 — WSL (recomendado)

Instale o [Windows Subsystem for Linux](https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux).

### Opcao 2 — cmder

1. Baixe o [cmder](https://cmder.net/) e descompacte em `c:\cmder`
2. Execute `c:\cmder\Cmder.exe` (fixe na barra de tarefas)
3. Para integrar com o VSCode, adicione ao `settings.json`:

```json
{
  "terminal.integrated.shell.windows": "C:\\cmder\\vendor\\git-for-windows\\bin\\bash.exe",
  "terminal.integrated.automationShell.linux": ""
}
```

</details>

<details>
<summary><strong>Recursos para aprender Git</strong></summary>

<br>

- [Comandos Git Visualizados](https://dev.to/lydiahallie/cs-visualized-useful-git-commands-37p1)
- [Git - Guia Pratico](https://rogerdudler.github.io/git-guide/index.pt_BR.html)
- [Versionamento Semantico](https://semver.org/lang/pt-BR/)

</details>

---

<p align="center">
  <sub>
    Mantido por <a href="https://github.com/maxwbh">@maxwbh</a> — Maxwell da Silva Oliveira — M&S do Brasil LTDA<br>
    Oracle 19-26 / APEX 24.2 / <a href="https://github.com/insum-labs/plsql-and-sql-coding-guidelines">Guideline Insum 4.4</a><br>
    Baseado no <a href="https://github.com/insum-labs/starter-project-template">Starter Project Template</a> da InSum Labs — Licenca CC0 1.0 Universal
  </sub>
</p>
