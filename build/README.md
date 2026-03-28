# Scripts de Build

Esta pasta contém scripts para ajudar a construir um release.

- [Construir um Release](#construir-um-release)

## Construir um Release

Para construir um release, basta executar o comando abaixo. É recomendado que você construa um release cada vez antes de executá-lo.

```bash
# Substitua "versao" pelo seu número de versão
./build.sh versao
```

Este script faz o seguinte:
- Varre as pastas `views` e `packages` e gera `release/all_views.sql` e `release/all_packages.sql`
- Gera um script para mapear algumas variáveis de ambiente do SO para SQL (`release/load_env_vars.sql`)
- Gera os comandos de instalação para todas as aplicações APEX e armazena em `release/all_apex.sql`

---

> **Mantido por:** [@maxwbh](https://github.com/maxwbh) — Maxwell da Silva Oliveira — M&S do Brasil LTDA
