-- Se quiser adicionar Arte ASCII: https://asciiartgen.now.sh/?style=standard
-- *** NÃO MODIFIQUE: SEÇÃO DE CABEÇALHO ***
clear screen

whenever sqlerror exit sql.sqlcode

prompt carregando variáveis de ambiente
@load_env_vars.sql


-- define - Define o caractere usado como prefixo para variáveis de substituição
-- Nota: se você alterar isso, precisará modificar toda referência a ele neste arquivo e nos arquivos referenciados
-- set define '&'
-- verify off impede a mensagem de substituição old/new
set verify off
-- feedback - Exibe o número de registros retornados por um script ON=1
set feedback on
-- timing - Exibe o tempo que os comandos levam para completar
set timing on
-- exibir mensagens dbms_output
set serveroutput on
-- desabilita linhas em branco no código
set sqlblanklines off;


-- Log da saída do release
define logname = '' -- Nome do arquivo de log

set termout on
column my_logname new_val logname
select 'release_log_'||sys_context( 'userenv', 'service_name' )|| '_' || to_char(sysdate, 'YYYY-MM-DD_HH24-MI-SS')||'.log' my_logname from dual;
-- bom limpar nomes de coluna quando terminar de usá-los
column my_logname clear
set termout on
spool &logname
prompt Arquivo de Log: &logname



prompt verificar se o usuário do BD é o esperado
declare
begin
  if user != '&env_schema_name' or '&env_schema_name' is null then
    raise_application_error(-20001, 'Deve ser executado como &env_schema_name');
  end if;
end;
/

-- Desabilitar aplicações APEX
@../scripts/apex_disable.sql &env_apex_app_ids


-- *** FIM: SEÇÃO DE CABEÇALHO ***


-- *** Tarefas específicas do release ***

@code/_run_code.sql

-- *** NÃO MODIFIQUE ABAIXO ***


-- Views e packages serão automaticamente referenciados nos arquivos abaixo
-- Pode gerar estes arquivos a partir do script de build
-- Procure por "list_all_files"
@all_views.sql
@all_packages.sql
@all_triggers.sql


prompt Objetos inválidos
select object_name, object_type
from user_objects
where status != 'VALID'
order by object_name
;


-- *** DADOS ****


-- Triggers geradas automaticamente
-- Se você tem código para gerar triggers automaticamente, este é um bom lugar para executar.
-- Um exemplo de como ficaria:

-- declare
-- begin
--   pkg_util.gen_triggers()
-- end;
-- /


-- Carregar quaisquer scripts de dados re-executáveis
@all_data.sql


-- Isso precisa estar em posição após a geração de triggers, pois algumas triggers seguem as triggers geradas acima
prompt recompilar objetos inválidos do schema
begin
 dbms_utility.compile_schema(schema => user, compile_all => false);
end;
/

-- *** APEX ***
-- Instalar todas as aplicações apex
@all_apex.sql


-- Controle de Opções de Build (opcional)
-- Em alguns casos, você pode querer habilitar/desabilitar várias opções de build para uma aplicação dependendo do ambiente
-- Um exemplo é fornecido abaixo sobre como habilitar uma opção de build
PROMPT *** Opção de Build APEX ***

-- set serveroutput on size unlimited;
-- declare
--   c_app_id constant apex_applications.application_id%type := ALTERE_ID_DA_APLICACAO;
--   c_username constant varchar2(30) := user;

--   l_build_option_id apex_application_build_options.build_option_id%type;
-- begin
--   if pkg_environment.is_dev() then
--     select build_option_id
--     into l_build_option_id
--     from apex_application_build_options
--     where 1=1
--       and application_id = c_app_id
--       and build_option_name='DEV_ONLY';

--     -- A sessão já está ativa
--     apex_session.create_session (
--       p_app_id => c_app_id,
--       p_page_id => 1,
--       p_username => c_username );

--     apex_util.set_build_option_status(
--       p_application_id => c_app_id,
--       p_id => l_build_option_id,
--       p_build_status=>'INCLUDE');
--   end if;

-- end;
-- /

-- commit;


spool off
exit
