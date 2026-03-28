set define off;

PROMPT Dados de CHANGE_ME

declare
  l_json clob;
begin

  -- Carregar dados no objeto JSON
  l_json := q'!
[
  {
    "CHANGE_ME_code": "CHANGEME",
    "CHANGE_ME_name": "CHANGEME",
    "CHANGE_ME_seq": 1
  }
]
!';


  for data in (
    select *
    from json_table(l_json, '$[*]' columns
      CHANGE_ME_code varchar2(4000) path '$.CHANGE_ME_code',
      CHANGE_ME_name varchar2(4000) path '$.CHANGE_ME_name',
      CHANGE_ME_seq number path '$.CHANGE_ME_seq'
    )
  ) loop

    -- Nota: iterando sobre cada entrada para facilitar a depuração caso uma entrada seja inválida
    -- Se performance for um problema, pode mover o select do loop para dentro da instrução merge
    merge into CHANGE_ME dest
      using (
        select
          data.CHANGE_ME_code CHANGE_ME_code
        from dual
      ) src
      on (1=1
        and dest.CHANGE_ME_code = src.CHANGE_ME_code
      )
    when matched then
      update
        set
          -- Não atualizar o valor pois provavelmente é uma chave/valor seguro
          -- Exclusões são tratadas acima
          dest.CHANGE_ME_name = data.CHANGE_ME_name,
          dest.CHANGE_ME_seq = data.CHANGE_ME_seq
    when not matched then
      insert (
        CHANGE_ME_code,
        CHANGE_ME_name,
        CHANGE_ME_seq,
        created_on,
        created_by)
      values(
        data.CHANGE_ME_code,
        data.CHANGE_ME_name,
        data.CHANGE_ME_seq,
        current_timestamp,
        'SYSTEM')
    ;
  end loop;

end;
/
