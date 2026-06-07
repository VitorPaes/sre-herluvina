# Problema de Negócio: Modernização Analítica da Northwind Traders

## 1. Contexto do Negócio
A Northwind Traders é uma distribuidora global de alimentos especializados que enfrenta o desafio de escalar suas operações em um mercado altamente competitivo. Atualmente, a empresa lida com uma volumetria crescente de pedidos e uma logística internacional complexa. A necessidade atual é transformar dados brutos de vendas e logística em inteligência estratégica, garantindo que a operação tenha visibilidade total sobre o fluxo de pedidos, prazos de entrega e saúde financeira das transações.

## 2. Stakeholders
*   **Operações e Logística (Negócio):** Interessados na eficiência do despacho e no cumprimento dos prazos de entrega internacional.
*   **Liderança Executiva:** Necessita de KPIs consolidados para direcionamento estratégico e expansão de mercado.
*   **Engenharia de Dados:** Responsável pela arquitetura e robustez dos pipelines que sustentam a plataforma analítica.
*   **Analistas de BI e Negócio:** Consumidores finais que dependem de dados confiáveis para dashboards de monitoramento e relatórios de performance.
*   **Time de Infraestrutura / SRE:** Focado na confiabilidade do ambiente de nuvem, segurança dos dados e disponibilidade do banco de dados.

## 3. Perguntas de Negócio
*   Qual a rentabilidade real por categoria de produto, subtraindo custos de frete e descontos aplicados?
*   Onde estão os gargalos logísticos que impedem o cumprimento da `required_date`?
*   Quais clientes ou regiões apresentam maior tendência de atraso ou pedidos incompletos?
*   Como a escolha da transportadora impacta diretamente no custo operacional e na satisfação do cliente (prazo)?
*   Existe correlação entre o volume de pedidos e a eficiência do processamento por funcionário?

## 4. Fluxos Críticos
*   **Pipeline de Ingestão:** Processamento automatizado de fontes de dados (CSV) para um ambiente de dados estruturado (Postgres).
*   **Ciclo de Entrega de Informação:** Garantia de que os dados transacionais do dia anterior estejam disponíveis e validados para análise nas primeiras horas da manhã.
*   **Monitoramento de SLA de Dados:** Observabilidade sobre o tempo de execução e sucesso das cargas de dados.
*   **Fluxo de Governança:** Validação da integridade e consistência dos dados entre os sistemas de origem e o destino analítico.

## 5. Riscos Sistêmicos
*   **Perda Silenciosa de Linhas:** Falhas na ingestão que resultam em dados incompletos sem disparar alertas imediatos.
*   **Efeito "Stale Data":** Decisões baseadas em dados desatualizados devido a falhas não detectadas no pipeline.
*   **Incerteza Financeira:** Divergências em cálculos de impostos, fretes e descontos que podem distorcer a percepção de lucro.
*   **Escalabilidade Ineficiente:** Aumento desproporcional de custos de nuvem em relação ao volume de dados processados.

## 6. Modos de Falha
*   **Degradação de Fonte de Dados:** Mudanças inesperadas no esquema ou formato dos arquivos CSV de origem.
*   **Quebra de Idempotência:** Reprocessamentos que causam duplicação de registros, inflando artificialmente os números de venda.
*   **Esgotamento de Recursos:** Falhas de processamento por falta de memória ou queda de instâncias durante picos de carga.
*   **Inconsistência de Negócio:** Dados que passam na validação técnica mas violam regras de negócio (ex: data de envio anterior à data do pedido).

## 7. Propriedades Emergentes Alvo
*   **Integridade Referencial Absoluta:** Garantia de que cada detalhe de pedido esteja corretamente vinculado ao seu respectivo cabeçalho e produto.
*   **Consistência Temporal:** Visibilidade clara da linha do tempo de cada pedido, permitindo análise precisa de lead time.
*   **Alta Disponibilidade Analítica:** Sistema resiliente que garante o acesso à informação mesmo após falhas parciais.
*   **Transparência de Custos:** Capacidade de atribuir custos de infraestrutura de forma clara e eficiente.

## 8. Fora de Escopo
*   Implementação de sistemas de ERP ou entrada de pedidos (Frontend).
*   Gestão de inventário físico e controle de armazém.
*   Automação de marketing ou CRM.
*   Previsão de demanda baseada em modelos de Machine Learning avançados (foco atual é descritivo/diagnóstico).
