# Requisitos Funcionais - Northwind Traders

Este documento especifica os Requisitos Funcionais (RF) para a plataforma de inteligência analítica local da Northwind Traders, baseando-se no contexto de negócio, fluxos críticos e stakeholders mapeados. Os requisitos estão descritos sob as diretrizes da sintaxe **EARS** (Easy Approach to Requirements Syntax) e acompanhados de critérios de aceitação no formato **Gherkin**.

---

## 1. Tabela Resumo dos Requisitos Funcionais

A priorização dos requisitos foi realizada com base no framework **MoSCoW** (Must, Should, Could, Won't).

| ID | Requisito Funcional (Título) | Atores Principais | Prioridade MoSCoW |
| :--- | :--- | :--- | :--- |
| **RF-01** | Ingestão de Dados Transacionais Locais | Engenharia de Dados | **Must** (Obrigatório) |
| **RF-02** | Cálculo da Rentabilidade Real por Categoria | Analistas de BI e Negócio, Liderança Executiva | **Must** (Obrigatório) |
| **RF-03** | Alocação Proporcional de Custo de Frete | Engenharia de Dados | **Should** (Recomendável) |
| **RF-04** | Identificação de Gargalos Logísticos e Atrasos | Operações e Logística, Analistas de BI | **Must** (Obrigatório) |
| **RF-05** | Agregação Geográfica de Performance de Entrega | Operações e Logística, Liderança Executiva | **Should** (Recomendável) |
| **RF-06** | Análise de Custo-Benefício de Transportadoras | Operações e Logística, Liderança Executiva | **Should** (Recomendável) |
| **RF-07** | Correlação de Produtividade de Funcionários | Liderança Executiva, Operações e Logística | **Could** (Desejável) |
| **RF-08** | Detecção de Inconsistência Temporal de Pedidos | Engenharia de Dados, Time de Infraestrutura / SRE | **Must** (Obrigatório) |
| **RF-09** | Reconciliação Quantitativa de Registros do Pipeline | Engenharia de Dados, Time de Infraestrutura / SRE | **Must** (Obrigatório) |

---

## 2. Anatomia Detalhada dos Requisitos

### RF-01: Ingestão de Dados Transacionais Locais
- **Título:** Ingestão de Dados Transacionais Locais
- **Atores:** Engenharia de Dados
- **Descrição EARS:** 
  - *Sintaxe EARS (Event-driven):* **When** a daily data ingestion job is triggered, the system **shall** load the local transactional raw data of orders and order details into the analytical data repository.
  - *Tradução:* Quando um trabalho diário de ingestão de dados for disparado, o sistema deve carregar os dados transacionais brutos locais de pedidos e detalhes de pedidos para o repositório de dados analítico.
- **Pré-condições:** Os arquivos de dados transacionais estão disponíveis no repositório de arquivos local e estão estruturalmente legíveis.
- **Pós-condições:** Os dados brutos de vendas e logística são carregados com sucesso na área de transição do repositório analítico.
- **Gherkin:**
  ```gherkin
  Funcionalidade: Ingestão de dados de vendas
    Cenário: Ingestão diária realizada com sucesso
      Dado que os arquivos locais de dados transacionais estão presentes no diretório de entrada
      Quando o processo de ingestão diária for disparado pelo orquestrador
      Então o sistema deve carregar todos os registros de cabeçalho e detalhes de pedidos na área de transição
      E o status da carga deve ser registrado como concluído
  ```

### RF-02: Cálculo da Rentabilidade Real por Categoria
- **Título:** Cálculo da Rentabilidade Real por Categoria
- **Atores:** Analistas de BI e Negócio, Liderança Executiva
- **Descrição EARS:**
  - *Sintaxe EARS (Ubiquitous):* The system **shall** calculate the net profitability for each product category by subtracting discounts and allocated freight costs from the gross revenue.
  - *Tradução:* O sistema deve calcular a rentabilidade líquida para cada categoria de produto, subtraindo os descontos e os custos de frete alocados da receita bruta.
- **Pré-condições:** Os dados de pedidos, detalhes de pedidos e produtos estão carregados e associados de forma consistente.
- **Pós-condições:** Os valores consolidados de rentabilidade real por categoria ficam disponíveis para consulta analítica.
- **Gherkin:**
  ```gherkin
  Funcionalidade: Análise financeira de vendas
    Cenário: Consolidação da rentabilidade real por categoria
      Dado que os dados de receitas brutas, descontos e fretes proporcionais já foram calculados
      Quando a agregação por categoria for solicitada
      Então o sistema deve subtrair o frete rateado e o desconto da receita bruta de cada item
      E exibir o lucro líquido totalizado por cada categoria cadastrada
  ```

### RF-03: Alocação Proporcional de Custo de Frete
- **Título:** Alocação Proporcional de Custo de Frete
- **Atores:** Engenharia de Dados
- **Descrição EARS:**
  - *Sintaxe EARS (Optional):* **Where** a shipping cost is registered at the order level, the system **shall** allocate the freight cost proportionally to each item within that order based on the item's gross value.
  - *Tradução:* Onde um custo de envio for registrado no nível do pedido, o sistema deve alocar o custo do frete proporcionalmente a cada item daquele pedido com base no valor bruto do item.
- **Pré-condições:** O pedido possui um valor de frete total cadastrado e possui um ou mais itens com valor de venda bruta maior que zero.
- **Pós-condições:** Cada linha de detalhe do pedido tem seu frete individual proporcional calculado, de modo que a soma destes seja equivalente ao frete total do cabeçalho do pedido.
- **Gherkin:**
  ```gherkin
  Funcionalidade: Rateio de custos logísticos
    Cenário: Ratear frete proporcionalmente entre itens de valores distintos
      Dado que um pedido possui custo de frete total de R$ 100,00
      E contém um item "A" com valor bruto de R$ 300,00
      E um item "B" com valor bruto de R$ 100,00
      Quando o sistema efetuar a alocação de frete do pedido
      Então o item "A" deve receber um valor de frete alocado de R$ 75,00
      E o item "B" deve receber um valor de frete alocado de R$ 25,00
  ```

### RF-04: Identificação de Gargalos Logísticos e Atrasos
- **Título:** Identificação de Gargalos Logísticos e Atrasos
- **Atores:** Operações e Logística, Analistas de BI e Negócio
- **Descrição EARS:**
  - *Sintaxe EARS (Ubiquitous):* The system **shall** compute the lead time and delivery deviation in days for each order using the order, required, and shipping dates.
  - *Tradução:* O sistema deve computar o lead time e o desvio de entrega em dias para cada pedido usando as datas de pedido, requerida e de envio.
- **Pré-condições:** Os pedidos possuem as datas de pedido (`order_date`), requerida (`required_date`) e de envio (`shipped_date`) preenchidas.
- **Pós-condições:** As métricas de lead time e atraso estão gravadas e prontas para agregação.
- **Gherkin:**
  ```gherkin
  Funcionalidade: Controle logístico de datas
    Cenário: Cálculo de atraso de entrega em dias
      Dado um pedido com data requerida (limite) em 10/06/2026
      E que a data de envio efetiva do pedido ocorreu em 13/06/2026
      Quando o sistema processar as datas deste pedido
      Então o desvio de entrega do pedido deve ser registrado como 3 dias de atraso
  ```

### RF-05: Agregação Geográfica de Performance de Entrega
- **Título:** Agregação Geográfica de Performance de Entrega
- **Atores:** Operações e Logística, Liderança Executiva
- **Descrição EARS:**
  - *Sintaxe EARS (Ubiquitous):* The system **shall** aggregate delivery performance indicators, including late delivery rates and incomplete order counts, grouped by client, region, and destination country.
  - *Tradução:* O sistema deve agregar os indicadores de performance de entrega, incluindo taxas de entrega em atraso e contagens de pedidos incompletos, agrupados por cliente, região e país de destino.
- **Pré-condições:** As informações geográficas de destino e de cadastro do cliente estão corretamente preenchidas e associadas aos pedidos.
- **Pós-condições:** As visões analíticas de atrasos e integridade por região estão consolidadas.
- **Gherkin:**
  ```gherkin
  Funcionalidade: Mapeamento de distribuição internacional
    Cenário: Consolidação de taxa de atraso regional
      Dado que o sistema processou 10 pedidos enviados para a região "Sul" no período
      E que 2 desses pedidos foram marcados como atrasados
      Quando a consolidação de performance regional for gerada
      Então a taxa de atraso da região "Sul" deve ser exibida como 20%
  ```

### RF-06: Análise de Custo-Benefício de Transportadoras
- **Título:** Análise de Custo-Benefício de Transportadoras
- **Atores:** Operações e Logística, Liderança Executiva
- **Descrição EARS:**
  - *Sintaxe EARS (Ubiquitous):* The system **shall** aggregate total freight costs and average shipping times grouped by the respective shipping provider and shipping route.
  - *Tradução:* O sistema deve agregar os custos totais de frete e os tempos médios de envio agrupados pela respectiva transportadora e rota de envio.
- **Pré-condições:** Os pedidos contêm a transportadora associada e as localidades de origem e destino identificadas.
- **Pós-condições:** A relação de custos de frete por transportadora e por rota logística fica consolidada.
- **Gherkin:**
  ```gherkin
  Funcionalidade: Avaliação de fornecedores de frete
    Cenário: Consolidação de custos e prazos de transportadoras
      Dado que existem registros de pedidos associados à "Transportadora Rápida"
      Quando o sistema calcular as médias de custo-benefício logístico
      Então deve totalizar o frete pago e calcular o tempo médio entre a data do pedido e do envio para esta transportadora
  ```

### RF-07: Correlação de Produtividade de Funcionários
- **Título:** Correlação de Produtividade de Funcionários
- **Atores:** Liderança Executiva, Operações e Logística
- **Descrição EARS:**
  - *Sintaxe EARS (Ubiquitous):* The system **shall** correlate the total volume of orders processed by each employee with their average processing time from order placement to shipment.
  - *Tradução:* O sistema deve correlacionar o volume total de pedidos processados por cada funcionário com seu tempo médio de processamento, do registro do pedido ao envio.
- **Pré-condições:** Os funcionários estão associados aos cabeçalhos de pedidos e os dados de datas estão íntegros.
- **Pós-condições:** A métrica de correlação de volume de trabalho por lead time de processamento do funcionário está consolidada.
- **Gherkin:**
  ```gherkin
  Funcionalidade: Avaliação de performance de equipe interna
    Cenário: Cálculo de lead time médio por funcionário
      Dado que um funcionário processou 50 pedidos no mês
      Quando o sistema processar a correlação de produtividade
      Então o sistema deve exibir o total de 50 pedidos para este funcionário
      E a média de dias transcorridos entre o registro e envio de seus pedidos
  ```

### RF-08: Detecção de Inconsistência Temporal de Pedidos
- **Título:** Detecção de Inconsistência Temporal de Pedidos
- **Atores:** Engenharia de Dados, Time de Infraestrutura / SRE
- **Descrição EARS:**
  - *Sintaxe EARS (Unwanted Behavior):* **If** an order record has a shipping date earlier than its order date, the system **shall** flag the record as inconsistent and write an entry to the data quality audit logs.
  - *Tradução:* Se um registro de pedido tiver uma data de envio anterior à sua data de pedido, o sistema deve marcar o registro como inconsistente e escrever uma entrada nos logs de auditoria de qualidade de dados.
- **Pré-condições:** O processo de validação de qualidade e integridade do pipeline está em execução ativa.
- **Pós-condições:** O registro que viola a consistência temporal é marcado e os metadados do erro são registrados na auditoria.
- **Gherkin:**
  ```gherkin
  Funcionalidade: Validação de consistência temporal de dados
    Cenário: Identificação de pedido enviado antes de ser efetuado
      Dado que um registro de pedido possui data de pedido "05/06/2026"
      E data de envio "01/06/2026"
      Quando o validador de consistência temporal analisar este registro
      Então o sistema deve marcar o registro de pedido como inconsistente
      E incluir um registro detalhado da falha na auditoria de qualidade
  ```

### RF-09: Reconciliação Quantitativa de Registros do Pipeline
- **Título:** Reconciliação Quantitativa de Registros do Pipeline
- **Atores:** Engenharia de Dados, Time de Infraestrutura / SRE
- **Descrição EARS:**
  - *Sintaxe EARS (Event-driven):* **When** the data transformation process completes, the system **shall** compare the total row count of the source data against the loaded database tables to verify complete loading.
  - *Tradução:* Quando o processo de transformação de dados for concluído, o sistema deve comparar a contagem total de linhas dos dados de origem com as tabelas carregadas no banco de dados para verificar o carregamento completo.
- **Pré-condições:** A etapa de carregamento de dados foi concluída sem interrupções críticas.
- **Pós-condições:** O relatório quantitativo de reconciliação de dados é persistido, validando a integridade numérica da carga.
- **Gherkin:**
  ```gherkin
  Funcionalidade: Auditoria de processamento quantitativo
    Cenário: Validação de conciliação sem perda de dados
      Dado que o arquivo de origem continha exatamente 500 registros de detalhes de pedidos
      Quando o processo de reconciliação for executado
      Então o sistema deve verificar se a tabela analítica correspondente contém exatamente 500 registros
      E gravar a diferença de 0 linhas no log de auditoria
  ```

---

## 3. Riscos e Ambiguidades

### Riscos de Negócio e de Dados
1. **Divergências Matemáticas de Arredondamento no Rateio (RF-03):** O rateio proporcional do custo do frete com base em valores de itens pode gerar divisões inexatas (dízimas). Se não houver uma regra explícita de arredondamento comercial (duas casas decimais) que ajuste a última parcela, a soma dos fretes rateados não baterá com o frete total do pedido, violando auditorias financeiras.
2. **Perda de Rastreabilidade de Histórico de Entidades (SCD Tipo 1):** Caso o cadastro de clientes mude sua região de destino ao longo do tempo (ex: de região "Norte" para "Sul") sem rastreabilidade de histórico (Slowly Changing Dimensions), a agregação geográfica (RF-05) reclassificará retroativamente pedidos passados para a nova região, distorcendo relatórios históricos de SLA.
3. **Ausência de Amostra Estatística para Rotas Novas (RF-06):** Novas transportadoras ou rotas pouco frequentes terão poucos dados para média de dias de envio. A exibição de médias aritméticas simples de lead time nessas condições pode induzir a liderança a tomar decisões logísticas equivocadas com base em outliers não representativos.

### Ambiguidades do Escopo
1. **Falta de Especificação para "Pedidos Incompletos" (RF-05):** O contexto de negócio não define de forma objetiva o que torna um pedido "incompleto" (se é a falta de preenchimento de datas como `shipped_date`, a falta de algum produto do inventário, ou cancelamento parcial). Sem essa definição clara, o sistema corre o risco de reportar métricas imprecisas aos stakeholders.
2. **Definição de Calendário (Dias Corridos vs. Dias Úteis) para Prazos (RF-04):** Ao computar o desvio de prazos e o atraso, não está estabelecido se o sistema deve calcular em dias corridos ou considerar finais de semana e feriados das respectivas filiais e países de destino, afetando diretamente a acurácia do indicador de lead time de despacho.
