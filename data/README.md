# Data

> Scripts re-executáveis para tabelas de lookup, LOVs e dados iniciais (seed).

---

## Início Rápido

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

- Cada arquivo usa `MERGE` para ser **re-executável** com segurança
- A associação é feita por **código** (não por ID), evitando problemas entre ambientes
- Nomenclatura recomendada: `data_<nome_tabela>.sql`

---

<sub>Mantido por <a href="https://github.com/maxwbh">@maxwbh</a> — Maxwell da Silva Oliveira — M&S do Brasil LTDA</sub>
