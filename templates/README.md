# Templates de Código do Projeto

Esta pasta contém templates de código para uso no seu projeto. Alguns templates iniciais são fornecidos e devem ser ajustados para cada projeto.

A maioria dos templates possui a palavra-chave `CHANGEME` que pode ser facilmente substituída pelo nome do objeto que está sendo criado. O [Visual Studio Code](https://code.visualstudio.com/) (VSCode) possui um atalho de seleção [`multi-cursor`](https://code.visualstudio.com/docs/editor/codebasics#_multiple-selections-multicursor) que permite substituição rápida de texto.

Se estiver usando o VSCode, você pode mover estes templates para a pasta [`.vscode`](../.vscode) e configurar [snippets](https://code.visualstudio.com/docs/editor/userdefinedsnippets) baseados em projeto para sua equipe usar. Veja [Escopo de snippet do projeto](https://code.visualstudio.com/docs/editor/userdefinedsnippets) para mais informações.


Arquivo | Descrição
--- | ---
`template_data_array.sql` | Para scripts de dados re-executáveis usando arrays PL/SQL (geralmente para tabelas de lookup).
`template_data_json.sql` | Para scripts de dados re-executáveis usando JSON (ideal para datasets maiores).
`template_pkg.pkb` | Template de package body e procedure/function
`template_pkg.pks` | Package spec
`template_table.sql` | Criação de tabela. *Nota: é esperado que este arquivo seja alterado para cada projeto, pois padrões de nomenclatura diferem*
`template_view.sql` | Criação de view

---

> **Mantido por:** [@maxwbh](https://github.com/maxwbh) — Maxwell da Silva Oliveira — M&S do Brasil LTDA
