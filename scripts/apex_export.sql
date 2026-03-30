
-- Executar no SQLcl (24.x+)
-- Compatível com Oracle APEX 24.2+ / Oracle 19-26
--
-- Parâmetros:
-- 1: ID da Aplicação
-- 2: Opções de exportação (opcional). Ex: "-split", "-skipExportDate"
--
-- Exemplos:
-- @apex_export.sql 100
-- @apex_export.sql 100 -split
-- @apex_export.sql 100 "-split -skipExportDate"
--
set termout off
set verify off


-- Permitir valor opcional para parâmetro 2
-- Ref: https://stackoverflow.com/questions/13474899
column 1 new_value 1
column 2 new_value 2
select '' "1", '' "2"
from dual
where rownum = 0;

define 1
define 2

define APP_ID = "&1"
define EXPORT_OPTIONS = "&2"

set termout on
set serveroutput on
begin
  dbms_output.put_line('ID da App: &APP_ID');
  dbms_output.put_line('Opções de Exportação: &EXPORT_OPTIONS');
  dbms_output.put_line('------------------');
end;
/
set serveroutput off

-- APEX 24.2: apex export suporta -skipExportDate para diffs mais limpos
apex export -applicationid &APP_ID -dir apex &EXPORT_OPTIONS
