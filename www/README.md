# Desenvolvimento Front-End com APEX Nitro

> Sincronize CSS e JavaScript automaticamente com sua aplicação APEX durante o desenvolvimento.

---

## O que é o APEX Nitro?

[APEX Nitro](https://github.com/OraOpenSource/apex-nitro) é uma ferramenta de build para desenvolvimento front-end Oracle APEX.

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
npm install
```

### 2. Configurar

Edite [`apexnitro.config.json`](../apexnitro.config.json) na raiz do projeto.

### 3. Configurar a aplicação APEX

Crie um **Application Process** em sua aplicação APEX:

```sql
apex_application.g_flow_images := owa_util.get_cgi_env('APEX-Nitro');
```

### 4. Iniciar o desenvolvimento

```bash
npm run nitro:launch
```

### 5. Construir para produção

```bash
npm run nitro:build
```

---

## Referências

- [APEX Nitro — GitHub](https://github.com/OraOpenSource/apex-nitro)
- [Oracle APEX JavaScript API](https://docs.oracle.com/en/database/oracle/apex/24.2/aexjs/)

---

<sub>Mantido por <a href="https://github.com/maxwbh">@maxwbh</a> — Maxwell da Silva Oliveira — M&S do Brasil LTDA</sub>
