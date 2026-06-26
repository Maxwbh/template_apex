-- Instala uma aplicação APEX
-- Compatível com Oracle APEX 24.2+ / Oracle 19-26
--
-- Parâmetros:
-- 1: Schema para instalar
-- 2: Workspace para instalar
-- 3: ID da Aplicação

set serveroutput on size unlimited;
set timing off;
set define on

declare
begin
  apex_application_install.set_application_id(&3.);
  apex_application_install.set_schema(upper('&1.'));
  apex_application_install.set_workspace(upper('&2.'));
  -- APEX 24.2: generate_offset disponível para evitar conflitos de ID
  -- apex_application_install.generate_offset;
end;
/

@../apex/f&3..sql
