create or replace package CHANGEME
  authid definer
as
  /**
   * CHANGEME
   * Descrição do package.
   *
   * @headcom
   *
   * @author @maxwbh
   * @created TODO
   */

  -- Subtipos padrão do package (Guideline G-3110, G-3120)
  -- subtype CHANGEME_code_type is CHANGEME.CHANGEME_code%type;

  -- Constantes públicas (Guideline G-1110: prefixo gc_ para constantes globais)
  -- gc_status_ativo constant varchar2(10) := 'ATIVO';

  -- Exceções públicas
  -- e_registro_nao_encontrado exception;

  /**
   * Descrição da procedure
   *
   * @param p_param1_todo Descrição do parâmetro
   */
  procedure p_CHANGEME(
    p_param1_todo in varchar2
  );

  /**
   * Descrição da function
   *
   * @param p_param1_todo Descrição do parâmetro
   * @return Descrição do retorno
   */
  -- function f_CHANGEME(
  --   p_param1_todo in varchar2
  -- ) return varchar2;

end CHANGEME;
/
