-- Guideline G-2180: usar identity columns ao invés de sequences + triggers (Oracle 12c+)
-- Guideline G-2340: usar timestamp with local time zone para auditoria (Oracle 9i+)
-- Guideline G-2110: usar varchar2 com semântica char quando possível
-- Compatível com Oracle 19 a 26
-- Nota: Oracle 23c+ suporta "create table if not exists" para DDL idempotente

prompt Criando tabela change_me
create table change_me (
  -- Guideline G-2180: identity column para chave primária
  change_me_id   number         generated always as identity not null
 ,change_me_code varchar2(30)   not null
 ,change_me_name varchar2(255)  not null
 ,change_me_desc varchar2(4000)
 ,change_me_seq  number         not null
 ,is_active      number(1,0)    default 1 not null
  -- Colunas de auditoria padrão (Guideline G-2340)
 ,created_on     timestamp with local time zone default localtimestamp not null
 ,created_by     varchar2(255 byte) default
    coalesce(
      sys_context('APEX$SESSION','app_user')
     ,regexp_substr(sys_context('userenv','client_identifier'),'^[^:]*')
     ,sys_context('userenv','session_user')
    )
    not null
 ,updated_on     timestamp with local time zone
 ,updated_by     varchar2(255 byte)
);

-- Comentários (Guideline G-2150: documentar todos os objetos)
comment on table change_me is 'TODO: descrição da tabela';
comment on column change_me.change_me_id is 'Identificador único (PK identity)';
comment on column change_me.change_me_code is 'Código único de negócio (UK)';
comment on column change_me.change_me_name is 'Nome descritivo';
comment on column change_me.change_me_desc is 'Descrição detalhada';
comment on column change_me.change_me_seq is 'Sequência de ordenação';
comment on column change_me.is_active is 'Flag de ativo: 1=Sim, 0=Não';
comment on column change_me.created_on is 'Data/hora de criação do registro';
comment on column change_me.created_by is 'Usuário que criou o registro';
comment on column change_me.updated_on is 'Data/hora da última atualização';
comment on column change_me.updated_by is 'Usuário da última atualização';

-- Constraints (Guideline G-2110: nomear todas as constraints)
alter table change_me add constraint change_me_pk
  primary key (change_me_id);

alter table change_me add constraint change_me_uk1
  unique (change_me_code);

-- Guideline G-2120: usar check constraints para validação de domínio
alter table change_me add constraint change_me_ck1
  check (change_me_code = trim(upper(change_me_code)));

alter table change_me add constraint change_me_ck2
  check (change_me_seq = trunc(change_me_seq));

alter table change_me add constraint change_me_ck3
  check (is_active in (0, 1));

-- Foreign keys (descomentar e ajustar conforme necessário)
-- alter table change_me add constraint change_me_fk1
--   foreign key (parent_id) references parent_table(parent_id);

-- Índices para foreign keys (Guideline G-2130: indexar colunas de FK)
-- create index change_me_idx1 on change_me(parent_id);
