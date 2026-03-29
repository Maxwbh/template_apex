create or replace package CHANGEME
  authid definer
as
  /**
   * CHANGEME
   * Descricao do package.
   *
   * @headcom
   *
   * @author @maxwbh
   * @created TODO
   */

  -- Subtipos padrao do package (Guideline G-3110, G-3120)
  -- subtype CHANGEME_code_type is CHANGEME.CHANGEME_code%type;

  -- Constantes publicas (Guideline G-1110: prefixo gc_ para constantes globais)
  -- gc_status_ativo constant varchar2(10) := 'ATIVO';

  -- Excecoes publicas
  -- e_registro_nao_encontrado exception;

  /**
   * Descricao da procedure
   *
   * @param p_param1_todo Descricao do parametro
   */
  procedure p_CHANGEME(
    p_param1_todo in varchar2
  );

  /**
   * Descricao da function
   *
   * @param p_param1_todo Descricao do parametro
   * @return Descricao do retorno
   */
  -- function f_CHANGEME(
  --   p_param1_todo in varchar2
  -- ) return varchar2;

end CHANGEME;
/
