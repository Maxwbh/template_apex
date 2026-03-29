-- Desabilita lista separada por virgula de aplicacoes APEX
-- Compativel com Oracle APEX 24.2+ / Oracle 19-26
-- Usado principalmente no inicio de um processo de release APEX
-- Um commit e aplicado ao final. Se nao, a app nao sera desabilitada para usuarios
--
-- Parametros
-- 1: Lista separada por virgula de IDs de aplicacao. Ex: 100,200
--
prompt Desabilitando Aplicacao(oes) APEX
declare
  -- Guideline G-1110: c_ prefixo para constantes locais
  c_app_ids  constant varchar2(500) := '&1.';
  c_username constant varchar2(255) := sys_context('userenv','session_user');

  -- Guideline G-1130: l_ prefixo para variaveis locais
  l_apex_app_ids apex_t_varchar2;
begin
  l_apex_app_ids := apex_string.split(p_str => c_app_ids, p_sep => ',');

  -- Nota: se receber ORA-20987: APEX - Uma chamada de API foi proibida
  -- Altere: Componentes Compartilhados > Atributos de Seguranca >
  --         Uso de API em Tempo de Execucao > Marque "Modificar Esta Aplicacao"

  for i in l_apex_app_ids.first .. l_apex_app_ids.last loop

    -- APEX 5.1+: apex_session.create_session disponivel desde APEX 5.1
    apex_session.create_session(
      p_app_id   => l_apex_app_ids(i)
     ,p_page_id  => 1
     ,p_username => c_username
    );

    apex_util.set_application_status(
      p_application_id      => l_apex_app_ids(i)
     ,p_application_status  => 'UNAVAILABLE'
     ,p_unavailable_value   => 'Atualizacao programada da aplicacao.'
    );

    apex_session.detach;

  end loop;

  commit;
end;
/
