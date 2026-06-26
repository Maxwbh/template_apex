set define off;

-- Guideline G-5070: scripts de dados devem ser re-executáveis (usar MERGE)
-- Guideline G-1130: l_ prefixo para variáveis locais

prompt Carregando dados de CHANGE_ME

declare
  -- Guideline G-3110: definir tipos com nomes descritivos
  type t_rec_data is varray(3) of varchar2(4000);
  type t_tab_data is table of t_rec_data index by pls_integer;

  l_data t_tab_data;
  l_row  CHANGE_ME%rowtype;
begin

  -- Ordem das colunas:
  -- 1: CHANGE_ME_code
  -- 2: CHANGE_ME_name
  -- 3: CHANGE_ME_seq

  -- TODO: adicionar dados abaixo
  -- l_data(l_data.count + 1) := t_rec_data('CODIGO', 'Descrição', '1');

  for i in 1..l_data.count loop
    l_row.CHANGE_ME_code := l_data(i)(1);
    l_row.CHANGE_ME_name := l_data(i)(2);
    l_row.CHANGE_ME_seq  := l_data(i)(3);

    -- Guideline G-5070: usar MERGE para idempotência
    merge into CHANGE_ME dest
    using (
      select l_row.CHANGE_ME_code as CHANGE_ME_code
      from dual
    ) src
    on (dest.CHANGE_ME_code = src.CHANGE_ME_code)
    when matched then
      update set
        dest.CHANGE_ME_name = l_row.CHANGE_ME_name
       ,dest.CHANGE_ME_seq  = l_row.CHANGE_ME_seq
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
        l_row.CHANGE_ME_code
       ,l_row.CHANGE_ME_name
       ,l_row.CHANGE_ME_seq
       ,localtimestamp
       ,'SYSTEM');
  end loop;

  commit;
end;
/
