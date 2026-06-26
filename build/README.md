# Scripts de Build

> Automatize a preparação do release com um único comando.

---

## Início Rápido

```bash
./build.sh 1.0.0
```

---

## O que o Build faz

```
build.sh <versão>
    |
    |-- 1. Varre pastas views/ e packages/
    |       |-- Gera release/all_views.sql
    |       +-- Gera release/all_packages.sql
    |
    |-- 2. Exporta aplicações APEX (definidas em project-config.sh)
    |       +-- Injeta número da versão no arquivo exportado
    |
    +-- 3. Gera scripts auxiliares de release
            |-- release/load_env_vars.sql   (variáveis de ambiente)
            +-- release/all_apex.sql        (instalação APEX)
```

---

## Exemplo Completo

### Preparar um release versão 2.1.0

```bash
# Navegue até a pasta raiz do projeto
cd ~/git/meu-projeto

# Execute o build
./build/build.sh 2.1.0

# Saída esperada:
# *** Listando todas as views e packages ***
# Listando arquivos em: /home/user/meu-projeto/views extensão: sql
# Listando arquivos em: /home/user/meu-projeto/packages extensão: pks
# Listando arquivos em: /home/user/meu-projeto/packages extensão: pkb
# Exportação APEX: 100
# Exportação APEX: 200
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

> **Próximo passo:** Execute o release seguindo as instruções em [`release/README.md`](../release/README.md)

---

<sub>Mantido por <a href="https://github.com/maxwbh">@maxwbh</a> — Maxwell da Silva Oliveira — M&S do Brasil LTDA</sub>
