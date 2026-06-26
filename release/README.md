# Release

> Framework completo para gerenciar releases Oracle APEX/PL-SQL com segurança.

---

## Estrutura do Release

```
release/
|-- _release.sql          # Script principal (ponto de entrada único)
|-- all_views.sql          # [auto] Lista de views
|-- all_packages.sql       # [auto] Lista de packages
|-- all_triggers.sql       # [auto] Lista de triggers
|-- all_apex.sql           # [auto] Instalação APEX
|-- all_data.sql           # [manual] Scripts de dados re-executáveis
|-- load_env_vars.sql      # [auto] Variáveis de ambiente para SQL
+-- code/
    |-- _run_code.sql      # Lista dos scripts do release atual
    |-- backout.sql        # Script de reversão (rollback)
    +-- issue-XXX.sql      # Código específico por ticket
```

> Arquivos marcados com `[auto]` são gerados pelo [`build.sh`](../build/README.md).
> Arquivos marcados com `[manual]` devem ser editados por você.

---

## Início Rápido

```bash
# 1. Desenvolva seu código nas pastas apropriadas
#    packages/, views/, data/, release/code/

# 2. Construa o release
./build/build.sh 1.0.0

# 3. Execute o release
source scripts/helper.sh
cd release
$SQLCL usuario/senha@servidor:1521/xe @_release.sql

# 4. Limpe após o release
source scripts/helper.sh
reset_release template_apex
```

---

## Fluxo do `_release.sql`

O script principal executa na seguinte ordem:

```
_release.sql
|
|-- 1. Carrega variáveis de ambiente (load_env_vars.sql)
|-- 2. Valida usuário do banco (deve ser o schema correto)
|-- 3. Desabilita aplicações APEX (apex_disable.sql)
|-- 4. Executa código do release (code/_run_code.sql)
|      +-- DDL, DML específicos desta versão
|-- 5. Compila views (all_views.sql)
|-- 6. Compila packages (all_packages.sql)
|-- 7. Compila triggers (all_triggers.sql)
|-- 8. Carrega dados (all_data.sql)
|-- 9. Recompila objetos inválidos
|-- 10. Instala aplicações APEX (all_apex.sql)
+-- 11. Grava log e encerra
```

---

## Arquivos de Referência

| Arquivo | Auto | Descrição |
|:--|:--:|:--|
| [`_release.sql`](_release.sql) | - | Script principal. Ponto de entrada único para cada release |
| [`all_apex.sql`](all_apex.sql) | Sim | Instala aplicações APEX conforme `project-config.sh` |
| [`all_data.sql`](all_data.sql) | Não | Scripts de dados re-executáveis. Edite manualmente (ordem importa) |
| [`all_packages.sql`](all_packages.sql) | Sim | Compila `.pks` primeiro, depois `.pkb` |
| [`all_views.sql`](all_views.sql) | Sim | Compila todas as views da pasta `views/` |
| [`all_triggers.sql`](all_triggers.sql) | Sim | Compila todos os triggers |
| [`load_env_vars.sql`](load_env_vars.sql) | Sim | Mapeia variáveis de ambiente para sessão SQL |

---

## A Pasta `code/`

Armazena código **não re-executável** específico de cada release:

```sql
-- code/issue-42.sql
alter table clientes add (telefone varchar2(20));
comment on column clientes.telefone is 'Telefone de contato';

-- code/issue-57.sql
update configuracoes set valor = 'v2' where chave = 'VERSAO_API';
commit;
```

Registre cada arquivo em `code/_run_code.sql`:

```sql
-- code/_run_code.sql
@issue-42.sql
@issue-57.sql
```

> Após cada release, o conteúdo de `code/` é limpo pelo `reset_release`.

---

## Estratégias de Release

> **Importante:** Releases Oracle são "implacáveis" — se um erro ocorrer, pode comprometer todo o restante. Planeje com cuidado.

### Variáveis usadas nos exemplos

```bash
RELEASE_VERSION=1.0.0
GIT_PRE_RELEASE_BRANCH=pre-release-$RELEASE_VERSION
```

