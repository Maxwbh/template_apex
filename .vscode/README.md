# Tarefas de Build do MS Visual Studio Code

- [Configuração](#configuração)
  - [`tasks.json`](#tasksjson)
- [Tarefas](#tarefas)
  - [Exportação APEX](#exportação-apex)
  - [Compilação de Código](#compilação-de-código)
  - [Gerar Objeto](#gerar-objeto)

O [Microsoft Visual Studio Code (VSC)](https://code.visualstudio.com/) é um editor de código recomendado para a maioria dos trabalhos com PL/SQL. O VSC pode compilar código PL/SQL diretamente (veja [este blog](https://ora-00001.blogspot.ca/2017/03/using-vs-code-for-plsql-development.html) para mais informações). Abrir a pasta deste projeto no VSC lhe dará automaticamente a capacidade de compilar código PL/SQL e fazer backups do APEX.


## Configuração

Na primeira vez que você executar este script, um erro será exibido e o arquivo `scripts/user-config.sh` será criado com alguns valores padrão. Modifique as variáveis conforme necessário. Você também pode precisar modificar o arquivo [`scripts/project-config.sh`](scripts/project-config.sh). Veja a documentação na pasta [`scripts`](scripts) para mais informações.

*Nota: Usuários Windows: Certifique-se de que o WSL ou cmder está configurado para executar bash como terminal no VSC: [instruções](../README.md#configuração-windows)*

### `tasks.json`

Este arquivo define as tarefas do VSCode. Na primeira vez que qualquer script bash for executado neste template (ex: build, compilação, exportação apex, etc.), os nomes das tarefas serão automaticamente atualizados para refletir o nome da pasta raiz do projeto.

Por exemplo, se o projeto estiver armazenado em `~/git/meu-projeto`, **após** a primeira execução do script bash (veja parágrafo anterior), os nomes das tarefas ficarão como: `compilar: meu-projeto` etc.

## Tarefas

As tarefas podem ser executadas com `Ctrl+Shift+B` e selecionando a tarefa desejada.

![Demo de Compilação de Tarefa](img/task-compile.gif)

### Exportação APEX

Se você deseja exportar suas aplicações APEX (definidas em `scripts/project-config.sh`), execute a tarefa `exportar apex: <nome do projeto>`

### Compilação de Código

Para compilar o arquivo que você está editando atualmente, execute a tarefa `compilar: <nome do projeto>`.


### Gerar Objeto

Para criar rapidamente um novo package, view ou arquivo de dados, execute a tarefa `gerar objeto: <nome do projeto>`.

---

> **Mantido por:** [@maxwbh](https://github.com/maxwbh) — Maxwell da Silva Oliveira — M&S do Brasil LTDA
