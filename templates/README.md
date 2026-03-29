# Templates de Código

> Modelos prontos para criar packages, views, tabelas e scripts de dados rapidamente.

---

## Início Rápido

```bash
source scripts/helper.sh

# Criar package
gen_object package pkg_clientes

# Criar view
gen_object view vw_clientes_ativos

# Criar script de dados (array)
gen_object data_array data_status

# Criar script de dados (JSON)
gen_object data_json data_categorias
```

> Todos os templates substituem `CHANGEME` pelo nome do objeto automaticamente.

---

## Templates Disponíveis

| Arquivo | Tipo | Gera em | Descrição |
|:--|:--|:--|:--|
| `template_pkg.pks` | Package Spec | `packages/` | Especificação do package |
| `template_pkg.pkb` | Package Body | `packages/` | Body com Logger, tratamento de erros e documentação |
| `template_view.sql` | View | `views/` | View básica com `create or replace force` |
| `template_table.sql` | Tabela | - | DDL completo com auditoria, constraints e índices |
| `template_data_array.sql` | Dados (Array) | `data/` | Carga via PL/SQL `varray` + `merge` |
| `template_data_json.sql` | Dados (JSON) | `data/` | Carga via `json_table` + `merge` |

---

## Exemplos de Uso

### Package — `pkg_clientes`

```bash
gen_object package pkg_clientes
```

**Spec gerada** (`packages/pkg_clientes.pks`):
```sql
create or replace package pkg_clientes as

end pkg_clientes;
/
```

**Body gerada** (`packages/pkg_clientes.pkb`):
```sql
create or replace package body pkg_clientes as

  gc_scope_prefix constant varchar2(31) := lower($$plsql_unit) || '.';

  procedure p_inserir(
    p_nome in varchar2)
  as
    l_scope logger_logs.scope%type := gc_scope_prefix || 'p_inserir';
    l_params logger.tab_param;
  begin
    logger.append_param(l_params, 'p_nome', p_nome);
    logger.log('INICIO', l_scope, null, l_params);

    -- Sua lógica aqui

    logger.log('FIM', l_scope);
  exception
    when others then
      logger.log_error('Exceção não tratada', l_scope, null, l_params);
      raise;
  end p_inserir;

end pkg_clientes;
/
```

---

### View — `vw_pedidos_pendentes`

```bash
gen_object view vw_pedidos_pendentes
```

**Arquivo gerado** (`views/vw_pedidos_pendentes.sql`):
```sql
create or replace force view vw_pedidos_pendentes as
  select
    p.pedido_id,
    p.cliente_id,
    p.valor_total,
    p.created_on as data_pedido
  from pedidos p
  where p.status_code = 'PENDENTE'
;
```

---

### Tabela — usando o template manualmente

O template de tabela não é gerado automaticamente. Copie e adapte:

```sql
-- Exemplo baseado em template_table.sql
create table clientes (
  cliente_id    number generated always as identity not null,
  cliente_code  varchar2(30) not null,
  nome          varchar2(100) not null,
  email         varchar2(255),
  created_on    date default sysdate not null,
  created_by    varchar2(255) default
    coalesce(
      sys_context('APEX$SESSION','app_user'),
      sys_context('userenv','session_user')
    ) not null,
  updated_on    date,
  updated_by    varchar2(255)
);

-- Constraints
alter table clientes add constraint clientes_pk primary key (cliente_id);
alter table clientes add constraint clientes_uk1 unique (cliente_code);
alter table clientes add constraint clientes_ck1
  check (cliente_code = trim(upper(cliente_code)));

-- Comentários
comment on table clientes is 'Cadastro de clientes';
comment on column clientes.cliente_code is 'Código único do cliente';
comment on column clientes.nome is 'Nome completo';
```

---

### Dados (Array) — `data_status_pedido`

```bash
gen_object data_array data_status_pedido
```

**Arquivo gerado** (`data/data_status_pedido.sql`):
```sql
set define off;

PROMPT data_status_pedido data

declare
  type rec_data is varray(3) of varchar2(4000);
  type tab_data is table of rec_data index by pls_integer;
  l_data tab_data;
  l_row data_status_pedido%rowtype;
begin
  -- 1: code, 2: name, 3: seq
  l_data(l_data.count + 1) := rec_data('PENDENTE', 'Pendente', 1);
  l_data(l_data.count + 1) := rec_data('APROVADO', 'Aprovado', 2);
  l_data(l_data.count + 1) := rec_data('CANCELADO', 'Cancelado', 3);

  for i in 1..l_data.count loop
    l_row.data_status_pedido_code := l_data(i)(1);
    l_row.data_status_pedido_name := l_data(i)(2);
    l_row.data_status_pedido_seq  := l_data(i)(3);

    merge into data_status_pedido dest
      using (
        select l_row.data_status_pedido_code data_status_pedido_code
        from dual
      ) src
      on (dest.data_status_pedido_code = src.data_status_pedido_code)
    when matched then
      update set
        dest.data_status_pedido_name = l_row.data_status_pedido_name,
        dest.data_status_pedido_seq  = l_row.data_status_pedido_seq
    when not matched then
      insert (data_status_pedido_code, data_status_pedido_name,
              data_status_pedido_seq, created_on, created_by)
      values (l_row.data_status_pedido_code, l_row.data_status_pedido_name,
              l_row.data_status_pedido_seq, current_timestamp, 'SYSTEM');
  end loop;
end;
/
```

---

### Dados (JSON) — `data_categorias`

```bash
gen_object data_json data_categorias
```

```sql
-- Trecho do arquivo gerado (data/data_categorias.sql)
l_json := q'!
[
  {"data_categorias_code": "ELETRO", "data_categorias_name": "Eletrônicos", "data_categorias_seq": 1},
  {"data_categorias_code": "MOVEIS", "data_categorias_name": "Móveis", "data_categorias_seq": 2},
  {"data_categorias_code": "ROUPAS", "data_categorias_name": "Roupas", "data_categorias_seq": 3}
]
!';
```

---

## Personalização

### Adicionar novos tipos de template

Edite [`scripts/project-config.sh`](../scripts/project-config.sh):

```bash
# Formato: nome:prefixo_template:extensões:pasta_destino
OBJECT_FILE_TEMPLATE_MAP="$OBJECT_FILE_TEMPLATE_MAP,trigger:templates/template_trigger:sql:triggers"
```

### Usar como snippets no VSCode

Mova os templates para `.vscode/` e configure [snippets de projeto](https://code.visualstudio.com/docs/editor/userdefinedsnippets):

```
.vscode/
+-- .code-snippets    # Defina snippets baseados nos templates
```

---

<sub>Mantido por <a href="https://github.com/maxwbh">@maxwbh</a> — Maxwell da Silva Oliveira — M&S do Brasil LTDA</sub>
