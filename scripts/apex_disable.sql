-- Desabilita lista separada por vírgula de aplicações APEX
-- Compatível com Oracle APEX 24.2+ / Oracle 19-26
-- Usado principalmente no início de um processo de release APEX
-- Um commit é aplicado ao final. Se não, a app não será desabilitada para usuários
--
-- Parâmetros
-- 1: Lista separada por vírgula de IDs de aplicação. Ex: 100,200
--
prompt Desabilitando Aplicação(ões) APEX
declare
  -- Guideline G-1110: c_ prefixo para constantes locais
  c_app_ids  constant varchar2(500) := '&1.';
  c_username constant varchar2(255) := sys_context('userenv','session_user');

  -- Guideline G-1130: l_ prefixo para variáveis locais
  l_apex_app_ids apex_t_varchar2;
begin
  l_apex_app_ids := apex_string.split(p_str => c_app_ids, p_sep => ',');

  -- Nota: se receber ORA-20987: APEX - Uma chamada de API foi proibida
  -- Altere: Componentes Compartilhados > Atributos de Segurança >
  --         Uso de API em Tempo de Execução > Marque "Modificar Esta Aplicação"

  for i in l_apex_app_ids.first .. l_apex_app_ids.last loop

    -- APEX 5.1+: apex_session.create_session disponível desde APEX 5.1
    apex_session.create_session(
      p_app_id   => l_apex_app_ids(i)
     ,p_page_id  => 1
     ,p_username => c_username
    );

    apex_util.set_application_status(
      p_application_id      => l_apex_app_ids(i)
     ,p_application_status  => 'UNAVAILABLE'
     ,p_unavailable_value   => 'Atualização programada da aplicação.'
    );

    apex_session.detach;

  end loop;

  commit;
end;
/
