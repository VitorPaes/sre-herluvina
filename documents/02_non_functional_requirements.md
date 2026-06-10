# Requisitos Não Funcionais (RNF) - Northwind Traders

Este documento define os Requisitos Não Funcionais (RNF) para a plataforma de inteligência analítica local da Northwind Traders, relacionando-os diretamente às partes interessadas (stakeholders) e aos fluxos críticos identificados no problema de negócio.

A modelagem destes requisitos baseia-se nos **8 atributos de qualidade de software definidos pela norma ISO/IEC 25010**. Cada requisito é estritamente mensurável e testável por meio de Indicadores de Nível de Serviço (**SLI**) e Objetivos de Nível de Serviço (**SLO**) específicos, livres de definições subjetivas ou acoplamento antecipado a tecnologias de implementação.

---

## 1. Mapeamento de Stakeholders e Fluxos Críticos

Para contextualizar a origem e necessidade de cada requisito, a tabela abaixo mapeia quais fluxos de negócio críticos (definidos em [00_problem.md](file:///workspaces/sre-herluvina/documents/00_problem.md)) impactam os diferentes stakeholders e quais atributos da ISO 25010 são primordiais para cada relação.

| Fluxo Crítico | Stakeholders Impactados | Atributos ISO 25010 Primordiais |
| :--- | :--- | :--- |
| **Pipeline de Ingestão** | Engenharia de Dados, Time de Infraestrutura / SRE | Adequação Funcional, Eficiência de Desempenho, Confiabilidade |
| **Ciclo de Entrega de Informação** | Liderança Executiva, Analistas de BI e Negócio, Operações | Confiabilidade, Eficiência de Desempenho, Usabilidade |
| **Monitoramento de SLA de Dados** | Engenharia de Dados, Time de Infraestrutura / SRE | Manutenibilidade, Confiabilidade |
| **Fluxo de Governança** | Engenharia de Dados, Analistas de BI e Negócio | Segurança, Adequação Funcional, Portabilidade |

---

## 2. Requisitos Não Funcionais por Atributo da ISO/IEC 25010

Abaixo são detalhados os requisitos não funcionais para cada um dos 8 atributos da norma ISO/IEC 25010 de forma agnóstica de ferramentas. Cada requisito contém um **SLI (Indicador de Nível de Serviço)**, um **SLO (Objetivo de Nível de Serviço)**, uma **unidade de medida**, a **janela de tempo** aplicável, as **premissas** do ambiente e a **fonte de medição** dos logs.

---

### 2.1. Adequação Funcional (Functional Suitability)
Foca em quão bem as funções de dados atendem às necessidades declaradas e implícitas da operação analítica.

#### RNF-01: Integridade Referencial e Consistência Dimensional
*   **Descrição:** Garantia de que cada detalhe de transação inserido no repositório analítico final de destino esteja corretamente correlacionado às respectivas entidades primárias e dimensões de negócios correspondentes.
*   **SLI:** Percentual de registros na tabela de detalhes de fatos que possuem chaves estrangeiras (`FK`) apontando para chaves primárias válidas e existentes nas tabelas dimensionais e de cabeçalho.
*   **SLO:** 100% de integridade referencial nas tabelas dimensionais e de fatos.
*   **Unidade:** Percentual (%) de registros com chaves órfãs igual a 0%.
*   **Janela:** Execução diária do pipeline.
*   **Premissas:** Os dados fornecidos pelos sistemas de origem local não possuem nulos em colunas de junção essenciais.
*   **Fonte de Medição:** Logs de testes executados pelo módulo validador de integridade e consistência lógica do pipeline, armazenados no repositório de logs do sistema.
*   **Prioridade MoSCoW:** Must

#### RNF-02: Completude Quantitativa de Carga
*   **Descrição:** Garantia de integridade de ingestão, prevenindo a perda silenciosa de linhas de pedidos ao carregar dados brutos das fontes de arquivos locais para o banco analítico.
*   **SLI:** Razão entre o total de registros persistidos no repositório na camada inicial (raw) e o total de linhas lidas dos arquivos físicos de origem local (desconsiderando a linha de cabeçalho).
*   **SLO:** Razão igual a 1.0 (100% de paridade quantitativa).
*   **Unidade:** Razão adimensional de reconciliação de contagem de linhas.
*   **Janela:** Lote diário processado.
*   **Premissas:** Os arquivos de dados na origem local não estão corrompidos e são acessíveis pelo sistema de arquivos.
*   **Fonte de Medição:** Logs de auditoria interna gerados pelo pipeline de ingestão comparando contagens de registros.
*   **Prioridade MoSCoW:** Must

---

### 2.2. Eficiência de Desempenho (Performance Efficiency)
Relaciona-se ao tempo de resposta, processamento e capacidade de uso dos recursos locais de computação.

#### RNF-03: Tempo de Execução do Pipeline (Comportamento Temporal)
*   **Descrição:** O pipeline completo de processamento local (carga inicial + transformações analíticas + gravação de logs) deve rodar a tempo de garantir dados atualizados aos tomadores de decisão nas primeiras horas da manhã.
*   **SLI:** Tempo total decorrido (em minutos) desde o acionamento inicial da leitura de dados brutos até a conclusão e validação da última tabela da camada analítica.
*   **SLO:** <= 45 minutos.
*   **Unidade:** Minutos.
*   **Janela:** Execução diária do pipeline.
*   **Premissas:** O volume de dados de transações diárias não excede 50.000 registros por lote.
*   **Fonte de Medição:** Carimbos de data/hora (timestamps) de início e fim registrados no log de execução do orquestrador de tarefas local.
*   **Prioridade MoSCoW:** Must

#### RNF-04: Rastreabilidade de Erros e Logs de Processamento (Analisabilidade)
*   **Descrição:** Garantia de observabilidade sobre o pipeline de processamento de dados, mapeando e registrando estruturalmente todos os erros ocorridos durante as etapas de ingestão, transformação e carga.
*   **SLI:** Percentual de falhas de processamento e execução (quebras de tipos, erros de junção e violações de regras) capturadas de forma legível e gravadas nos arquivos de log.
*   **SLO:** 100% das falhas de ETL capturadas em log.
*   **Unidade:** Percentual (%) de falhas rastreáveis e logadas.
*   **Janela:** Lote de processamento diário.
*   **Premissas:** O container do pipeline monta a pasta de logs local para persistência de dados.
*   **Fonte de Medição:** Inspeção e validação do volume de logs montado localmente no host.
*   **Prioridade MoSCoW:** Must

---

### 2.3. Compatibilidade (Compatibility)
Foca na capacidade de coexistir com outros componentes locais e na facilidade de intercâmbio de dados de forma harmônica.

#### RNF-05: Coexistência de Concorrência de Recursos Locais
*   **Descrição:** As transformações de dados não devem causar bloqueios exclusivas (locks) prolongados no repositório local que impeçam a visualização ou o consumo por ferramentas analíticas.
*   **SLI:** Percentual de consultas de leitura e relatórios cancelados ou com falha de timeout em decorrência de contenções de bloqueio causadas pelas transações de escrita do pipeline.
*   **SLO:** 0% de consultas analíticas interrompidas por timeout de contenção de escrita.
*   **Unidade:** Percentual (%) de consultas interrompidas.
*   **Janela:** Janela mensal (30 dias).
*   **Premissas:** O banco de dados analítico local implementa o isolamento de concorrência com controle de versões (ex: MVCC).
*   **Fonte de Medição:** Logs de eventos, conexões e sessões ativas do banco de dados analítico local.
*   **Prioridade MoSCoW:** Should

#### RNF-06: Interoperabilidade de Formato de Arquivos Locais
*   **Descrição:** O pipeline analítico deve ser capaz de processar dados em formato de texto delimitado local sem falhar por codificação ou divergência de layouts comuns.
*   **SLI:** Taxa de sucesso no carregamento de arquivos de texto formatados em layout de mercado padrão estruturado e codificação de caracteres de amplo uso.
*   **SLO:** 100% de decodificação correta utilizando codificação de caracteres universal (UTF-8).
*   **Unidade:** Percentual (%) de arquivos processados sem interrupção por erros de caracteres.
*   **Janela:** Execução diária.
*   **Premissas:** Os arquivos extraídos dos sistemas de origem estão normalizados na codificação estipulada.
*   **Fonte de Medição:** Logs de tratamento de exceções e parser do pipeline local.
*   **Prioridade MoSCoW:** Must

---

### 2.4. Usabilidade (Usability)
Trata da eficácia, eficiência e satisfação com que usuários analíticos consultam o repositório de dados.

#### RNF-07: Tempo de Resposta para Consultas Analíticas (Operabilidade)
*   **Descrição:** O banco analítico local deve responder às consultas de negócios de forma célere para garantir a eficiência na geração de insights operacionais.
*   **SLI:** Tempo decorrido de execução interna para consultas de agregação analítica baseadas em filtros logísticos, temporais e financeiros.
*   **SLO:** <= 5.0 segundos no percentil 95 (P95).
*   **Unidade:** Segundos.
*   **Janela:** Janela diária comercial (das 08:00 às 18:00).
*   **Premissas:** As queries limitam os filtros analíticos a períodos históricos iguais ou inferiores a 2 anos e utilizam as chaves de otimização definidas.
*   **Fonte de Medição:** logs e views internas de telemetria de consultas analíticas do banco de dados local.
*   **Prioridade MoSCoW:** Should

---

### 2.5. Confiabilidade (Reliability)
Reflete a maturidade, a resiliência a falhas, a capacidade de se recuperar e de manter o sistema disponível.

#### RNF-08: Idempotência de Reprocessamentos (Recuperabilidade)
*   **Descrição:** Em cenários de interrupções abruptas do pipeline, a sua reexecução manual ou automatizada não deve duplicar registros ou deturpar o cálculo de métricas acumuladas.
*   **SLI:** Quantidade de registros com chaves de negócios repetidas em tabelas analíticas após a reexecução corretiva completa de uma carga que falhou anteriormente.
*   **SLO:** 0 registros duplicados.
*   **Unidade:** Quantidade absoluta de duplicados.
*   **Janela:** Por execução de recuperação pós-falha.
*   **Premissas:** O pipeline possui mecanismos lógicos de truncagem, recriação total ou inserção com verificação de chaves exclusivas.
*   **Fonte de Medição:** Relatório de testes automatizados de chaves exclusivas executados logo após a reexecução.
*   **Prioridade MoSCoW:** Must

#### RNF-09: Disponibilidade do Repositório Analítico Local
*   **Descrição:** O banco de dados analítico local deve se manter responsivo a conexões para leituras analíticas e escritas do pipeline.
*   **SLI:** Proporção de tempo em que a porta do serviço de banco de dados analítico local está ativa e aceitando conexões de rede padrão.
*   **SLO:** >= 99.0% de tempo de atividade (Uptime).
*   **Unidade:** Percentual (%) de tempo ativo.
*   **Janela:** Janela mensal (30 dias).
*   **Premissas:** O sistema host que hospeda o banco de dados possui fornecimento elétrico regular e o serviço de banco está configurado para reinicializar em caso de falha de processo.
*   **Fonte de Medição:** Script ou daemon periódico de verificação de conexão (health check) executado localmente a cada 60 segundos.
*   **Prioridade MoSCoW:** Must

---

### 2.6. Segurança (Security)
Define o nível de proteção dos dados confidenciais de transações, credenciais e trilha de auditoria.

#### RNF-10: Prevenção contra Exposição de Credenciais (Confidencialidade)
*   **Descrição:** Parâmetros de autenticação, senhas e informações confidenciais de diretórios locais não devem ser expostos ou versionados nos repositórios de código-fonte.
*   **SLI:** Quantidade de credenciais de bancos de dados analíticos ou caminhos privados gravados diretamente em arquivos no controle de versão Git.
*   **SLO:** 0 segredos ou credenciais expostos no código-fonte.
*   **Unidade:** Contagem absoluta de segredos identificados.
*   **Janela:** A cada commit executado na branch local de desenvolvimento.
*   **Premissas:** As credenciais de acessos locais são inseridas em runtime via variáveis de ambiente carregadas de arquivo de configuração local ignorado pelo controle de versão.
*   **Fonte de Medição:** Ferramenta automatizada de análise estática de segurança e scanner de segredos executada localmente.
*   **Prioridade MoSCoW:** Must

#### RNF-11: Rastreabilidade de Alterações de Dados (Não-repúdio / Responsabilidade)
*   **Descrição:** As operações de manipulação de escrita no banco de dados analítico local devem ser registradas para auditorias regulatórias e segurança dos dados financeiros.
*   **SLI:** Percentual de instruções do tipo `INSERT`, `UPDATE` e `DELETE` efetuadas nas tabelas analíticas finais capturadas de forma estruturada.
*   **SLO:** 100% de transações de escrita auditadas.
*   **Unidade:** Percentual (%) de instruções modificadoras auditadas.
*   **Janela:** Janela semanal (7 dias).
*   **Premissas:** Os scripts de execução analítica conectam-se utilizando usuários ou privilégios distintos e identificáveis no banco.
*   **Fonte de Medição:** Módulo de logs de auditoria interna habilitado nas configurações do banco de dados local.
*   **Prioridade MoSCoW:** Should

---

### 2.7. Manutenibilidade (Maintainability)
Representa a facilidade de modificar o pipeline de dados, diagnosticar falhas e manter o sistema estável.

#### RNF-12: Tempo Médio de Alerta de Falhas (Analisabilidade)
*   **Descrição:** Falhas na integridade de dados ou interrupções abruptas no pipeline analítico devem disparar alertas legíveis imediatamente para correção.
*   **SLI:** Tempo transcorrido entre a ocorrência de erro crítico de carregamento ou teste e o registro estruturado da falha nos logs permanentes de erros de auditoria.
*   **SLO:** <= 5 minutos.
*   **Unidade:** Minutos.
*   **Janela:** Janela de execução diária (últimas 24 horas).
*   **Premissas:** O pipeline de processamento possui blocos de tratamento de erros configurados para registrar falhas em metadados de execução.
*   **Fonte de Medição:** Diferença de timestamps entre o registro do erro do orquestrador e a persistência no banco de dados analítico local de logs.
*   **Prioridade MoSCoW:** Must

#### RNF-13: Cobertura de Testes Lógicos de Negócios (Testabilidade)
*   **Descrição:** Os cálculos de negócios essenciais (como rateio de frete e rentabilidade) devem possuir testes automáticos de consistência de dados implementados.
*   **SLI:** Percentual de colunas analíticas das tabelas finais cobertas por testes automatizados de consistência (nulidade, chaves exclusivas, limites de valores e regras lógicas).
*   **SLO:** >= 90% das colunas finais fundamentais testadas.
*   **Unidade:** Percentual (%) de atributos cobertos por validação.
*   **Janela:** A cada implantação (build/deploy) ou alteração do código do pipeline.
*   **Premissas:** As regras lógicas de transformação estão mapeadas em arquivos de especificação.
*   **Fonte de Medição:** Relatório de testes emitido no console do desenvolvedor a cada execução do ciclo de testes analíticos do pipeline.
*   **Prioridade MoSCoW:** Must

---

### 2.8. Portability (Portabilidade)
Diz respeito à capacidade de transferir e inicializar o sistema de processamento de dados local de um computador de desenvolvimento para outro.

#### RNF-14: Tempo de Instalação do Ambiente Local (Instalabilidade)
*   **Descrição:** A configuração e execução de um ambiente local limpo de desenvolvimento do pipeline analítico deve demandar o mínimo de configuração manual.
*   **SLI:** Tempo total necessário para clonar o repositório, criar a base de dados local, rodar scripts de criação de schemas e processar o pipeline até a disponibilização das tabelas finais de negócios.
*   **SLO:** <= 15 minutos.
*   **Unidade:** Minutos.
*   **Janela:** Auditoria periódica ou setup de novas máquinas de desenvolvimento.
*   **Premissas:** A máquina destino possui os pré-requisitos mínimos instalados localmente (como linguagem de script, controle de versão e engine de banco local).
*   **Fonte de Medição:** Registro de tempo total de execução do script de instalação automatizada executado na máquina de testes.
*   **Prioridade MoSCoW:** Should

---

## 3. Tabela Consolidada de Requisitos Não Funcionais (SLI/SLO)

A tabela abaixo resume e consolida todos os Requisitos Não Funcionais, fornecendo um catálogo técnico direto e agnóstico de tecnologias para parametrização de testes e auditorias locais.

| ID | Atributo ISO 25010 | SLI | SLO | Fonte de Medição | Prioridade MoSCoW |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **RNF-01** | Adequação Funcional | % de registros na tabela de detalhes de fatos com chaves estrangeiras (`FK`) apontando para chaves válidas. | 100% de integridade referencial. | Logs de integridade lógica do pipeline | **Must** |
| **RNF-02** | Adequação Funcional | Razão entre registros gravados e linhas físicas lidas nos arquivos de origem. | Razão = 1.0 (100% de linhas salvas). | Logs internos de auditoria de ingestão | **Must** |
| **RNF-03** | Eficiência de Desempenho | Tempo de execução completa do pipeline de dados analíticos local. | <= 45 minutos. | Logs e timestamps do orquestrador local | **Must** |
| **RNF-04** | Manutenibilidade (Analisabilidade) | Rastreabilidade de erros e logs de processamento. | 100% das falhas de ETL capturadas em log. | Inspeção do volume de logs montado no host | **Must** |
| **RNF-05** | Compatibilidade | % de consultas analíticas locais suspensas/canceladas por lock exclusivo de escrita. | 0% de interrupções por lock de escrita. | Logs de conexões/bloqueios do banco analítico | **Should** |
| **RNF-06** | Compatibilidade | % de arquivos processados com sucesso sob codificação de caracteres universal. | 100% de leitura de arquivos em UTF-8. | logs de erros e parser de caracteres | **Must** |
| **RNF-07** | Usability | Tempo de execução do banco de dados para queries SQL analíticas de agregação complexas. | <= 5.0 segundos no 95º percentil (P95). | Logs internos de queries do banco local | **Should** |
| **RNF-08** | Confiabilidade | Contagem de chaves duplicadas em tabelas de destino analítico após reexecução corretiva. | 0 registros duplicados. | Relatório de testes de unicidade do pipeline | **Must** |
| **RNF-09** | Confiabilidade | Tempo de Uptime do serviço de banco analítico local aceitando conexões. | >= 99.0% de tempo de Uptime. | Logs de execução do daemon de health check | **Must** |
| **RNF-10** | Segurança | Segredos ou credenciais expostos e gravados em arquivos do controle de versão. | 0 segredos expostos no repositório. | Varredura estática de segurança local | **Must** |
| **RNF-11** | Segurança | % de comandos DML (`INSERT/UPDATE/DELETE`) na camada final que geram logs de auditoria. | 100% das transações de escrita registradas. | logs de auditoria nativos do banco analítico | **Should** |
| **RNF-12** | Manutenibilidade | Tempo decorrido entre falha no carregamento e registro de alerta estruturado de auditoria. | <= 5 minutos. | Logs e timestamps do orquestrador local | **Must** |
| **RNF-13** | Manutenibilidade | % de colunas finais analíticas validadas por testes automáticos no pipeline de dados. | >= 90% das colunas testadas. | Relatórios estatísticos do console de testes | **Must** |
| **RNF-14** | Portability | Tempo para inicialização completa do ecossistema local em uma nova máquina limpa. | <= 15 minutos. | Tempo de relógio registrado por script de setup | **Should** |

---

## 4. Riscos e Ambiguidades

Abaixo estão listados os riscos estruturais e as ambiguidades identificadas no escopo de medição técnica deste repositório de dados.

### Riscos Sistêmicos de Medição
1. **Dificuldade de Medição Contínua em Ambiente de Sandbox Local:** Devido à restrição técnica de execução puramente local (sem cloud), a coleta de SLIs depende estritamente de scripts internos locais, logs do sistema de arquivos e tabelas do banco analítico de destino. Falhas de concorrência ou permissão de gravação de arquivos locais pelo shell do desenvolvedor podem suspender a auditoria de SLOs silenciosamente.
2. **Impacto no Desempenho do Pipeline pelo Overhead de Auditoria e Testes:** Ativar auditorias nativas minuciosas para rastreabilidade de transações (RNF-11) e rodar testes de integridade referencial a cada carga (RNF-13) gera um alto fluxo de leitura e escrita local (overhead de I/O). À medida que o volume de registros dos arquivos da Northwind acumular no banco de dados local, essas validações podem retardar o processamento diário, quebrando o SLO de comportamento temporal de 45 minutos (RNF-03).
3. **Ausência de Alta Disponibilidade de Hardware em Instâncias Locais:** O banco analítico local opera em infraestrutura local (ex: computador do desenvolvedor ou servidor de arquivos local) sem replicação ativa de dados (Single Point of Failure). Em caso de falha catastrófica de hardware (por exemplo, queima de disco ou perda de energia elétrica no escritório), o SLO de disponibilidade do banco analítico (RNF-09) será imediatamente quebrado, dependendo inteiramente de cópias de segurança manuais ou reimportação de dados.

### Ambiguidades do Escopo Técnico
1. **Definição e Padronização da Janela Comercial de Medição de Queries:** O RNF-07 prevê que consultas analíticas complexas devem responder em até 5 segundos durante a "janela comercial" (08:00 às 18:00). No entanto, não está especificado se esta janela comercial considera o fuso horário da sede corporativa da distribuidora Northwind Traders (EST) ou o fuso horário local dos analistas e desenvolvedores alocados em diferentes regiões geográficas, o que pode enviesar o cálculo do percentil P95.
2. **Critério de Início do SLA de Entrega Diária de Informação:** O pipeline diário de dados é engatilhado pela chegada física dos arquivos CSV no sistema de arquivos local. Há ambiguidade em determinar se o SLA de tempo de processamento total (RNF-03) deve iniciar imediatamente quando o arquivo CSV é depositado no diretório ou a partir do momento em que o agendador de tarefas cron detecta e dispara o script ingestor local. Caso a chegada dos arquivos atrase por parte dos sistemas transacionais de origem, o tempo total decorrido extrapolaria o SLO de 45 minutos, mesmo que o pipeline execute o carregamento de forma eficiente.
