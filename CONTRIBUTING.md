# Diretrizes de Contribuição

> **Mantido por:** [@maxwbh](https://github.com/maxwbh) — Maxwell da Silva Oliveira — M&S do Brasil LTDA

## Visão Geral

Este repositório é um template para projetos Oracle APEX/PL-SQL. Abaixo estão as diretrizes para contribuição e uso.

## Padrões de Código

### PL/SQL
- Utilize **Logger** para rastreamento e depuração em packages
- Mantenha o prefixo de scope (`gc_scope_prefix`) em todos os packages
- Documente procedures e functions com os blocos `@author`, `@created`, `@param`, `@return`
- Trate exceções adequadamente com `logger.log_error`
- Use `@author @maxwbh` nos templates de código

### SQL
- Scripts de dados devem ser **re-executáveis** (utilize `MERGE` ao invés de `INSERT`)
- DDL não re-executável vai na pasta `release/code/`
- Nomeie arquivos de código de release por ticket: `issue-XXX.sql`

### Nomenclatura
- Packages: `pkg_<nome>.pks` / `pkg_<nome>.pkb`
- Views: `<nome>_v.sql` ou `<nome>.sql`
- Tabelas: utilize o template em `templates/template_table.sql`
- Colunas de auditoria padrão: `created_on`, `created_by`, `updated_on`, `updated_by`

## Estrutura do Projeto

| Pasta | Conteúdo |
|:--|--|
| `apex/` | Exportações de aplicações APEX |
| `data/` | Scripts de dados re-executáveis (seed, LOVs) |
| `docs/` | Documentação do projeto |
| `lib/` | Bibliotecas de terceiros (Logger, OOS Utils) |
| `packages/` | Package specs (`.pks`) e bodies (`.pkb`) |
| `release/` | Scripts de release e código específico |
| `scripts/` | Scripts auxiliares e configuração |
| `synonyms/` | Sinônimos do banco |
| `templates/` | Templates de código |
| `triggers/` | Triggers do banco |
| `views/` | Views do banco |
| `www/` | Assets web (CSS, JS, imagens) |

## Fluxo de Trabalho

1. **Configuração inicial**: Configure `scripts/project-config.sh` e execute qualquer script para gerar `scripts/user-config.sh`
2. **Desenvolvimento**: Crie código nas pastas apropriadas
3. **Build**: Execute `./build/build.sh <versão>` para preparar o release
4. **Release**: Siga o processo documentado em `release/README.md`
5. **Limpeza**: Execute `reset_release` após cada release

## Versionamento

Utilize [Versionamento Semântico](https://semver.org/lang/pt-BR/): `major.minor.patch`

- **major**: Alterações incompatíveis com versões anteriores
- **minor**: Novas funcionalidades compatíveis
- **patch**: Correções de bugs

## Commits

- Mensagens de commit devem ser claras e descritivas
- Referencie o número do ticket quando aplicável (ex: `fix: corrige cálculo de impostos #123`)
- Todos os commits devem ser atribuídos a [@maxwbh](https://github.com/maxwbh)

## Contato

- **Responsável:** [@maxwbh](https://github.com/maxwbh) — Maxwell da Silva Oliveira
- **Empresa:** M&S do Brasil LTDA
- **Repositório:** [github.com/maxwbh/template_apex](https://github.com/maxwbh/template_apex)
