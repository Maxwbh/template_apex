<p align="center">
  <strong>Diretrizes de Contribuição</strong><br>
  Padrões, convenções e fluxo de trabalho para contribuir neste projeto
</p>

<p align="center">
  <a href="https://github.com/maxwbh"><img src="https://img.shields.io/badge/mantido%20por-%40maxwbh-purple?style=for-the-badge&logo=github" alt="@maxwbh"></a>
  <a href="https://github.com/insum-labs/plsql-and-sql-coding-guidelines"><img src="https://img.shields.io/badge/Guideline-Insum%204.4-blue?style=for-the-badge" alt="Guideline Insum 4.4"></a>
  <a href="https://github.com/maxwbh/template_apex"><img src="https://img.shields.io/badge/Oracle%2019--26-APEX%2024.2-red?style=for-the-badge&logo=oracle" alt="Oracle 19-26 / APEX 24.2"></a>
</p>

---

## Visão Geral

Este repositório é um template para projetos **Oracle 19-26 / APEX 24.2** seguindo as [Insum PL/SQL and SQL Coding Guidelines 4.4](https://github.com/insum-labs/plsql-and-sql-coding-guidelines). Mantido por [@maxwbh](https://github.com/maxwbh) (Maxwell da Silva Oliveira — M&S do Brasil LTDA).

---

## Fluxo de Trabalho

```
1. Configurar    2. Desenvolver    3. Build       4. Release     5. Limpar
+----------+    +-------------+   +----------+   +----------+   +----------+
| project- |    | packages/   |   | build.sh |   | _release |   | reset_   |
| config   | -> | views/      | ->| <versão> | ->|   .sql   | ->| release  |
| .sh      |    | data/       |   |          |   |          |   |          |
+----------+    | release/    |   +----------+   +----------+   +----------+
                | code/       |
                +-------------+
```

### Passo a passo

1. **Configurar**: Edite `scripts/project-config.sh` e execute qualquer script para gerar `user-config.sh`
2. **Desenvolver**: Crie código nas pastas apropriadas
3. **Build**: Execute `./build/build.sh <versão>`
4. **Release**: Execute `_release.sql` no banco (veja [`release/README.md`](release/README.md))
5. **Limpar**: Execute `reset_release` após cada release

---

## Padrões de Código

### PL/SQL — [Guideline Insum 4.4](https://github.com/insum-labs/plsql-and-sql-coding-guidelines)

```sql
-- Guideline G-1110/G-1120/G-1130: Prefixos obrigatórios
gc_scope_prefix constant varchar2(31) := lower($$plsql_unit) || '.';  -- gc_ constante global
g_config_cache  varchar2(4000);                                        -- g_  variável global
l_result        varchar2(4000);                                        -- l_  variável local
p_cliente_id    number;                                                 -- p_  parâmetro
t_rec_data      ...;                                                    -- t_  tipo
c_max_rows      constant number := 1000;                                -- c_  constante local

-- Guideline G-5020: Registrar parâmetros de entrada com Logger
logger.append_param(l_params, 'p_cliente_id', p_cliente_id);
logger.log('INICIO', l_scope, null, l_params);

-- Guideline G-5010: Tratar exceções no nível mais próximo
exception
  when others then
    logger.log_error('Exceção não tratada', l_scope, null, l_params);
    raise;

-- Oracle 23c+: DDL com IF NOT EXISTS (opcional, não disponível em 19/21)
-- create table if not exists clientes (...);
create table clientes (...);

-- Oracle 9i+: timestamp com timezone para auditoria
created_on timestamp with local time zone default localtimestamp not null
```

### SQL

| Guideline | Regra | Exemplo |
|:--|:--|:--|
| G-4120 | Listar colunas explicitamente | Nunca `select *` |
| G-5070 | Scripts re-executáveis | `MERGE` ao invés de `INSERT` |
| G-2180 | Identity columns | `generated always as identity` |
| G-2150 | Documentar objetos | `comment on table/column` |
| - | DDL não re-executável | Em `release/code/issue-XXX.sql` |

---

## Convenções de Nomenclatura

| Tipo | Padrão | Exemplo |
|:--|:--|:--|
| Package spec | `pkg_<nome>.pks` | `pkg_clientes.pks` |
| Package body | `pkg_<nome>.pkb` | `pkg_clientes.pkb` |
| View | `vw_<nome>.sql` | `vw_clientes_ativos.sql` |
| Tabela | `<nome_singular>` | `cliente`, `pedido` |
| Script de dados | `data_<tabela>.sql` | `data_status_pedido.sql` |
| Código de release | `issue-<número>.sql` | `issue-42.sql` |

### Colunas de Auditoria Padrão

Toda tabela deve incluir:

```sql
created_on   date default sysdate not null,
created_by   varchar2(255) default coalesce(
               sys_context('APEX$SESSION','app_user'),
               sys_context('userenv','session_user')
             ) not null,
updated_on   date,
updated_by   varchar2(255)
```

---

## Estrutura do Projeto

```
template_apex/
|-- apex/         Exportações de aplicações APEX
|-- build/        Scripts de build do release
|-- data/         Scripts de dados re-executáveis (seed, LOVs)
|-- docs/         Documentação do projeto
|-- lib/          Bibliotecas de terceiros (Logger, OOS Utils)
|-- packages/     Package specs (.pks) e bodies (.pkb)
|-- release/      Scripts de release e código específico
|-- scripts/      Scripts auxiliares e configuração
|-- synonyms/     Sinônimos do banco
|-- templates/    Templates de código
|-- triggers/     Triggers do banco
|-- views/        Views do banco
+-- www/          Assets web (CSS, JS, imagens)
```

---

## Versionamento

Utilize [Versionamento Semântico](https://semver.org/lang/pt-BR/): `major.minor.patch`

| Tipo | Quando usar | Exemplo |
|:--|:--|:--|
| **major** | Alterações incompatíveis | `1.0.0` -> `2.0.0` |
| **minor** | Novas funcionalidades compatíveis | `1.0.0` -> `1.1.0` |
| **patch** | Correções de bugs | `1.0.0` -> `1.0.1` |

---

## Commits

### Formato

```
<tipo>: <descrição curta>

<corpo opcional com mais detalhes>
```

### Tipos

| Tipo | Uso |
|:--|:--|
| `feat` | Nova funcionalidade |
| `fix` | Correção de bug |
| `refactor` | Refatoração sem mudança de comportamento |
| `docs` | Alteração em documentação |
| `chore` | Tarefas de manutenção |

### Exemplos

```bash
git commit -m "feat: adiciona procedure de cálculo de frete no pkg_pedidos"
git commit -m "fix: corrige validação de CPF no pkg_clientes #42"
git commit -m "docs: atualiza README com exemplos de uso"
```

> Todos os commits devem ser atribuídos a [@maxwbh](https://github.com/maxwbh).

---

## Contato

| | |
|:--|:--|
| **Responsável** | [@maxwbh](https://github.com/maxwbh) — Maxwell da Silva Oliveira |
| **Empresa** | M&S do Brasil LTDA |
| **Repositório** | [github.com/maxwbh/template_apex](https://github.com/maxwbh/template_apex) |

---

<sub>Mantido por <a href="https://github.com/maxwbh">@maxwbh</a> — Maxwell da Silva Oliveira — M&S do Brasil LTDA</sub>
