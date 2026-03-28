# Dados

Esta pasta é para scripts de dados re-executáveis. Scripts de dados re-executáveis são mais comuns para tabelas de Lista de Valores (LOV) / lookup. Isso permite que desenvolvedores gerenciem facilmente os dados de LOV ao invés de usuários finais. Também evita ter que escrever atualizações manuais cada vez que uma for necessária. É recomendado nomear cada arquivo como `data_nome_tabela.sql`. Ao abrir arquivos no VSCode usando a [Paleta de Comandos](https://code.visualstudio.com/docs/getstarted/tips-and-tricks#_quick-open), você pode encontrar rapidamente scripts `data` usando a funcionalidade de [Abertura Rápida](https://code.visualstudio.com/docs/getstarted/tips-and-tricks#_quick-open). *Nota: outros editores de texto modernos possuem funcionalidade semelhante*

*Nota: Se você tiver atualizações de dados pontuais, elas devem fazer parte de um [release](../release/)*

Templates são fornecidos para scripts de dados: [`template_data_array.sql`](../templates/template_data_array.sql) e [`template_data_json.sql`](../templates/template_data_json.sql). Eles utilizam o conceito de `merge` que associa valores LOV por códigos. Ao associar por códigos ao invés de IDs, remove qualquer diferença em sequências que possam ocorrer entre ambientes.
