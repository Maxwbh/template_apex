-- Desabilita lista separada por vírgula de aplicações APEX
-- Usado principalmente no início de um processo de release APEX
-- Um commit é aplicado ao final deste arquivo. Se não for feito, a aplicação não será desabilitada para os usuários finais
--
-- Parâmetros
-- 1: Lista separada por vírgula de IDs de aplicação. Ex: 100,200
--
--
prompt Desabilitando Aplicação(ões) APEX
declare
  c_app_ids constant varchar2(500) := '&1.';
  c_username constant varchar2(30) := user;

  l_apex_app_ids apex_t_varchar2;
begin
  l_apex_app_ids := apex_string.split(p_str => c_app_ids, p_sep => ',');

  -- Nota: se receber o erro "ORA_20987 para capturar o erro: ORA-20987: APEX - Uma chamada de API foi proibida."
  -- Altere as Configurações de Segurança da Aplicação
  -- Componentes Compartilhados > Atributos de Segurança > Uso de API em Tempo de Execução:
  --  - Marque "Modificar Esta Aplicação"

  for i in l_apex_app_ids.first .. l_apex_app_ids.last loop

    apex_session.create_session (
      p_app_id => l_apex_app_ids(i) ,
      p_page_id => 1,
      p_username => c_username );

    apex_util.set_application_status(
      p_application_id => l_apex_app_ids(i) ,
      p_application_status => 'UNAVAILABLE',
      p_unavailable_value => 'Atualização programada da aplicação.');

    -- Veja https://github.com/insum-labs/starter-project-template/issues/28 para descrição completa
    apex_session.detach;

  end loop;

  commit; -- Commit necessário para garantir que a desabilitação da aplicação seja aplicada
end;
/