> Use [Versionamento Semântico](https://semver.org/lang/pt-BR/): `major.minor.patch`

---

<details>
<summary><strong>Conceito 1: Tag ao ir para Produção</strong></summary>

<br>

O código é marcado (tag) cada vez que **vai para produção**. Patches em teste são aplicados manualmente e o script de release é atualizado.

**Vantagem:** Processo mais simples, um único release para produção.
**Risco:** A ordem dos patches importa. Requer diligência manual.

#### Fluxo

```
master ──> pre-release ──> teste ──> correções ──> tag ──> produção
              |                         |
              +--- patch 1 ────────────+
              +--- patch 2 ────────────+
```

#### Passo a passo

```bash
# Criar branch pre-release
git checkout -b $GIT_PRE_RELEASE_BRANCH master
git push --set-upstream origin $GIT_PRE_RELEASE_BRANCH

# Executar release manualmente em Teste (veja seção abaixo)

# Se precisar corrigir bugs em teste:
git checkout $GIT_PRE_RELEASE_BRANCH
# Edite os arquivos necessários...
# Execute manualmente o DDL/DML corretivo no banco de teste
git add .
git commit -m "fix: corrige campo X na tabela Y"
git push

# Quando 100% certificado, marque o release:
git checkout $GIT_PRE_RELEASE_BRANCH
git tag $RELEASE_VERSION
git push origin --tags

# Mesclar de volta e limpar
git checkout master
git merge $GIT_PRE_RELEASE_BRANCH
git push --delete origin $GIT_PRE_RELEASE_BRANCH
git branch -d $GIT_PRE_RELEASE_BRANCH

# Resetar pasta de release
source scripts/helper.sh
reset_release template_apex
```

</details>

<details>
<summary><strong>Conceito 2: Tag ao sair de Dev</strong></summary>

<br>

O código é marcado (tag) cada vez que **sai de dev**. Cada correção gera uma nova versão.

**Vantagem:** Menor risco em produção — cada release é executado exatamente como foi testado.
**Desvantagem:** Múltiplos releases para aplicar em produção.

#### Fluxo

```
master ──> v1.0.0 ──> teste ──> bug encontrado
                                    |
master ──> v1.0.1 ──> teste ──> bug encontrado
                                    |
master ──> v1.0.2 ──> teste ──> aprovado!

Produção: executar v1.0.0 -> v1.0.1 -> v1.0.2
```

#### Passo a passo

```bash
# Para CADA versão, repita o ciclo:
git checkout -b $GIT_PRE_RELEASE_BRANCH master
git push --set-upstream origin $GIT_PRE_RELEASE_BRANCH

# Executar release em Teste

# Mesclar, marcar e limpar
git checkout master
git pull origin master
git merge $GIT_PRE_RELEASE_BRANCH
git push origin master

git checkout $GIT_PRE_RELEASE_BRANCH
git tag $RELEASE_VERSION
git push origin --tags

git checkout master
git push --delete origin $GIT_PRE_RELEASE_BRANCH
git branch -d $GIT_PRE_RELEASE_BRANCH

source scripts/helper.sh
reset_release template_apex
```

</details>

---

## Executar em Produção

```bash
source scripts/helper.sh
git checkout tags/1.0.0
cd release
$SQLCL usuario_prod/senha@servidor_prod:1521/xe @_release.sql

if [ $? -eq 0 ]; then
  echo "Release bem-sucedido"
else
  echo "ERRO no release"
fi
```

---

## Executar Manualmente (Recomendado para Teste)

Executar passo a passo ajuda a detectar e corrigir erros imediatamente.

### Setup

```bash
cd release
code _release.sql                         # Abrir no VSCode
source ../scripts/helper.sh
$SQLCL usuario/senha@servidor:1521/xe     # Conectar ao banco
```

### Processo

1. Com `_release.sql` aberto no editor e o SQLcl conectado no terminal
2. Copie e cole cada seção do script no terminal
3. Para arquivos em `code/`, abra-os e copie/cole também
4. Use `Ctrl+1` (editor) e `Ctrl+2` (terminal) para navegar rapidamente

![Demo do release manual](../.vscode/img/vsc-manual-release.gif)

---

<sub>Mantido por <a href="https://github.com/maxwbh">@maxwbh</a> — Maxwell da Silva Oliveira — M&S do Brasil LTDA</sub>
