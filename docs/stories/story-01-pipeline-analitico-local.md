# Story: Implementação da Plataforma Analítica Local - Northwind Traders

**ID**: STORY-01  
**Status**: Done  
**Autor**: Data Engineer  

Esta story gerencia a implementação de ponta a ponta do pipeline de ETL local e do painel analítico da Northwind Traders, rastreando o progresso das tarefas de engenharia de dados.

---

## 1. Critérios de Aceitação

*   **AC-01**: Infraestrutura local operando via containers Docker isolados (MinIO, Python, Streamlit).
*   **AC-02**: Ingestão automática de arquivos CSV locais no bucket `northwind-raw` do MinIO.
*   **AC-03**: Pipeline executado via CLI (`bin/run-pipeline.sh`) rodando dbt + DuckDB com leitura direta do MinIO.
*   **AC-04**: Alocação proporcional de frete e lead times implementados nas tabelas intermediárias do dbt.
*   **AC-05**: Dashboard analítico em Streamlit exibindo lucro real por categoria e métricas de desempenho logístico.
*   **AC-06**: Validação de qualidade de dados passando por testes de integridade referencial, completude e consistência de dados (`dbt test` + logs de auditoria).

---

## 2. Checklist de Progresso

- [x] **Etapa 1: Infraestrutura de Containers**
  - [x] Criar `docker-compose.yml`
  - [x] Criar `Dockerfile` para o pipeline
  - [x] Configurar `.env` a partir do template
- [x] **Etapa 2: Ingestão de Dados no MinIO**
  - [x] Criar script app/ingest.py
  - [x] Testar upload dos arquivos locais para o MinIO
- [x] **Etapa 3: ETL dbt + DuckDB**
  - [x] Configurar dbt profiles e projeto
  - [x] Escrever models de staging (`stg_orders`, `stg_order_details`)
  - [x] Escrever models intermediários (`int_orders_calculated`, `int_order_details_allocated`)
  - [x] Escrever models de marts (`dim_customers`, `dim_products`, `dim_employees`, `dim_shippers`, `fct_order_items`)
  - [x] Criar testes dbt de qualidade de dados
  - [x] Criar script orquestrador CLI `bin/run-pipeline.sh` com reconciliação quantitativa
- [x] **Etapa 4: Visualização Streamlit**
  - [x] Desenvolver `app/main.py`
  - [x] Configurar conexões seguras e somente-leitura com `northwind.duckdb`
- [x] **Etapa 5: Validação Geral e Observabilidade**
  - [x] Executar suíte de testes ponta a ponta (TC-01 a TC-23)
  - [x] Implementar logs de auditoria DML programáticos

---

## 3. Lista de Arquivos (File List)

- [x] [docker-compose.yml](file:///workspaces/sre-herluvina/docker-compose.yml)
- [x] [Dockerfile](file:///workspaces/sre-herluvina/Dockerfile)
- [x] [.env](file:///workspaces/sre-herluvina/.env)
- [x] [app/ingest.py](file:///workspaces/sre-herluvina/app/ingest.py)
- [x] [app/audit.py](file:///workspaces/sre-herluvina/app/audit.py)
- [x] [bin/run-pipeline.sh](file:///workspaces/sre-herluvina/bin/run-pipeline.sh)
- [x] [transform/dbt_project.yml](file:///workspaces/sre-herluvina/transform/dbt_project.yml)
- [x] [transform/profiles.yml](file:///workspaces/sre-herluvina/transform/profiles.yml)
- [x] [transform/models/staging/stg_orders.sql](file:///workspaces/sre-herluvina/transform/models/staging/stg_orders.sql)
- [x] [transform/models/staging/stg_order_details.sql](file:///workspaces/sre-herluvina/transform/models/staging/stg_order_details.sql)
- [x] [transform/models/intermediate/int_orders_calculated.sql](file:///workspaces/sre-herluvina/transform/models/intermediate/int_orders_calculated.sql)
- [x] [transform/models/intermediate/int_order_details_allocated.sql](file:///workspaces/sre-herluvina/transform/models/intermediate/int_order_details_allocated.sql)
- [x] [transform/models/marts/dim_customers.sql](file:///workspaces/sre-herluvina/transform/models/marts/dim_customers.sql)
- [x] [transform/models/marts/dim_products.sql](file:///workspaces/sre-herluvina/transform/models/marts/dim_products.sql)
- [x] [transform/models/marts/dim_employees.sql](file:///workspaces/sre-herluvina/transform/models/marts/dim_employees.sql)
- [x] [transform/models/marts/dim_shippers.sql](file:///workspaces/sre-herluvina/transform/models/marts/dim_shippers.sql)
- [x] [transform/models/marts/fct_order_items.sql](file:///workspaces/sre-herluvina/transform/models/marts/fct_order_items.sql)
- [x] [app/main.py](file:///workspaces/sre-herluvina/app/main.py)

---

## 4. Riscos e Ambiguidades

### Riscos (3)
1.  **Divergência de dependências Python em ambiente Docker**: A imagem Docker pode ter problemas de compilação ou conflito com bibliotecas específicas do `dbt-duckdb` e da biblioteca `httpfs` do DuckDB em arquiteturas locais distintas.
2.  **Bloqueio de arquivo concorrente (DuckDB) no container**: Multi-processamento de testes dbt paralelos ou consultas simultâneas no Streamlit podem travar a base se as flags corretas não forem passadas.
3.  **Vazamento acidental de chaves locais no Git**: Os arquivos `.env` ou docker config podem ser acidentalmente versionados no repositório.

### Ambiguidades (2)
1.  **Extensão física das dimensões secundárias**: Não há arquivos brutos separados para clientes, produtos ou funcionários, gerando ambiguidade sobre como alimentar as tabelas de dimensões recomendadas no RTM.
2.  **Formato de data de entrada**: Os arquivos CSV podem conter strings de data em múltiplos formatos regionais, o que pode causar falhas de parse silenciosas no DuckDB se não especificarmos o formato.

---
*Fim do Documento da Story.*
