# Scripts de Build

> Automatize a preparacao do release com um unico comando.

---

## Inicio Rapido

```bash
./build.sh 1.0.0
```

---

## O que o Build faz

```
build.sh <versao>
    |
    |-- 1. Varre pastas views/ e packages/
    |       |-- Gera release/all_views.sql
    |       +-- Gera release/all_packages.sql
    |
    |-- 2. Exporta aplicacoes APEX (definidas em project-config.sh)
    |       +-- Injeta numero da versao no arquivo exportado
    |
    +-- 3. Gera scripts auxiliares de release
            |-- release/load_env_vars.sql   (variaveis de ambiente)
            +-- release/all_apex.sql        (instalacao APEX)
```

---

## Exemplo Completo

### Preparar um release versao 2.1.0

```bash
# Navegue ate a pasta raiz do projeto
cd ~/git/meu-projeto

# Execute o build
./build/build.sh 2.1.0

# Saida esperada:
# *** Listando todas as views e packages ***
# Listando arquivos em: /home/user/meu-projeto/views extensao: sql
# Listando arquivos em: /home/user/meu-projeto/packages extensao: pks
# Listando arquivos em: /home/user/meu-projeto/packages extensao: pkb
# Exportacao APEX: 100
# Exportacao APEX: 200
```

### Arquivos gerados

```
release/
|-- all_views.sql        # @../views/vw_clientes_ativos.sql
|                        # @../views/vw_pedidos_pendentes.sql
|
|-- all_packages.sql     # @../packages/pkg_clientes.pks
|                        # @../packages/pkg_pedidos.pks
|                        # @../packages/pkg_clientes.pkb
|                        # @../packages/pkg_pedidos.pkb
|
|-- all_apex.sql         # @../scripts/apex_install.sql SCHEMA WORKSPACE 100
|                        # @../scripts/apex_install.sql SCHEMA WORKSPACE 200
|
+-- load_env_vars.sql    # define env_schema_name=MEU_SCHEMA
                         # define env_apex_app_ids=100,200
```

---

> **Proximo passo:** Execute o release seguindo as instrucoes em [`release/README.md`](../release/README.md)

---

<sub>Mantido por <a href="https://github.com/maxwbh">@maxwbh</a> — Maxwell da Silva Oliveira — M&S do Brasil LTDA</sub>
