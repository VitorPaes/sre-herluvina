# Story: Execução dos Testes de Carga e Performance - Northwind Traders

**ID**: STORY-02  
**Status**: To Do  
**Autor**: SRE / QA Engineer  

Esta story gerencia o ciclo completo de implementação e execução dos testes de carga, soak, spike e estresse especificados no plano de testes analíticos em [documents/05_performance_test_plan.md](file:///workspaces/sre-herluvina/documents/05_performance_test_plan.md). O escopo engloba o provisionamento do ambiente k6 local, a criação dos scripts JS, a automação dos gatilhos de concorrência e a consolidação das métricas de latência e resiliência contra os SLOs estabelecidos.

---

## 1. Critérios de Aceitação

Os critérios de aceitação foram estruturados para garantir a cobertura completa dos cenários de teste (`TC-24` a `TC-27`) e validação dos limites de recursos locais:

*   **AC-01**: Ambiente de execução do k6 configurado localmente via Docker Host sem interferir nos containers de produção (MinIO, Streamlit).
*   **AC-02**: Scripts JavaScript de teste do k6 desenvolvidos e parametrizados individualmente para simular o comportamento analítico de usuários (acessos WebSocket/HTTP no Streamlit e MinIO).
*   **AC-03**: Scripts de automação CLI criados para engatilhar as concorrências de escrita (pipeline de ETL rodando dbt/DuckDB) simultaneamente às execuções de testes do k6.
*   **AC-04**: Evidências de execução de cada cenário coletadas (saídas de terminal k6, dumps de consumo de CPU/Memória RAM e logs de erros do DuckDB).
*   **AC-05**: Relatório de análise de SRE consolidando as latências P95 e taxas de falhas contra os limites de SLO dos requisitos não funcionais.

---

## 2. Checklist de Progresso

A execução está estruturada em 5 etapas sequenciais:

- [ ] **Etapa 1: Configuração do Ambiente e Geração de Massa de Testes**
  - [ ] Instalar e testar CLI do k6 no Docker Host ou em container isolado
  - [ ] Desenvolver scripts geradores de massa de teste em CSV para volumetria analítica (50.000, 250.000 e 1.000.000 de registros de vendas)
  - [ ] Validar a integridade lógica e referencial da massa fictícia antes de carregar no MinIO
- [ ] **Etapa 2: Implementação dos Scripts de Carga (k6)**
  - [ ] Codificar o script k6 para simular consultas no dashboard Streamlit (`tests/performance/k6_streamlit_load.js`)
  - [ ] Implementar thresholds do k6 vinculados ao **RNF-07** (tempo de resposta P95 <= 5.0 segundos) e **RNF-09** (taxa de erro < 1.0%)
  - [ ] Validar execução seca (dry-run) de 1 VU por 10 segundos para cada script k6
- [ ] **Etapa 3: Automação dos Gatilhos de Concorrência**
  - [ ] Implementar script bash de concorrência para o Load Test (`bin/run-load-test.sh`), coordenando k6 e `bin/run-pipeline.sh`
  - [ ] Implementar script bash de concorrência para o Spike Test (`bin/run-spike-test.sh`), carregando 250k linhas sob pico de 100 VUs
  - [ ] Configurar script de telemetria daemon para capturar dados do `docker stats` a cada 5 segundos
- [ ] **Etapa 4: Execução dos Casos de Teste (TC-24 a TC-27)**
  - [ ] Executar o Load Test de Coexistência (`TC-24`) por 15 minutos e capturar logs do DuckDB e k6
  - [ ] Executar o Soak Test de Resistência (`TC-25`) por 4 horas e monitorar vazamento de memória RAM no host
  - [ ] Executar o Spike Test de Carga Repentina (`TC-26`) por 10 minutos e verificar logs do Kernel contra OOM Killers
  - [ ] Executar o Stress Test de Saturação (`TC-27`) até quebrar o limite de SLO ou exaurir recursos do host
- [ ] **Etapa 5: Consolidação de Resultados e Relatório SRE**
  - [ ] Reunir logs de erros do DuckDB e mapear timeouts ou travamentos por concorrência de escrita (**RNF-05**)
  - [ ] Consolidar métricas do k6 e traçar curvas de performance (RPS vs Latência P95)
  - [ ] Produzir o Relatório Final de Performance contendo as recomendações de mitigação de concorrência e ajustes de hardware
  - [ ] Atualizar o status dos testes na Matriz de Rastreabilidade (RTM)

---

## 3. Lista de Arquivos Planejada (File List)

Esta lista inclui os arquivos de código e configuração que serão criados ou atualizados durante a story:

- [ ] `tests/performance/k6_streamlit_load.js` -> Script JavaScript de navegação analítica simulada.
- [ ] `tests/performance/generator_test_data.py` -> Script auxiliar em Python para gerar arquivos CSV fictícios de alta volumetria.
- [ ] `bin/run-load-test.sh` -> Script de disparo coordenado k6 + orquestrador de ETL local (TC-24).
- [ ] `bin/run-spike-test.sh` -> Script de disparo coordenado k6 + carga massiva de 250k linhas (TC-26).
- [ ] `bin/monitor-host-resources.sh` -> Script de coleta contínua de telemetria do host (CPU/RAM do container Streamlit).
- [ ] `documents/06_performance_results_report.md` -> Relatório contendo as análises dos resultados obtidos.

---

## 4. Riscos e Ambiguidades

Abaixo estão detalhados os riscos técnicos da implementação e as ambiguidades identificadas no escopo desta story.

### Riscos Técnicos de Implementação (3)
1.  **Distorção de Métricas por Concorrência com k6**: O k6 gera carga executando scripts JavaScript localmente. Rodar o k6 no mesmo Docker Host onde o Streamlit e o DuckDB estão em execução consome CPU e recursos de rede local. Isso pode distorcer o resultado dos testes, reduzindo a CPU disponível para o dbt e gerando latências artificiais nos SLOs de tempo de pipeline (RNF-03) e query (RNF-07).
2.  **Corrupção de Volumes do Docker MinIO no Spike Test**: Durante o Spike Test (TC-26), a injeção rápida de 250k linhas no MinIO com 100 VUs gerando tráfego simultâneo de rede local pode corromper a estrutura lógica de diretórios montados no container do MinIO se o sistema de arquivos local do Host sofrer sobrecarga de locks de I/O.
3.  **Vazamento de Dados Fictícios de Massa de Testes para Produção**: Caso os CSVs fictícios gerados para estressar a base contendo nomes de produtos ou clientes duplicados/falsos sejam acidentalmente importados nas tabelas oficiais de negócios sem expurgo após o ciclo de testes, as métricas geradas no dashboard para a diretoria serão corrompidas (Efeito *Stale/Dirty Data*).

### Ambiguidades Pendentes (2)
1.  **Critério de Limite Máximo de Consumo de RAM no Host Local**: Não há parâmetros no projeto que definam qual o limite aceitável de memória RAM do host que o Streamlit pode consumir antes de ser considerado "falha de recursos" no Soak Test (TC-25). Sem esse limite (ex: 2GB de limite por container), o teste pode passar tecnicamente (sem crash), mesmo consumindo quase toda a RAM livre da máquina de desenvolvimento.
2.  **Tratamento de Erros de Conexão Recusada no k6**: Caso o Streamlit recuse conexões durante o Stress Test (TC-27) por atingir o limite padrão de WebSockets ativos, resta ambíguo se o script do k6 deve contabilizar isso como falha crítica de disponibilidade (quebrando o SLO do RNF-09) ou tratá-lo apenas como uma contenção esperada da porta de rede do host de desenvolvimento.

---
