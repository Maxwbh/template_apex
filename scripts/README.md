# Scripts

Os arquivos nesta pasta podem ser usados para múltiplos propósitos, como compilação no VSCode, scripts de build, etc.

- [Arquivos](#arquivos)
- [`apex_disable.sql`](#apex_disablesql)
- [`apex_export_app.sql`](#apex_export_appsql)
- [`helper.sh`](#helpersh)
  - [Variáveis de Ambiente](#variáveis-de-ambiente)
  - [Funções](#funções)
    - [`export_apex_app`](#export_apex_app)
    - [`gen_object`](#gen_object)
    - [`list_all_files`](#list_all_files)
    - [`reset_release`](#reset_release)
    - [`merge_sql_files`](#merge_sql_files)
- [`project-config.sh`](#project-configsh)
- [`user-config.sh`](#user-configsh)

## Arquivos

**Você precisará configurar tanto `project-config.sh` quanto `user-config.sh` no primeiro uso**

Arquivo | Descrição
--- | ---
[`apex_export_app.sql`](#apex_export_appsql) | Exporta uma aplicação APEX
[`helper.sh`](#helpersh) | Funções auxiliares que todos os outros scripts devem chamar. Carrega `config.sh`
`project-config.sh` | Configuração do projeto
[`user-config.sh`](#user-configsh) | Este arquivo será gerado automaticamente quando qualquer script bash for executado pela primeira vez. É auto-documentado.


## `apex_disable.sql`

Este script desabilitará a aplicação (define o status como Indisponível). Seu principal propósito é desabilitar a aplicação no início de um release para que os usuários não a utilizem enquanto o schema está sendo atualizado. Por padrão, é chamado em [`../release/_release.sql`].

**Este script executa um `commit` ao final.**

Parâmetro | Descrição
--- | ---
`1` | Lista de IDs de aplicação separados por vírgula

Exemplo:

```bash
echo exit | sqlcl usuario/senha123@localhost:32118/xe @apex_disable.sql 100,200
```



## `apex_export_app.sql`

Este script requer [SQLcl](https://www.oracle.com/ca-en/database/technologies/appdev/sqlcl.html)

Parâmetro | Descrição
--- | ---
`1` | ID da Aplicação
`2` | *Opcional* Opções de exportação APEX (ex: `-split`)


Exemplos:

```bash
# Exportar para f100.sql
echo exit | sqlcl usuario/senha123@localhost:32118/xe @apex_export_app.sql 100

# Exportar a Aplicação 100 como arquivos divididos
echo exit | sqlcl usuario/senha123@localhost:32118/xe @apex_export_app.sql 100 -split
```


## `helper.sh`

A documentação abaixo referencia `pasta raiz do projeto`. Esta é a pasta base onde o projeto git está localizado no seu computador. Ex: `/Users/maxwell/git/template_apex/`

Para carregar as funções auxiliares execute: `source scripts/helper.sh` (*assumindo que você está na pasta raiz do projeto*). Isso carregará algumas variáveis de ambiente e carregará/verificará as configurações para este release.

### Variáveis de Ambiente

Nome | Descrição
--- | ---
`SCRIPT_DIR` | Diretório onde o arquivo helper está localizado. Usando o exemplo acima, retornará: `/Users/maxwell/git/template_apex/scripts`
`PROJECT_DIR` | Diretório raiz do repositório git associado a este arquivo. Ex: `/Users/maxwell/git/template_apex/`


### Funções

#### `export_apex_app`

Exporta aplicações APEX e também divide o arquivo de exportação. As exportações APEX serão armazenadas na pasta `<raiz_do_projeto>/apex`. A lista de aplicações a exportar é definida na variável `APEX_APP_IDS` em `scripts/project-config.sh`.

**Parâmetros**
Posição | Obrigatório | Descrição
--- | --- | ---
`$1` | Opcional | Versão da aplicação. Se definido, procurará no arquivo exportado da aplicação por `%RELEASE_VERSION%` e substituirá por esta variável. Veja a documentação em [`apex`](../apex/) para mais informações.

**Exemplo**

```bash
# Sem versão da aplicação
export_apex_app

# Com versão da aplicação
export_apex_app 1.2.3
```

#### `gen_object`

Gera um arquivo baseado em um arquivo de template. (veja o exemplo abaixo para mais descrição)

**Parâmetros**
Posição | Obrigatório | Descrição
--- | --- | ---
`$1` | Obrigatório | Tipo de objeto. Por padrão: `package, view, data`
`$2` | Obrigatório | Nome do objeto. Será o nome do novo arquivo e substituirá todas as referências a `CHANGEME` no arquivo

**Exemplo**

Suponha que você queira criar rapidamente um novo package (`pkg_emp`). Por padrão, na pasta [`templates`](../templates) existem dois arquivos [`template_pkg.pks`](../templates/template_pkg.pks) e [`template_pkg.pkb`](../templates/template_pkg.pkb). Antes, você precisaria copiar esses dois arquivos, renomeá-los e modificar os `CHANGEME`s, substituindo pelo nome do seu package. Agora basta:

```bash
source ./scripts/helper.sh
gen_object package pkg_emp
```

Isso criará automaticamente dois novos arquivos `packages/pkg_emp.pks` e `packages/pkg_emp.pkb`. No VSCode também existe uma tarefa para isso, evitando o uso da linha de comando.

**Configuração**

Para modificar os diferentes tipos de templates disponíveis, modifique [`scripts/project-config.sh`](project-config.sh) e procure por `OBJECT_FILE_TEMPLATE_MAP` (é auto-documentado).

#### `list_all_files`

É muito raro que você precise executar esta função sozinha, pois ela é chamada como parte do processo de [`build`](../build). Esta função listará todos os arquivos em uma pasta e gerará os resultados com o prefixo `@../` em um arquivo de saída especificado. Isso é útil para compilar automaticamente todos os packages e views durante o build.

**Parâmetros**
Posição | Obrigatório | Descrição
--- | --- | ---
`$1` | Obrigatório | Pasta da qual listar os arquivos. **Nota:** esta pasta é o nome da pasta **relativa** à pasta raiz do projeto. Ou seja, para `views` você especificaria `views` e **não** `/Users/maxwell/git/template_apex/views`
`$2` | Obrigatório | Arquivo para armazenar os resultados
`$3` | Opcional | Lista de extensões de arquivo separadas por vírgula para buscar. Padrão: `sql`. Note que a ordem da lista importa. Por exemplo, se `pks,pkb`, todos os arquivos `pks` (spec) serão listados primeiro e depois os arquivos `pkb` (body).

**Exemplo**
```bash
# Gerar todas as views
list_all_files views release/all_views.sql sql

# Gerar todos os packages
# Note que pks vem antes de pkb para que os specs sejam listados antes dos body
list_all_files packages release/all_packages.sql pks,pkb
```

#### `reset_release`

Reseta a pasta de release raiz do projeto. Como o reset apagará tudo na pasta `release/code` e resetará `release/code/_run_code.sql`, esta função requer que um parâmetro adicional seja passado para garantir que nada seja excluído por engano.

**Parâmetros**
Posição | Obrigatório | Descrição
--- | --- | ---
`$1` | Obrigatório | Nome do diretório raiz do projeto. Se a pasta raiz é `/Users/maxwell/git/template_apex/`, então este parâmetro será `template_apex`

**Exemplo**

```bash
# Mostra o que acontece quando nenhum parâmetro é passado
# Note que a mensagem de erro mostrará a chamada correta
reset_release

Erro: diretório de confirmação ausente ou não correspondente. Execute: reset_release template_apex

# Execução correta

reset_release template_apex
```


#### `merge_sql_files`

Mescla múltiplos arquivos em um único arquivo. Isso é útil quando não é possível referenciar múltiplos arquivos facilmente em um release (ex: deploy no apex.oracle.com).
Isso manterá quaisquer comandos existentes (ex: `alter table, update, etc.`) mas expandirá qualquer linha que comece com `@`.

**Parâmetros**
Posição | Obrigatório | Descrição
--- | --- | ---
`$1` | Obrigatório | Arquivo de entrada "raiz"
`$2` | Obrigatório | Arquivo de saída (mesclado)

**Exemplo**

Suponha que sua estrutura de arquivos seja a seguinte:

```
/release
  _release.sql
    update config set release_date = sysdate;
    @all_packages.sql
  @all_packages.sql
    @..packages/pkg_emp.pks
    @..packages.pkg_emp.pkb
```

Se você então executar:

```bash
cd /release
merge_sql_files _release.sql merged_release.sql
```

Isso criará `merged_release.sql` com o seguinte:
```sql
-- _release.sql
update config set release_date = sysdate;
--
-- referenciando @all_packages.sql
--
-- referenciando @..packages/pkg_emp.pks
--
create or replace package pkg_emp
...
--
-- referenciando @..packages/pkg_emp.pkb
create or replace package body pkg_emp
...
```

## `project-config.sh`
Este arquivo contém informações sobre o seu projeto (como nome do schema, aplicações APEX, etc.). É comum para todos os desenvolvedores e as alterações são salvas no git. **Não** coloque informações sensíveis neste arquivo (`user-config.sh` é para informações sensíveis).

## `user-config.sh`
Na primeira vez que qualquer script bash for executado, um erro será exibido e um novo arquivo (`scripts/user-config.sh`) será criado. `user-config.sh` é auto-documentado e requer alguma configuração antes que o build funcione.

`user-config.sh` está no arquivo `.gitignore` para que você possa armazenar informações mais sensíveis sem que sejam commitadas.

---

> **Mantido por:** [@maxwbh](https://github.com/maxwbh) — Maxwell da Silva Oliveira — M&S do Brasil LTDA
