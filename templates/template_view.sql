-- Guideline G-4110: usar create or replace force view
-- Guideline G-4120: listar todas as colunas explicitamente (evitar select *)
-- Guideline G-4130: usar alias de tabela significativos

create or replace force view CHANGEME as
select
  t.column_id
 ,t.column_name
from dual t
where 1 = 1
;

comment on table CHANGEME is 'TODO: descrição da view';
