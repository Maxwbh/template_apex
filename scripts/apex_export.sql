
-- Executar no SQLcl
--
-- Parâmetros:
-- 1: ID da Aplicação
-- 2: Opções de exportação (opcional). Por exemplo: "-split"
--
-- Exemplos
--
-- Exportar aplicação 100 para f100.sql
-- @apex_export_app 100
--
-- Exportar aplicação 100 como arquivos divididos
-- @apex_export_app 100 -split
--
set termout off
set verify off


-- De: https://stackoverflow.com/questions/13474899/default-value-for-paramteters-not-passed-sqlplus-script
-- e: http://vbegun.blogspot.com/2008/04/on-sqlplus-defines.html
-- Permitir valor opcional para parâmetro 2
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
  dbms_output.put_line ( 'ID da App: &APP_ID' );
  dbms_output.put_line ( 'Opções de Exportação: &EXPORT_OPTIONS' );
  dbms_output.put_line ( '------------------' );
end;
/
set serveroutput off
-- fim

-- spool f&APP_ID..sql
apex export -applicationid &APP_ID -dir apex &EXPORT_OPTIONS
-- spool off
