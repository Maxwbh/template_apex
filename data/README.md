# Dados

> Scripts re-executaveis para tabelas de lookup, LOVs e dados iniciais (seed).

---

## Inicio Rapido

```bash
source scripts/helper.sh

# Criar script usando template de array
gen_object data_array data_status_pedido
# -> data/data_status_pedido.sql

# Criar script usando template JSON
gen_object data_json data_categorias
# -> data/data_categorias.sql
```

---

## Como funciona

- Cada arquivo usa `MERGE` para ser **re-executavel** com seguranca
- A associacao e feita por **codigo** (nao por ID), evitando problemas entre ambientes
- Nomenclatura recomendada: `data_<nome_tabela>.sql`

---

## Exemplo Pratico

```sql
-- data/data_status_pedido.sql
set define off;

PROMPT Dados de status_pedido

declare
  type rec_data is varray(3) of varchar2(4000);
  type tab_data is table of rec_data index by pls_integer;
  l_data tab_data;
begin
  -- 1: code  2: descricao  3: sequencia
  l_data(l_data.count + 1) := rec_data('PENDENTE',  'Pendente',  1);
  l_data(l_data.count + 1) := rec_data('APROVADO',  'Aprovado',  2);
  l_data(l_data.count + 1) := rec_data('ENVIADO',   'Enviado',   3);
  l_data(l_data.count + 1) := rec_data('ENTREGUE',  'Entregue',  4);
  l_data(l_data.count + 1) := rec_data('CANCELADO', 'Cancelado', 5);

  for i in 1..l_data.count loop
    merge into status_pedido dest
      using (select l_data(i)(1) as code from dual) src
      on (dest.status_code = src.code)
    when matched then
      update set dest.descricao = l_data(i)(2),
                 dest.sequencia = l_data(i)(3)
    when not matched then
      insert (status_code, descricao, sequencia, created_on, created_by)
      values (l_data(i)(1), l_data(i)(2), l_data(i)(3),
              current_timestamp, 'SYSTEM');
  end loop;
end;
/
```

---

## Registrar no release

Adicione seus scripts manualmente em [`release/all_data.sql`](../release/all_data.sql):

```sql
-- release/all_data.sql
@../data/data_status_pedido.sql
@../data/data_categorias.sql
@../data/data_tipos_pagamento.sql
```

> **Ordem importa!** Scripts com dependencias devem vir depois.

---

## Quando usar cada template

| Template | Melhor para | Tamanho |
|:--|:--|:--|
| `data_array` | Poucos registros, dados simples | Pequeno (< 50 linhas) |
| `data_json` | Muitos registros, dados complexos | Grande (> 50 linhas) |

> **Nota:** Atualizacoes pontuais de dados (nao re-executaveis) devem ir em [`release/code/`](../release/code/).

---

<sub>Mantido por <a href="https://github.com/maxwbh">@maxwbh</a> — Maxwell da Silva Oliveira — M&S do Brasil LTDA</sub>
