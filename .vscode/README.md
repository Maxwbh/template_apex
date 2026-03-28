# Integracao com Visual Studio Code

> Compile PL/SQL, exporte APEX e gere novos objetos sem sair do editor.

---

## Inicio Rapido

```bash
# 1. Abra o projeto no VSCode
code /caminho/para/template_apex

# 2. Na primeira execucao, sera gerado scripts/user-config.sh
#    Configure com seus dados de conexao

# 3. Use Ctrl+Shift+B para acessar as tarefas
```

> **Windows:** Configure WSL ou cmder como terminal bash no VSCode.
> Veja [instrucoes](../README.md#configuracao-windows).

---

## Tarefas Disponiveis

Acesse com `Ctrl+Shift+B` (Windows/Linux) ou `Cmd+Shift+B` (macOS):

| Tarefa | Comando | O que faz |
|:--|:--|:--|
| **Compilar** | `compilar: <projeto>` | Compila o arquivo PL/SQL aberto no editor |
| **Exportar APEX** | `exportar apex: <projeto>` | Exporta todas as aplicacoes APEX configuradas |
| **Gerar Objeto** | `gerar objeto: <projeto>` | Cria novo package, view ou script de dados |

> Os nomes das tarefas sao atualizados automaticamente com o nome da pasta do projeto na primeira execucao.

---

## Exemplos de Uso

### Compilar um Package

1. Abra o arquivo `packages/pkg_clientes.pkb`
2. Pressione `Ctrl+Shift+B`
3. Selecione `compilar: template_apex`
4. O arquivo sera compilado no banco via SQLcl/SQL*Plus

![Demo de Compilacao](img/task-compile.gif)

### Exportar Aplicacao APEX

1. Pressione `Ctrl+Shift+B`
2. Selecione `exportar apex: template_apex`
3. As aplicacoes definidas em `project-config.sh` serao exportadas para `apex/`

```bash
# Resultado esperado:
apex/f100.sql    # Aplicacao 100 exportada
apex/f200.sql    # Aplicacao 200 exportada
```

### Gerar um Novo Objeto

1. Pressione `Ctrl+Shift+B`
2. Selecione `gerar objeto: template_apex`
3. Escolha o tipo: `package`, `view`, `data_array` ou `data_json`
4. Digite o nome do objeto (ex: `pkg_pedidos`)

```bash
# Resultado para "package" + "pkg_pedidos":
packages/pkg_pedidos.pks    # Spec gerada a partir do template
packages/pkg_pedidos.pkb    # Body gerada a partir do template
# Todas as ocorrencias de CHANGEME foram substituidas por pkg_pedidos
```

---

## Configuracao

### `tasks.json`

Define as tarefas do VSCode. Os rotulos `CHANGEME_TASKLABEL` sao substituidos automaticamente pelo nome da pasta do projeto na primeira execucao de qualquer script bash.

### Arquivos de Script

| Arquivo | Funcao |
|:--|:--|
| `scripts/run_sql.sh` | Compilacao de arquivos SQL/PL-SQL |
| `scripts/apex_export.sh` | Exportacao de aplicacoes APEX |
| `scripts/gen_object.sh` | Geracao de novos objetos |

---

<details>
<summary><strong>Dica: Atalhos para navegar entre editor e terminal</strong></summary>

<br>

Configure em `Preferencias > Atalhos de Teclado`:

| Acao | Atalho sugerido |
|:--|:--|
| Focalizar editor | `Ctrl+1` / `Cmd+1` |
| Focalizar terminal | `Ctrl+2` / `Cmd+2` |

Isso permite alternar rapidamente para copiar SQL do editor e colar no terminal (em uma sessao SQLcl).

</details>

---

<sub>Mantido por <a href="https://github.com/maxwbh">@maxwbh</a> — Maxwell da Silva Oliveira — M&S do Brasil LTDA</sub>
