-- =============================================================================
-- Release Script — Oracle 19-26 / APEX 24.2
-- Template: github.com/maxwbh/template_apex
-- Guideline: Insum PL/SQL and SQL Coding Guidelines 4.4
-- =============================================================================
-- *** NAO MODIFIQUE: SECAO DE CABECALHO ***
clear screen

whenever sqlerror exit sql.sqlcode

prompt === Carregando variaveis de ambiente ===
@load_env_vars.sql


-- verify off impede a mensagem de substituicao old/new
set verify off
-- feedback - Exibe o numero de registros retornados por um script
set feedback on
-- timing - Exibe o tempo que os comandos levam para completar
set timing on
-- exibir mensagens dbms_output
set serveroutput on size unlimited
-- desabilita linhas em branco no codigo
set sqlblanklines off;
-- saida longa para grandes scripts
set long 50000
set longchunksize 50000


-- Log da saida do release
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


-- Validar usuario de conexao (Guideline G-1110: c_ para constantes)
prompt === Validando usuario do banco ===
declare
  c_expected_user constant varchar2(128) := upper('&env_schema_name');
begin
  if c_expected_user is null then
    raise_application_error(-20001, 'env_schema_name nao esta definido');
  elsif upper(user) != c_expected_user then
    raise_application_error(-20001,
      'Deve ser executado como ' || c_expected_user
      || ', mas esta conectado como ' || user);
  end if;
end;
/


-- Desabilitar aplicacoes APEX durante o release
prompt === Desabilitando aplicacoes APEX ===
@../scripts/apex_disable.sql &env_apex_app_ids


-- *** FIM: SECAO DE CABECALHO ***


-- =============================================================================
-- Tarefas especificas do release (DDL/DML nao re-executavel)
-- =============================================================================
prompt === Executando codigo do release ===
@code/_run_code.sql


-- *** NAO MODIFIQUE ABAIXO ***


-- =============================================================================
-- Objetos re-executaveis (gerados automaticamente pelo build)
-- =============================================================================
prompt === Compilando views ===
@all_views.sql

prompt === Compilando packages ===
@all_packages.sql

prompt === Compilando triggers ===
@all_triggers.sql


-- Verificar objetos invalidos apos compilacao
prompt === Objetos invalidos (pre-recompilacao) ===
select object_name
      ,object_type
      ,status
from user_objects
where status != 'VALID'
order by object_type
        ,object_name
;


-- =============================================================================
-- Dados re-executaveis
-- =============================================================================
prompt === Carregando dados ===
@all_data.sql


-- Recompilar objetos invalidos do schema
-- Oracle 19+: dbms_utility.compile_schema continua sendo a abordagem padrao
prompt === Recompilando objetos invalidos do schema ===
begin
  dbms_utility.compile_schema(schema => user, compile_all => false);
end;
/

-- Verificacao final de objetos invalidos
prompt === Objetos invalidos (pos-recompilacao) ===
select object_name
      ,object_type
      ,status
from user_objects
where status != 'VALID'
order by object_type
        ,object_name
;


-- =============================================================================
-- Instalar aplicacoes APEX
-- =============================================================================
prompt === Instalando aplicacoes APEX ===
@all_apex.sql


-- Controle de Opcoes de Build (opcional)
-- APEX 24.2: build options para controlar features por ambiente
prompt === Opcoes de Build APEX ===

-- Exemplo: habilitar build option em ambiente de desenvolvimento
-- declare
--   c_app_id constant apex_applications.application_id%type := 100;
--   l_build_option_id apex_application_build_options.build_option_id%type;
-- begin
--   select build_option_id
--   into l_build_option_id
--   from apex_application_build_options
--   where application_id = c_app_id
--     and build_option_name = 'DEV_ONLY';
--
--   apex_session.create_session(
--     p_app_id   => c_app_id
--    ,p_page_id  => 1
--    ,p_username => user
--   );
--
--   apex_util.set_build_option_status(
--     p_application_id => c_app_id
--    ,p_id             => l_build_option_id
--    ,p_build_status   => 'INCLUDE'
--   );
--
--   apex_session.detach;
--   commit;
-- end;
-- /


prompt === Release concluido ===
spool off
exit
