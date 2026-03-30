-- =============================================================================
-- Script de Release — Oracle 19-26 / APEX 24.2
-- Template: github.com/maxwbh/template_apex
-- Guideline: Insum PL/SQL and SQL Coding Guidelines 4.4
-- =============================================================================
-- *** NÃO MODIFIQUE: SEÇÃO DE CABEÇALHO ***
clear screen

whenever sqlerror exit sql.sqlcode

prompt === Carregando variáveis de ambiente ===
@load_env_vars.sql

set verify off
set feedback on
set timing on
set serveroutput on size unlimited
set sqlblanklines off;
set long 50000
set longchunksize 50000

define logname = ''
set termout on
column my_logname new_val logname
select 'release_log_'
  || sys_context('userenv', 'service_name')
  || '_'
  || to_char(sysdate, 'YYYY-MM-DD_HH24-MI-SS')
  || '.log' as my_logname
from dual;
column my_logname clear
set termout on
spool &logname
prompt Arquivo de Log: &logname

prompt === Validando usuário do banco ===
declare
  c_expected_user constant varchar2(128) := upper('&env_schema_name');
begin
  if c_expected_user is null then
    raise_application_error(-20001, 'env_schema_name não está definido');
  elsif upper(user) != c_expected_user then
    raise_application_error(-20001,
      'Deve ser executado como ' || c_expected_user
      || ', mas está conectado como ' || user);
  end if;
end;
/

prompt === Desabilitando aplicações APEX ===
@../scripts/apex_disable.sql &env_apex_app_ids

prompt === Executando código do release ===
@code/_run_code.sql

prompt === Compilando views ===
@all_views.sql

prompt === Compilando packages ===
@all_packages.sql

prompt === Compilando triggers ===
@all_triggers.sql

prompt === Objetos inválidos (pré-recompilação) ===
select object_name, object_type, status
from user_objects
where status != 'VALID'
order by object_type, object_name;

prompt === Carregando dados ===
@all_data.sql

prompt === Recompilando objetos inválidos do schema ===
begin
  dbms_utility.compile_schema(schema => user, compile_all => false);
end;
/

prompt === Objetos inválidos (pós-recompilação) ===
select object_name, object_type, status
from user_objects
where status != 'VALID'
order by object_type, object_name;

prompt === Instalando aplicações APEX ===
@all_apex.sql

prompt === Opções de Build APEX ===

prompt === Release concluído ===
spool off
exit
