# 📊 Plataforma Analítica Local - Northwind Traders

Este repositório contém a especificação e a implementação da plataforma analítica local da **Northwind Traders**. A solução foi projetada de forma a operar **100% offline (local-first)**, sem dependência de serviços em nuvem pública, garantindo segurança das credenciais e simplicidade operacional.

O desenvolvimento segue a filosofia **CLI-First** (toda a execução e testes de qualidade são acionáveis via terminal) e a governança do framework **Synkra AIOX**.

---

## 1. Contexto do Negócio e Arquitetura

A Northwind Traders é uma distribuidora de alimentos especializados que necessita consolidar dados brutos de vendas e logística internacional para extrair inteligência de negócios. A arquitetura adota:
*   **Armazenamento de Objetos Local (S3 compatível)**: MinIO local para recebimento de arquivos CSV brutos.
*   **Motor OLAP Embutido**: DuckDB para consultas vetoriais de alto desempenho e materialização física das tabelas analíticas.
*   **Orquestração e Transformação**: dbt (Data Build Tool) estruturando o pipeline em camadas lógicas de modelagem dimensional.
*   **Visualização Interativa**: Dashboard Streamlit para expor KPIs executivos e logísticos.

---

## 2. Estrutura do Projeto

Navegue pela estrutura do repositório para compreender a solução:

```bash
├── app/
│   ├── audit.py             # Script de reconciliação de linhas e gravação de logs DML
│   ├── ingest.py            # Script boto3 de ingestão dos CSVs locais no MinIO
│   └── main.py              # Dashboard interativo do Streamlit
├── bin/
│   └── run-pipeline.sh      # Script orquestrador CLI (Gatilho principal do pipeline)
├── data/
│   ├── northwind_orders.csv # Dados brutos de origem (Pedidos)
│   └── northwind_order_details.csv # Dados brutos de origem (Detalhes)
│   # NOTA: O arquivo northwind.duckdb é gerado nesta pasta durante o pipeline
├── documents/
│   ├── 00_problem.md        # Especificação do problema de negócio e riscos
│   ├── 01_functional_requirements.md # Requisitos funcionais em formato Gherkin
│   ├── 02_non_functional_requirements.md # Requisitos não-funcionais mensuráveis (SLAs)
│   ├── 03_architecture.md   # Arquitetura física/lógica (RM-ODP e ADRs)
│   └── 04_rtm.md            # Matriz de Rastreabilidade e Casos de Teste (TCs)
├── docs/stories/
│   └── story-01-pipeline-analitico-local.md # Story de acompanhamento e progresso
├── transform/               # Projeto dbt
│   ├── dbt_project.yml      # Configurações do projeto dbt
│   ├── profiles.yml         # Perfis de conexão dbt-duckdb (com HTTPFS para MinIO)
│   └── models/              # Camadas staging, intermediate e marts SQL do dbt
├── Dockerfile               # Configuração da imagem do container pipeline/streamlit
└── docker-compose.yml       # Orquestração local dos containers
```

---

## 3. Instruções de Execução (Passo a Passo)

Siga os passos abaixo para construir a infraestrutura e rodar o pipeline analítico localmente no host:

### Pré-requisitos
*   Docker instalado (v24.0.0+)
*   Docker Compose instalado (v2.20.0+)
*   Terminal Bash Linux/macOS

---

### Passo 1: Inicializar os Containers
A partir do diretório raiz do projeto, levante a infraestrutura local em segundo plano:
```bash
docker compose up -d --build
```
*Este comando inicializará o MinIO local (`Healthy` na porta 9000/9001), o container do pipeline aguardando triggers e o Streamlit exposto no host.*

---

### Passo 2: Executar o Pipeline de Dados (CLI-First)
Dispare o orquestrador CLI no host. Ele gerencia todo o ciclo do pipeline:
```bash
./bin/run-pipeline.sh
```

**O que este script executa sob o capô?**
1.  **Ingestão**: Roda `app/ingest.py` dentro do container, transferindo os CSVs da pasta `./data/` para o bucket `northwind-raw` no MinIO.
2.  **Transformação**: Executa as transformações do dbt, lendo do MinIO via protocolo S3 (HTTPFS) e materializando o modelo Star Schema no arquivo `./data/northwind.duckdb`.
3.  **Qualidade**: Dispara o `dbt test` para validar as chaves primárias e relacionamentos de integridade referencial.
4.  **Auditoria**: Roda `app/audit.py` comparando a contagem de registros do CSV com a tabela fato para prevenir perda silenciosa de dados e grava um log de eventos na tabela `audit_log` do DuckDB.

*Os logs completos da execução são salvos localmente na pasta `./logs/pipeline_YYYYMMDD_HHMMSS.log`.*

---

### Passo 3: Acessar a Visualização Analítica
Abra o navegador do host e acesse a interface gráfica interativa do Streamlit:
```
http://localhost:8501
```

O painel está estruturado em quatro abas principais:
1.  **Rentabilidade Financeira**: Lucro líquido real por categoria (RF-02).
2.  **Logística e Entregas**: Tempo médio de entrega (Lead Times), desvios e atrasos por país (RF-04, RF-05).
3.  **Transportadoras e Rotas**: Custo-benefício de frete e prazos médios de rotas por transportadora (RF-06).
4.  **Equipe e Produtividade**: Correlação de volume de ordens processadas e tempo médio por funcionário (RF-07).

---

### Passo 4: Limpar Recursos Locais
Para parar os containers e limpar os volumes locais:
```bash
docker compose down -v
```

---

## 4. Riscos e Ambiguidades de Documentação

### Riscos (3)
1.  **Alterações em Portas do Host**: Se o desenvolvedor já estiver rodando outros serviços nas portas `9000`, `9001` ou `8501`, as instruções falharão na inicialização do docker-compose.
2.  **Uso de Terminal Windows sem WSL**: Comandos de script shell (`chmod +x` e `./bin/run-pipeline.sh`) não funcionarão nativamente em prompt do Windows puro, exigindo WSL2 ou ambiente Unix compatível.
3.  **Versionamento do Banco DuckDB**: O arquivo `.duckdb` é excluído do controle de versão pelo `.gitignore`, mas se o usuário forçar o commit via linha de comando, dados confidenciais gigantes de produção local podem ser expostos.

### Ambiguidades (2)
1.  **Frequência Recomendada do Cron**: O README instrui a execução manual do pipeline, mas não especifica qual a frequência diária ideal (horário) que o cron do sistema operacional host deve adotar para simular a carga.
2.  **Manutenção das Permissões de Usuário**: Não há especificação sobre como manter as permissões corretas de escrita na pasta de logs compartilhada se múltiplos usuários diferentes rodarem o script no mesmo host.
