create or replace package body CHANGEME as

  gc_scope_prefix constant varchar2(31) := lower($$plsql_unit) || '.';


  /**
   * Descrição
   *
   *
   * @example
   *
   * @issue TODO
   *
   * @author @maxwbh
   * @created TODO
   * @param TODO
   * @return
   */
  procedure P_CHANGEME(
    p_param1_todo in varchar2)
  as
    l_scope logger_logs.scope%type := gc_scope_prefix || 'P_CHANGEME';
    l_params logger.tab_param;

  begin
    logger.append_param(l_params, 'p_param1_todo', p_param1_todo);
    logger.log('INICIO', l_scope, null, l_params);

    ...
    -- Todas as chamadas ao logger devem passar o scope
    ...

    logger.log('FIM', l_scope);
  exception
    when others then
      logger.log_error('Exceção não tratada', l_scope, null, l_params);
      raise;
  end P_CHANGEME;


end CHANGEME;
/
