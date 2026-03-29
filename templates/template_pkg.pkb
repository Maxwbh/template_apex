create or replace package body CHANGEME
as

  -- Guideline G-1110: gc_ prefixo para constantes globais de package
  gc_scope_prefix constant varchar2(31) := lower($$plsql_unit) || '.';

  -- Guideline G-1120: g_ prefixo para variaveis globais de package
  -- g_example varchar2(100);


  /**
   * Descricao da procedure
   *
   * @example
   *   begin
   *     CHANGEME.p_CHANGEME(p_param1_todo => 'valor');
   *   end;
   *
   * @issue TODO
   *
   * @author @maxwbh
   * @created TODO
   * @param p_param1_todo Descricao do parametro
   */
  procedure p_CHANGEME(
    p_param1_todo in varchar2)
  as
    -- Guideline G-1130: l_ prefixo para variaveis locais
    l_scope  logger_logs.scope%type := gc_scope_prefix || 'p_CHANGEME';
    l_params logger.tab_param;
  begin
    -- Guideline G-5020: Registrar parametros de entrada
    logger.append_param(l_params, 'p_param1_todo', p_param1_todo);
    logger.log('INICIO', l_scope, null, l_params);

    -- TODO: implementar logica aqui
    null;

    logger.log('FIM', l_scope);

  -- Guideline G-5010: Tratar excecoes no nivel mais proximo possivel
  exception
    when others then
      logger.log_error('Excecao nao tratada', l_scope, null, l_params);
      raise;
  end p_CHANGEME;


  /**
   * Exemplo de function seguindo Guidelines
   *
   * @param p_param1_todo Descricao do parametro
   * @return Descricao do retorno
   */
  -- function f_CHANGEME(
  --   p_param1_todo in varchar2)
  --   return varchar2
  -- as
  --   l_scope  logger_logs.scope%type := gc_scope_prefix || 'f_CHANGEME';
  --   l_params logger.tab_param;
  --   l_result varchar2(4000);
  -- begin
  --   logger.append_param(l_params, 'p_param1_todo', p_param1_todo);
  --   logger.log('INICIO', l_scope, null, l_params);
  --
  --   -- TODO: implementar logica aqui
  --   l_result := null;
  --
  --   logger.log('FIM', l_scope);
  --   return l_result;
  -- exception
  --   when others then
  --     logger.log_error('Excecao nao tratada', l_scope, null, l_params);
  --     raise;
  -- end f_CHANGEME;


end CHANGEME;
/
