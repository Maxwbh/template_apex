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

<sub>Mantido por <a href="https://github.com/maxwbh">@maxwbh</a> — Maxwell da Silva Oliveira — M&S do Brasil LTDA</sub>
