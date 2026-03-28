-- GERADO pelo build/build.sh NÃO modifique este arquivo diretamente, pois todas as alterações serão sobrescritas no próximo build\n\n
define env_schema_name=
define env_apex_app_ids=
define env_apex_workspace=


prompt Variáveis de ambiente
select
  '&env_schema_name.' env_schema_name,
  '&env_apex_app_ids.' env_apex_app_ids,
  '&env_apex_workspace.' env_apex_workspace
from dual;

