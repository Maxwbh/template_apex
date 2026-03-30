# Desenvolvimento Front-End com APEX Nitro

> Sincronize CSS e JavaScript automaticamente com sua aplicação APEX durante o desenvolvimento.

<p align="center">
  <a href="https://github.com/OraOpenSource/apex-nitro"><img src="https://img.shields.io/badge/APEX%20Nitro-v5-blue?style=for-the-badge&logo=npm" alt="APEX Nitro v5"></a>
  <a href="https://www.npmjs.com/package/apex-nitro"><img src="https://img.shields.io/badge/npm-apex--nitro-red?style=for-the-badge&logo=npm" alt="npm apex-nitro"></a>
</p>

---

## O que é o APEX Nitro?

[APEX Nitro](https://github.com/OraOpenSource/apex-nitro) é uma ferramenta de build para desenvolvimento front-end Oracle APEX, criada por **Vincent Morneau** ([OraOpenSource](https://github.com/OraOpenSource)).

### Funcionalidades

| Recurso | Descrição |
|:--|:--|
| **Live Reload** | Alterações em CSS/JS são sincronizadas automaticamente no navegador |
| **Browser Sync** | Cliques, scroll e formulários espelhados entre dispositivos |
| **Minificação** | Compila e otimiza arquivos para produção |
| **Concatenação** | Combina múltiplos arquivos CSS/JS em um único arquivo |
| **Source Maps** | Mapeia código compilado de volta ao fonte original |
| **Upload** | Envia arquivos compilados para o APEX via SQLcl |

---

## Início Rápido

### 1. Instalar dependências

```bash
# Na raiz do projeto
npm install
```

> Isso instala o `apex-nitro` como dependência de desenvolvimento (definido no `package.json`).

### 2. Configurar

Edite o arquivo [`apexnitro.config.json`](../apexnitro.config.json) na raiz do projeto:

```json
{
  "mode": "basic",
  "appUrl": "https://SEU_SERVIDOR/ords/f?p=100",
  "srcFolder": "./www/src",
  "distFolder": "./www/dist",
  "libraryName": "meu-projeto"
}
```

| Campo | Descrição | Exemplo |
|:--|:--|:--|
| `mode` | Modo de operação (`basic` ou `pro`) | `"basic"` |
| `appUrl` | URL da sua aplicação APEX | `"https://apex.empresa.com/ords/f?p=100"` |
| `srcFolder` | Pasta com os arquivos fonte | `"./www/src"` |
| `distFolder` | Pasta de saída (build) | `"./www/dist"` |
| `libraryName` | Nome do projeto/biblioteca | `"meu-projeto"` |

### 3. Configurar a aplicação APEX

Crie um **Application Process** em sua aplicação APEX:

1. Acesse **Componentes Compartilhados** > **Processos de Aplicação**
2. Crie um novo processo:
   - **Nome:** `APEX Nitro`
   - **Ponto:** `On Load: Before Header`
   - **Condição:** `Nunca` (apenas ativo durante desenvolvimento)
3. Cole o código PL/SQL:

```sql
-- Application Process: APEX Nitro
-- Sequência: -999 (executar antes de tudo)
-- Ponto: On Load: Before Header
-- Condição: Build Option "DEV_ONLY" (ver abaixo)
apex_application.g_flow_images := owa_util.get_cgi_env('APEX-Nitro');
```

4. Crie uma **Build Option** para controlar o ambiente:
   - Acesse **Componentes Compartilhados** > **Opções de Build**
   - Crie: `DEV_ONLY` (Status: `Include`)
   - Associe o Application Process `APEX Nitro` a esta Build Option
   - Em produção, altere o status para `Exclude`

5. Referencie os arquivos na aplicação:
   - Vá em **Propriedades da Interface do Usuário**
   - CSS: `#APP_IMAGES#app#MIN#.css`
   - JS: `#APP_IMAGES#app#MIN#.js`

> **Importante:** A Build Option garante que o APEX Nitro só redireciona arquivos em desenvolvimento. Em produção, os arquivos são carregados via **Static Application Files** (use `apex-nitro upload`).

### 4. Iniciar o desenvolvimento

```bash
# Iniciar o APEX Nitro (live reload)
npm run nitro:launch

# Ou diretamente:
npx apex-nitro launch
```

Agora, qualquer alteração em `www/src/css/` ou `www/src/js/` será automaticamente sincronizada no navegador.

### 5. Construir para produção

```bash
# Compilar e minificar
npm run nitro:build

# Enviar para o APEX (requer Oracle Instant Client)
npm run nitro:upload
```

---

## Estrutura de Arquivos

```
www/
|-- src/                   # Arquivos fonte (editáveis)
|   |-- css/
|   |   +-- app.css        # Estilos da aplicação
|   |-- js/
|   |   +-- app.js         # JavaScript da aplicação
|   |-- img/               # Imagens do projeto
|   +-- lib/               # Bibliotecas de terceiros (jQuery plugins, etc.)
|
+-- dist/                  # Saída do build (NÃO editar, gerado automaticamente)
    |-- css/
    |   +-- app.min.css
    +-- js/
        +-- app.min.js
```

> **Regra:** Edite apenas os arquivos em `www/src/`. A pasta `www/dist/` é gerada pelo APEX Nitro e está no `.gitignore`.

---

## Comandos Disponíveis

| Comando | npm script | Descrição |
|:--|:--|:--|
| `apex-nitro init` | `npm run nitro:init` | Inicializa/reconfigura o projeto |
| `apex-nitro launch` | `npm run nitro:launch` | Inicia o live reload + browser sync |
| `apex-nitro build` | `npm run nitro:build` | Compila e minifica para produção |
| `apex-nitro upload` | `npm run nitro:upload` | Envia arquivos para o APEX via SQLcl |

---

## Modos de Operação

### Modo Basic

O modo **basic** sincroniza os arquivos diretamente de `src/` para o navegador, sem compilação.

- Ideal para iniciantes
- Sem minificação automática
- Funciona com CSS e JS puro

### Modo Pro

O modo **pro** compila os arquivos de `src/` para `dist/` (ou `build/`), oferecendo:

- Minificação automática de CSS e JS
- Suporte a ES6+ (transpilação via Babel)
- Concatenação de múltiplos arquivos
- Source maps para depuração
- Resolução de módulos (`import`/`export`)

Para mudar para o modo Pro:

```bash
npm run nitro:init
# Selecione "pro" quando perguntado
```

---

## Boas Práticas

### CSS

```css
/* Use prefixo do projeto para evitar conflitos com o tema APEX */
.ta-card-destaque {
  border-left: 4px solid var(--ta-color-primary);
}

/* Use Custom Properties (variáveis CSS) para cores e espaçamento */
:root {
  --ta-color-primary: #1a73e8;
}
```

### JavaScript

```javascript
/* Use namespace para evitar conflitos */
var meuApp = (function () {
  'use strict';

  function init() {
    // Lógica de inicialização
  }

  /* Use as APIs do APEX */
  function salvar() {
    apex.server.process('SALVAR_DADOS', {
      x01: apex.item('P1_NOME').getValue()
    }, {
      success: function (data) {
        apex.message.showPageSuccess('Registro salvo!');
      }
    });
  }

  return { init: init, salvar: salvar };
})();

$(function () { meuApp.init(); });
```

### Integração com APEX

| Método APEX | Uso |
|:--|:--|
| `apex.item('P1_NOME').getValue()` | Obter valor de item |
| `apex.item('P1_NOME').setValue('x')` | Definir valor de item |
| `apex.region('R1').refresh()` | Atualizar região |
| `apex.server.process('PROC', {})` | Chamada AJAX |
| `apex.message.showPageSuccess('OK')` | Mensagem de sucesso |
| `apex.message.showErrors([...])` | Exibir erros |
| `apex.event.trigger('#btn', 'click')` | Disparar evento |

---

## Referências

- [APEX Nitro — GitHub](https://github.com/OraOpenSource/apex-nitro)
- [APEX Nitro — npm](https://www.npmjs.com/package/apex-nitro)
- [APEX Nitro — Documentação](https://github.com/OraOpenSource/apex-nitro/blob/master/docs/init.md)
- [Oracle APEX JavaScript API](https://docs.oracle.com/en/database/oracle/apex/24.2/aexjs/)
- [Vincent Morneau — Criador](https://vmorneau.me/os/)

---

<sub>Mantido por <a href="https://github.com/maxwbh">@maxwbh</a> — Maxwell da Silva Oliveira — M&S do Brasil LTDA</sub>
