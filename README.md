
# Template de Projeto Inicial para Oracle APEX

[Template para desenvolvimento Oracle PL/SQL e/ou APEX](https://github.com/maxwbh/template_apex) — projetos mantidos por [@maxwbh](https://github.com/maxwbh) (Maxwell da Silva Oliveira — M&S do Brasil LTDA). Este template fornece scripts e processos para acelerar o desenvolvimento e simplificar os processos de release.

É **importante** notar que este é um **template**. Se algo não atender às necessidades do seu projeto ou mudanças adicionais forem necessárias, ajuste conforme necessário. Todas as ferramentas incluídas visam fornecer resultados rapidamente. Se o seu projeto não precisar delas, remova-as.

- [Início](#início)
- [Visão Geral](#visão-geral)
- [Configuração](#configuração)
- [Estrutura de Pastas](#estrutura-de-pastas)
- [Outras Informações](#outras-informações)
  - [Git](#git)
  - [Fluxos de Trabalho Git](#fluxos-de-trabalho-git)
  - [Configuração Windows](#configuração-windows)
    - [Configuração do cmder](#configuração-do-cmder)

## Início

No Github, basta clicar no botão [`Usar este template`](https://github.com/maxwbh/template_apex/generate).

Se estiver usando outra plataforma git, inicie um novo projeto (`git init`) e então [**baixe**](https://github.com/maxwbh/template_apex/archive/main.zip) este projeto (*não clone nem faça fork*) e descompacte no seu novo projeto. Ao copiar, é importante copiar todos os arquivos e pastas ocultos. Exemplo de comando: `cp -r ~/Downloads/template_apex-main/. ~/git/meu-projeto`.


## Visão Geral

Este template contém diversas funcionalidades que podem ajudar no seu projeto.

- [Build](build/): Scripts para gerar o release
- [Pastas](#estrutura-de-pastas): A estrutura de pastas mais comum para projetos é fornecida neste template.
- [Release](release/): Framework para construir e executar releases.
- Integração com [Visual Studio Code](https://code.visualstudio.com/) (VSC): compile ou execute seu código SQL e PL/SQL diretamente do VSC. Mais detalhes na pasta [`.vscode`](.vscode/).

Uma vez [configurado](#configuração), o processo de alto nível para utilizar este template é o seguinte:

- **Desenvolver**
  - Packages vão em [`packages`](packages/), views vão em [`views`](views/), etc
  - Código específico de release / não re-executável vai na pasta [`release/code`](release/code) (veja a pasta [`release`](release) para mais informações sobre como nomear arquivos e listá-los no seu release)
    - Cada release começará exatamente no mesmo ponto: [`release/_release.sql`](release/_release.sql). Se automatizar seus releases, isso fornece um script consistente para executar, reduzindo qualquer intervenção manual.
- **Construir Release**
  - Quando estiver pronto para promover seu código, execute `./build/build.sh <versão>`. Isso fará coisas como exportar sua(s) aplicação(ões) APEX, varrer as pastas views/packages buscando todos os arquivos, etc.
    - Mais informações sobre o processo de build estão disponíveis na pasta [`build`](build/)
- **Executar Release**
  - Existem várias abordagens sobre como realizar um release e marcar (tag) seu código. Você precisa ler as diretrizes de [release](release/) para escolher a abordagem mais adequada para você
- **Limpar Release**
  - Uma vez que um release é concluído, você "limpa" o código específico do release (ou seja, a pasta `release/code` será limpa e resetada). Um script bash [`reset_release`](scripts/#reset_release) é fornecido para isso automaticamente. Exemplos podem ser encontrados na pasta [`release`](release/).

## Configuração

- [`scripts/project-config.sh`](scripts/project-config.sh): Configure as definições do APEX
- [`scripts/user-config.sh`](scripts/user-config.sh): Na primeira vez que qualquer script bash for executado, este arquivo será gerado e precisa ser modificado com as configurações específicas do usuário. Por padrão, este arquivo não será commitado no seu repositório git, pois contém configurações específicas do usuário e senhas de banco de dados
- Remova diretórios que não se aplicam ao seu projeto (ex: data, templates, etc...)


## Estrutura de Pastas

A estrutura de pastas padrão (listada abaixo) fornece um conjunto de pastas comuns que a maioria dos projetos utilizará. Sinta-se à vontade para adicionar novas pastas ao seu projeto quando necessário. Por exemplo, se você tiver scripts ORDS, pode criar uma pasta raiz chamada `ords` para armazená-los.

| Pasta | Descrição |
|:--|--|
| [`.vscode`](.vscode/) | Configurações específicas do [Visual Studio Code](https://code.visualstudio.com/)
| [`apex`](apex/) | Exportações de aplicações
| [`data`](data/) | Scripts de conversão e dados iniciais (seed)
| docs | Documentos do projeto
| lib | Bibliotecas de instalação ([OOS Utils](https://github.com/OraOpenSource/oos-utils), [Logger](https://github.com/OraOpenSource/Logger), etc..)
| [`release`](release/) | Scripts do release atual para alterações e correções. Documentação é fornecida sobre várias formas de realizar releases.
| [`scripts`](scripts/) | Scripts geralmente re-executáveis referenciados por um script de release
| packages | Packages (`.pks` & `.pkb`), (*Se você tiver triggers, procedures ou functions standalone, é recomendado criar uma nova pasta para eles*)
| synonyms | Sinônimos da aplicação
| triggers | Triggers da aplicação
| views | Views da aplicação
| www | Assets do servidor: imagens, CSS e JavaScript



## Outras Informações

### Git

Se você é novo no git, confira estes recursos para aprender mais:

- [Comandos Git Visualizados](https://dev.to/lydiahallie/cs-visualized-useful-git-commands-37p1)

### Fluxos de Trabalho Git

Existem vários conceitos sobre como gerenciar seus projetos Git. Ou seja, o desenvolvimento ativo é feito na branch `master` ou em uma branch `develop`? Cada conceito tem seus prós e contras, e recomendamos que você revise e entenda as diferenças para aplicar o melhor método ao seu projeto. Os fluxos de trabalho mais populares são:

- [`git-flow`](https://www.git-tower.com/learn/git/ebook/en/command-line/advanced-topics/git-flow)
- [GitLab flow](https://docs.gitlab.com/ee/topics/gitlab_flow.html)
  - Este é um superconjunto do `git-flow` e contém funcionalidades específicas do GitLab para ajudar se você estiver usando [GitLab](https://gitlab.com/)
  - O documento fornece uma ótima comparação de todos os diferentes modelos de fluxo de trabalho
- [GitHub Flow](https://guides.github.com/introduction/flow/)
  - *Nota: no documento do GitLab flow há um comentário dizendo que o GitHub flow não é recomendado a menos que você faça deploy em produção frequentemente. Para projetos Oracle, este comentário pode geralmente ser ignorado*

Dada a simplicidade do [GitHub Flow](https://guides.github.com/introduction/flow/), recomendamos este conceito para a maioria dos projetos.


### Configuração Windows

Todos os scripts fornecidos neste template inicial são escritos em bash para ambientes Linux (e macOS). Usuários Windows têm várias opções. Podem instalar o [Windows Subsystem for Linux](https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux) (WSL) para executar Linux no Windows.

Alternativamente, os usuários podem instalar o [cmder](https://cmder.net/), que é um emulador Linux para Windows.

#### Configuração do cmder

Para configurar o cmder, [baixe](https://cmder.net/) a versão mais recente. Descompacte e coloque a pasta `cmder` em `c:\`. *Nota: o cmder pode ser armazenado em qualquer lugar. Para fins destas instruções, assume-se que está em `c:\cmder`*.

Você pode iniciar o cmder a qualquer momento executando `c:\cmder\Cmder.exe` (*Dica: na primeira vez que executar, fixe na barra de tarefas para acesso rápido*)

Para integrar com o VSCode:

- `Arquivo > Preferências > Configurações`
- Pesquise por `terminal integrated shell`
  - Nos resultados, você encontrará um link para `Terminal > Integrated > Automation Shell: Windows` e um link para `Editar em settings.json`. Clique no link de edição e adicione o seguinte ao `settings.json`:

```json
  "terminal.integrated.shell.windows": "C:\\cmder\\vendor\\git-for-windows\\bin\\bash.exe",
  "terminal.integrated.automationShell.linux": ""
```

---

> **Mantido por:** [@maxwbh](https://github.com/maxwbh) — Maxwell da Silva Oliveira — M&S do Brasil LTDA
>
> **Diretrizes:** Consulte os READMEs de cada subpasta para informações detalhadas sobre cada componente. Este template segue as melhores práticas de desenvolvimento Oracle APEX/PL-SQL.
>
> Baseado no [Starter Project Template](https://github.com/insum-labs/starter-project-template) da InSum Labs — Licença CC0 1.0 Universal (Domínio Público).
