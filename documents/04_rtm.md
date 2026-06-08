# Matriz de Rastreabilidade de Requisitos (RTM) - Northwind Traders

Este documento apresenta a Matriz de Rastreabilidade de Requisitos (RTM) para a plataforma analítica local da Northwind Traders. O objetivo da RTM é garantir que cada Requisito Funcional (RF) e Requisito Não Funcional (RNF) esteja mapeado para um componente correspondente da arquitetura especificada em [documents/03_architecture.md](file:///workspaces/sre-herluvina/documents/03_architecture.md) e possua um Caso de Teste (TC) associado para validação de qualidade.

---

## 1. Matriz de Rastreabilidade (RTM)

A tabela abaixo vincula os requisitos aos componentes RM-ODP e aos casos de teste propostos. Qualquer requisito sem componente ou sem caso de teste associado é classificado com o status **Aberto**.

| Req | Tipo | Origem (Stakeholder / Documento) | Componente (RM-ODP) | Teste/Evidência (TC-NN) | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **RF-01** | Funcional | Engenharia de Dados / [01_functional_requirements.md](file:///workspaces/sre-herluvina/documents/01_functional_requirements.md) | `dbt-duckdb Adapter` / `northwind.duckdb File` | `TC-01` | **Coberto** |
| **RF-02** | Funcional | Analistas de BI, Liderança Executiva / [01_functional_requirements.md](file:///workspaces/sre-herluvina/documents/01_functional_requirements.md) | `dbt CLI Engine` (Marts Layer) | `TC-02` | **Coberto** |
| **RF-03** | Funcional | Engenharia de Dados / [01_functional_requirements.md](file:///workspaces/sre-herluvina/documents/01_functional_requirements.md) | `dbt CLI Engine` (Intermediate Layer) | `TC-03` | **Coberto** |
| **RF-04** | Funcional | Operações e Logística, Analistas de BI / [01_functional_requirements.md](file:///workspaces/sre-herluvina/documents/01_functional_requirements.md) | `dbt CLI Engine` (Intermediate Layer) | `TC-04` | **Coberto** |
| **RF-05** | Funcional | Operações e Logística, Liderança Executiva / [01_functional_requirements.md](file:///workspaces/sre-herluvina/documents/01_functional_requirements.md) | `dbt CLI Engine` / `Streamlit Web UI` | `TC-05` | **Coberto** |
| **RF-06** | Funcional | Operações e Logística, Liderança Executiva / [01_functional_requirements.md](file:///workspaces/sre-herluvina/documents/01_functional_requirements.md) | `dbt CLI Engine` / `Streamlit Web UI` | `TC-06` | **Coberto** |
| **RF-07** | Funcional | Liderança Executiva, Operações e Logística / [01_functional_requirements.md](file:///workspaces/sre-herluvina/documents/01_functional_requirements.md) | `dbt CLI Engine` (Marts Layer) | `TC-07` | **Coberto** |
| **RF-08** | Funcional | Engenharia de Dados, SRE / [01_functional_requirements.md](file:///workspaces/sre-herluvina/documents/01_functional_requirements.md) | `dbt CLI Engine` / `Pipeline Shell Trigger` | `TC-08` | **Coberto** |
| **RF-09** | Funcional | Engenharia de Dados, SRE / [01_functional_requirements.md](file:///workspaces/sre-herluvina/documents/01_functional_requirements.md) | `Pipeline Shell Trigger` | `TC-09` | **Coberto** |
| **RNF-01** | Não Funcional | Engenharia de Dados, SRE / [02_non_functional_requirements.md](file:///workspaces/sre-herluvina/documents/02_non_functional_requirements.md) | `dbt CLI Engine` (`dbt test` constraints) | `TC-10` | **Coberto** |
| **RNF-02** | Não Funcional | Engenharia de Dados, SRE / [02_non_functional_requirements.md](file:///workspaces/sre-herluvina/documents/02_non_functional_requirements.md) | `Pipeline Shell Trigger` (Log comparisons) | `TC-11` | **Coberto** |
| **RNF-03** | Não Funcional | Liderança Executiva, Engenharia / [02_non_functional_requirements.md](file:///workspaces/sre-herluvina/documents/02_non_functional_requirements.md) | `Pipeline Shell Trigger` (Timestamps check) | `TC-12` | **Coberto** |
| **RNF-04** | Não Funcional | Engenharia de Dados / [02_non_functional_requirements.md](file:///workspaces/sre-herluvina/documents/02_non_functional_requirements.md) | `dbt-duckdb Adapter` (Engine logging) | `TC-13` | **Coberto** |
| **RNF-05** | Não Funcional | Analistas de BI / [02_non_functional_requirements.md](file:///workspaces/sre-herluvina/documents/02_non_functional_requirements.md) | `northwind.duckdb File` (Read-only flag) | `TC-14` | **Coberto** |
| **RNF-06** | Não Funcional | Engenharia de Dados / [02_non_functional_requirements.md](file:///workspaces/sre-herluvina/documents/02_non_functional_requirements.md) | `dbt-duckdb Adapter` (Ingest parser) | `TC-15` | **Coberto** |
| **RNF-07** | Não Funcional | Analistas de BI / [02_non_functional_requirements.md](file:///workspaces/sre-herluvina/documents/02_non_functional_requirements.md) | `northwind.duckdb File` (Index/Query optimization) | `TC-16` | **Coberto** |
| **RNF-08** | Não Funcional | Engenharia, SRE / [02_non_functional_requirements.md](file:///workspaces/sre-herluvina/documents/02_non_functional_requirements.md) | `dbt CLI Engine` (Materialization strategies) | `TC-17` | **Coberto** |
| **RNF-09** | Não Funcional | SRE / [02_non_functional_requirements.md](file:///workspaces/sre-herluvina/documents/02_non_functional_requirements.md) | *Nenhum componente nativo* (Ver Seção 3) | `TC-18` | **Aberto** |
| **RNF-10** | Não Funcional | SRE / [02_non_functional_requirements.md](file:///workspaces/sre-herluvina/documents/02_non_functional_requirements.md) | `Docker Compose` / `.gitignore` | `TC-19` | **Coberto** |
| **RNF-11** | Não Funcional | Engenharia de Dados / [02_non_functional_requirements.md](file:///workspaces/sre-herluvina/documents/02_non_functional_requirements.md) | *Nenhum componente nativo* (Ver Seção 3) | `TC-20` | **Aberto** |
| **RNF-12** | Não Funcional | SRE, Engenharia de Dados / [02_non_functional_requirements.md](file:///workspaces/sre-herluvina/documents/02_non_functional_requirements.md) | `Pipeline Shell Trigger` (Alerting routine) | `TC-21` | **Coberto** |
| **RNF-13** | Não Funcional | Engenharia de Dados / [02_non_functional_requirements.md](file:///workspaces/sre-herluvina/documents/02_non_functional_requirements.md) | `dbt CLI Engine` (dbt-expectations) | `TC-22` | **Coberto** |
| **RNF-14** | Não Funcional | SRE, Engenharia de Dados / [02_non_functional_requirements.md](file:///workspaces/sre-herluvina/documents/02_non_functional_requirements.md) | `Docker Compose` (Setup verification) | `TC-23` | **Coberto** |

---

## 2. Detalhamento dos Casos de Teste Propostos (TC-NN)

Esta seção especifica a lógica de teste ou verificação de evidência para cada caso proposto:

*   **TC-01 (RF-01)**: Executar a carga inicial dos dados brutos dos arquivos CSV no DuckDB e verificar se todos os cabeçalhos de colunas foram mapeados com sucesso sem falhas de conversão de esquema.
*   **TC-02 (RF-02)**: Consultar os valores consolidados por categoria na tabela `fct_order_items` e verificar matematicamente contra uma planilha de controle se o lucro líquido calculado bate exatamente com: `receita_bruta - frete_rateado - desconto`.
*   **TC-03 (RF-03)**: Validar se a soma do frete proporcional de todos os itens de um pedido na fato é igual ao frete total do cabeçalho daquele pedido. Testar pedidos com 1 item, múltiplos itens de valores distintos e pedidos de valor bruto zero.
*   **TC-04 (RF-04)**: Inserir pedidos de teste com datas conhecidas e validar se o tempo de envio em dias (`shipped_date - order_date`) e atraso (`shipped_date - required_date`) é calculado corretamente, gerando valores positivos para atrasos e negativos ou nulos para entregas adiantadas.
*   **TC-05 (RF-05)**: Verificar se as agregações geográficas de entrega atrasada agrupadas por cliente e região contam corretamente os atrasos sem duplicar linhas de transações ou rotas.
*   **TC-06 (RF-06)**: Validar se a junção com a dimensão de transportadoras calcula corretamente as médias de prazo e soma de fretes pagos agrupados por fornecedor.
*   **TC-07 (RF-07)**: Verificar se o volume de pedidos processados é corretamente associado ao funcionário responsável por meio da chave estrangeira correspondente.
*   **TC-08 (RF-08)**: Simular a entrada de um registro de pedido inválido (onde `shipped_date < order_date`) e confirmar se o pipeline detecta e marca este registro como inconsistente, gravando o alerta correspondente na tabela de qualidade de dados.
*   **TC-09 (RF-09)**: Comparar o número de linhas físicas do arquivo CSV bruto no repositório de entrada com a contagem total de registros persistidos na camada de staging do DuckDB.
*   **TC-10 (RNF-01)**: Rodar o comando `dbt test` para validar as constraints de integridade referencial (relacionamento entre chaves estrangeiras na fato de detalhes de pedidos e as dimensões correspondentes).
*   **TC-11 (RNF-02)**: Executar teste automatizado comparando as contagens de linhas de origem contra o destino analítico. O teste deve falhar (exibir código de saída 1) se houver qualquer divergência na contagem.
*   **TC-12 (RNF-03)**: Verificar se o tempo total decorrido registrado pelos timestamps de início e fim no log do pipeline é menor ou igual a 45 minutos.
*   **TC-13 (RNF-04)**: Registrar o tempo e a contagem de registros processados na ingestão bruta para verificar se a vazão ultrapassa 5.000 registros por segundo.
*   **TC-14 (RNF-05)**: Executar uma simulação de concorrência onde consultas frequentes de leitura no Streamlit são feitas enquanto um script de carga do dbt grava no banco local. Garantir que as leituras não entrem em timeout.
*   **TC-15 (RNF-06)**: Tentar ingerir um arquivo CSV contendo caracteres acentuados especiais em formato UTF-8 e confirmar se os caracteres são exibidos corretamente no banco sem quebra de codificação.
*   **TC-16 (RNF-07)**: Executar um conjunto de 10 consultas SQL analíticas de agregação complexas no DuckDB e verificar se o tempo médio de resposta no percentil 95 (P95) é menor ou igual a 5 segundos.
*   **TC-17 (RNF-08)**: Rodar o pipeline diário duas vezes consecutivas para o mesmo conjunto de dados brutos e garantir que não haja duplicação de registros na camada final (garantia de idempotência).
*   **TC-18 (RNF-09)**: Verificar a consistência e o Uptime do arquivo local de banco analítico. Como o DuckDB é embutido e não roda como um serviço de banco de dados ativo (daemon), o teste deve monitorar a acessibilidade contínua ao arquivo pela aplicação do Streamlit.
*   **TC-19 (RNF-10)**: Rodar uma ferramenta local de varredura estática de segurança no código-fonte do projeto (como o gitleaks) para garantir que nenhuma chave de API ou credencial secreta local foi gravada.
*   **TC-20 (RNF-11)**: Validar a gravação de logs de auditoria no repositório. Como o DuckDB não possui suporte nativo a triggers de auditoria automáticos de gravação por ser um banco embarcado, este teste deve validar a existência de tabelas ou arquivos de log gerados programaticamente durante a escrita.
*   **TC-21 (RNF-12)**: Simular uma falha de banco de dados (ex: arquivo de banco corrompido) e garantir que o script de trigger do pipeline capture a falha e escreva um alerta estruturado na auditoria do sistema em até 5 minutos.
*   **TC-22 (RNF-13)**: Validar se a suíte de testes de dados do dbt e do dbt-expectations cobre pelo menos 90% das colunas finais das tabelas expostas.
*   **TC-23 (RNF-14)**: Rodar o comando `docker compose up --build` em uma máquina nova/limpa e medir se o tempo total até a inicialização bem-sucedida do Streamlit é menor ou igual a 15 minutos.

---

## 3. Análise de Gaps e Requisitos "Abertos"

Identificamos duas brechas analíticas (gaps) na infraestrutura local projetada na arquitetura que impedem a cobertura completa de dois Requisitos Não Funcionais (RNFs). Estes requisitos estão com status **Aberto**:

### Gap 1: RNF-09 (Disponibilidade e Uptime do Repositório Analítico Local)
*   **Motivo**: O DuckDB é um banco de dados embarcado e sem servidor (serverless/embedded). Ele funciona lendo e gravando direto em um arquivo local (`northwind.duckdb`). Isso significa que não há um "processo/serviço" de banco de dados que fica rodando continuamente em segundo plano para aceitar conexões TCP. O Uptime de 99.0% especificado em RNF-09 não pode ser testado por monitoramento de porta tradicional (ex: ping na porta 5432).
*   **Mitigação Recomendada**: Mudar a abordagem de teste em `TC-18` para verificar a integridade física e disponibilidade do arquivo de banco no volume compartilhado por meio do container de health check do Streamlit.

### Gap 2: RNF-11 (Rastreabilidade de Alterações de Dados - Logs DML)
*   **Motivo**: Como o DuckDB é um motor SQL embarcado em arquivos, ele não possui recursos nativos corporativos de triggers DML (tabelas de histórico de auditoria preenchidas automaticamente por gatilhos do banco ao inserir/deletar/atualizar linhas) e logs nativos avançados como o WAL (Write-Ahead Logging) do PostgreSQL. 
*   **Mitigação Recomendada**: A auditoria das transformações deve ser implementada no nível da aplicação (via logs detalhados do dbt nas tabelas de run do dbt-artifacts ou por meio de tabelas de log preenchidas pelo próprio pipeline no dbt).

---

## 4. Riscos e Ambiguidades de Rastreabilidade

### Riscos (3)
1.  **Falsos Positivos nos Testes de Concorrência (RNF-05)**: O teste `TC-14` pode passar em ambientes de desenvolvimento locais com poucos dados e usuários simulados, mas falhar em produção local se múltiplos analistas de BI tentarem ler o painel do Streamlit enquanto uma carga de dados massiva do dbt está em execução.
2.  **Acúmulo de Débito Técnico nos Gaps de Auditoria**: Ignorar a falta de triggers nativos no DuckDB (RNF-11) e confiar apenas nos logs do dbt pode fazer com que alterações manuais diretas no arquivo `northwind.duckdb` (feitas fora do dbt) ocorram sem qualquer rastro de auditoria.
3.  **Falta de Validação Real de Ingestão no TC-09**: Comparar apenas contagens de linhas de arquivos CSV (RF-09 / RNF-02) não garante que as linhas foram importadas corretamente em suas respectivas colunas (pode ocorrer truncamento silencioso de dados ou carregamento de colunas nulas).

### Ambiguidades (2)
1.  **Origem do Requisito de Produtividade dos Funcionários (RF-07)**: Não há clareza em [01_functional_requirements.md](file:///workspaces/sre-herluvina/documents/01_functional_requirements.md) sobre qual diretoria operacional utilizará a métrica de produtividade ou como o tempo médio de processamento será correlacionado com o volume real de trabalho do funcionário sem violar regras locais de privacidade de dados.
2.  **Métrica de Throughput em Máquinas Virtuais (RNF-04)**: Como a vazão mínima de 5.000 reg/s do teste `TC-13` será executada localmente, o resultado será altamente variável e ambíguo caso o pipeline rode em ambientes virtualizados limitados pelo host local, não refletindo a performance real da stack de software.

---