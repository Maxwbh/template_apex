<p align="center">
  <strong>Diretrizes de Contribuicao</strong><br>
  Padroes, convencoes e fluxo de trabalho para contribuir neste projeto
</p>

<p align="center">
  <a href="https://github.com/maxwbh"><img src="https://img.shields.io/badge/mantido%20por-%40maxwbh-purple?style=for-the-badge&logo=github" alt="@maxwbh"></a>
  <a href="https://github.com/maxwbh/template_apex"><img src="https://img.shields.io/badge/M%26S%20do%20Brasil-LTDA-blue?style=for-the-badge" alt="M&S do Brasil"></a>
</p>

---

## Visao Geral

Este repositorio e um template para projetos Oracle APEX/PL-SQL mantido por [@maxwbh](https://github.com/maxwbh) (Maxwell da Silva Oliveira — M&S do Brasil LTDA).

---

## Fluxo de Trabalho

```
1. Configurar    2. Desenvolver    3. Build       4. Release     5. Limpar
+----------+    +-------------+   +----------+   +----------+   +----------+
| project- |    | packages/   |   | build.sh |   | _release |   | reset_   |
| config   | -> | views/      | ->| <versao> | ->|   .sql   | ->| release  |
| .sh      |    | data/       |   |          |   |          |   |          |
+----------+    | release/    |   +----------+   +----------+   +----------+
                | code/       |
                +-------------+
```

### Passo a passo

1. **Configurar**: Edite `scripts/project-config.sh` e execute qualquer script para gerar `user-config.sh`
2. **Desenvolver**: Crie codigo nas pastas apropriadas
3. **Build**: Execute `./build/build.sh <versao>`
4. **Release**: Execute `_release.sql` no banco (veja [`release/README.md`](release/README.md))
5. **Limpar**: Execute `reset_release` apos cada release

---

## Padroes de Codigo

### PL/SQL

```sql
-- Use Logger para rastreamento
logger.log('INICIO', l_scope, null, l_params);

-- Documente procedures com blocos padrao
/**
 * Descricao da procedure
 *
 * @author @maxwbh
 * @created 2026-03-28
 * @param p_cliente_id ID do cliente
 * @return
 */

-- Trate excecoes adequadamente
exception
  when others then
    logger.log_error('Excecao nao tratada', l_scope, null, l_params);
    raise;
```

### SQL

| Regra | Exemplo |
|:--|:--|
| Scripts de dados devem ser **re-executaveis** | Use `MERGE` ao inves de `INSERT` |
| DDL nao re-executavel | Coloque em `release/code/issue-XXX.sql` |
| Nomeie por ticket | `issue-42.sql`, `issue-123.sql` |

---

## Convencoes de Nomenclatura

| Tipo | Padrao | Exemplo |
|:--|:--|:--|
| Package spec | `pkg_<nome>.pks` | `pkg_clientes.pks` |
| Package body | `pkg_<nome>.pkb` | `pkg_clientes.pkb` |
| View | `vw_<nome>.sql` | `vw_clientes_ativos.sql` |
| Tabela | `<nome_singular>` | `cliente`, `pedido` |
| Script de dados | `data_<tabela>.sql` | `data_status_pedido.sql` |
| Codigo de release | `issue-<numero>.sql` | `issue-42.sql` |

### Colunas de Auditoria Padrao

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
|-- apex/         Exportacoes de aplicacoes APEX
|-- build/        Scripts de build do release
|-- data/         Scripts de dados re-executaveis (seed, LOVs)
|-- docs/         Documentacao do projeto
|-- lib/          Bibliotecas de terceiros (Logger, OOS Utils)
|-- packages/     Package specs (.pks) e bodies (.pkb)
|-- release/      Scripts de release e codigo especifico
|-- scripts/      Scripts auxiliares e configuracao
|-- synonyms/     Sinonimos do banco
|-- templates/    Templates de codigo
|-- triggers/     Triggers do banco
|-- views/        Views do banco
+-- www/          Assets web (CSS, JS, imagens)
```

---

## Versionamento

Utilize [Versionamento Semantico](https://semver.org/lang/pt-BR/): `major.minor.patch`

| Tipo | Quando usar | Exemplo |
|:--|:--|:--|
| **major** | Alteracoes incompativeis | `1.0.0` -> `2.0.0` |
| **minor** | Novas funcionalidades compativeis | `1.0.0` -> `1.1.0` |
| **patch** | Correcoes de bugs | `1.0.0` -> `1.0.1` |

---

## Commits

### Formato

```
<tipo>: <descricao curta>

<corpo opcional com mais detalhes>
```

### Tipos

| Tipo | Uso |
|:--|:--|
| `feat` | Nova funcionalidade |
| `fix` | Correcao de bug |
| `refactor` | Refatoracao sem mudanca de comportamento |
| `docs` | Alteracao em documentacao |
| `chore` | Tarefas de manutencao |

### Exemplos

```bash
git commit -m "feat: adiciona procedure de calculo de frete no pkg_pedidos"
git commit -m "fix: corrige validacao de CPF no pkg_clientes #42"
git commit -m "docs: atualiza README com exemplos de uso"
```

> Todos os commits devem ser atribuidos a [@maxwbh](https://github.com/maxwbh).

---

## Contato

| | |
|:--|:--|
| **Responsavel** | [@maxwbh](https://github.com/maxwbh) — Maxwell da Silva Oliveira |
| **Empresa** | M&S do Brasil LTDA |
| **Repositorio** | [github.com/maxwbh/template_apex](https://github.com/maxwbh/template_apex) |

---

<sub>Mantido por <a href="https://github.com/maxwbh">@maxwbh</a> — Maxwell da Silva Oliveira — M&S do Brasil LTDA</sub>
