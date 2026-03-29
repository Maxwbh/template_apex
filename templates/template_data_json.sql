set define off;

-- Guideline G-5070: scripts de dados devem ser re-executaveis (usar MERGE)
-- Oracle 26: suporte aprimorado a json_table

prompt Carregando dados de CHANGE_ME

declare
  -- Guideline G-1130: l_ prefixo para variaveis locais
  l_json clob;
begin

  -- Carregar dados no objeto JSON
  l_json := q'!
[
  {
    "CHANGE_ME_code": "TODO_CODE",
    "CHANGE_ME_name": "TODO Descricao",
    "CHANGE_ME_seq": 1
  }
]
!';

  -- Guideline G-4120: listar colunas explicitamente
  for l_rec in (
    select
      jt.CHANGE_ME_code
     ,jt.CHANGE_ME_name
     ,jt.CHANGE_ME_seq
    from json_table(l_json, '$[*]' columns (
      CHANGE_ME_code varchar2(4000) path '$.CHANGE_ME_code'
     ,CHANGE_ME_name varchar2(4000) path '$.CHANGE_ME_name'
     ,CHANGE_ME_seq  number         path '$.CHANGE_ME_seq'
    )) jt
  ) loop

    -- Guideline G-5070: usar MERGE para idempotencia
    merge into CHANGE_ME dest
    using (
      select l_rec.CHANGE_ME_code as CHANGE_ME_code
      from dual
    ) src
    on (dest.CHANGE_ME_code = src.CHANGE_ME_code)
    when matched then
      update set
        dest.CHANGE_ME_name = l_rec.CHANGE_ME_name
       ,dest.CHANGE_ME_seq  = l_rec.CHANGE_ME_seq
       ,dest.updated_on     = localtimestamp
       ,dest.updated_by     = 'SYSTEM'
    when not matched then
      insert (
        CHANGE_ME_code
       ,CHANGE_ME_name
       ,CHANGE_ME_seq
       ,created_on
       ,created_by)
      values (
        l_rec.CHANGE_ME_code
       ,l_rec.CHANGE_ME_name
       ,l_rec.CHANGE_ME_seq
       ,localtimestamp
       ,'SYSTEM');
  end loop;

  commit;
end;
/
