# Modernização Analítica da Northwind Traders

Este repositório contém a especificação arquitetural, de engenharia de dados e SRE para a modernização analítica local da Northwind Traders, desenvolvida como o trabalho final da disciplina de SRE para Engenharia de Dados.

---

## 1. Estrutura da Documentação do Projeto

A documentação está dividida de forma estruturada na pasta `documents/` para cobrir os diferentes aspectos do ciclo de vida e qualidade dos dados:

1. **[00_problem.md](file:///workspaces/sre-herluvina/documents/00_problem.md):** Contextualização do negócio, stakeholders, perguntas estratégicas de negócio, fluxos críticos e riscos sistêmicos da Northwind Traders.
2. **[01_functional_requirements.md](file:///workspaces/sre-herluvina/documents/01_functional_requirements.md):** Especificação detalhada dos Requisitos Funcionais (RF-NN) mapeados segundo a sintaxe EARS, com critérios de aceitação em Gherkin e priorização MoSCoW.
3. **[02_architecture.md](file:///workspaces/sre-herluvina/documents/02_architecture.md):** Desenho arquitetural do pipeline ELT local usando Mermaid, modelagem dimensional em estrela (Star Schema) e as decisões de arquitetura documentadas em ADRs estáveis (ADR-NN).
4. **[03_testing_observability.md](file:///workspaces/sre-herluvina/documents/03_testing_observability.md):** Casos de teste de qualidade e integridade (TC-NN), lógica de idempotência, auditoria de cargas e desenho de observabilidade local.

---

## 2. Visão Geral das Fontes de Dados Locais

O pipeline consome os dados brutos de vendas que residem localmente na pasta `data/`:
- `data/northwind_orders.csv`: Cabeçalhos dos pedidos contendo informações de frete, datas chave e transportadoras.
- `data/northwind_order_details.csv`: Itens detalhados de cada pedido contendo preços de venda, quantidade e descontos.

---

## 3. Diretrizes de Execução e Segurança (Restrições Duras)

- **Sem Nuvem (Tudo Local):** Toda a especificação e as futuras execuções de banco de dados (PostgreSQL) e transformações de dados (dbt Core) ocorrem de forma 100% local, em conformidade com as diretrizes do projeto.
- **Segurança de Segredos:** Nenhuma credencial de banco de dados ou caminho absoluto deve ser versionada no código. Toda configuração sensível é armazenada em variáveis de ambiente carregadas via arquivo local `.env` (ignorado pelo Git).
- **Sem Provisionamento Ativo:** O escopo atual limita-se à documentação arquitetural analítica estruturada e modelagem em diagramas Mermaid.

---

## 4. Riscos e Ambiguidades da README

### Riscos
1. **Desatualização do Sumário de Arquivos:** À medida que o projeto evoluir e novos arquivos de documentação ou scripts de infraestrutura forem adicionados, a `README.md` pode ficar defasada se não for mantida em paralelo, confundindo novos engenheiros.
2. **Falta de Contexto Operacional Direto:** A `README.md` atua como guia de alto nível. Desenvolvedores que tentarem rodar ferramentas locais sem consultar especificamente os requisitos de segurança e dependências em `02_architecture.md` podem causar violações involuntárias de boas práticas do projeto.
3. **Incompatibilidade de Renderização de Links Relativos:** Dependendo da plataforma ou cliente Git utilizado (ex: editores markdown locais sem suporte ao protocolo `file:///`), os links internos relativos para os documentos de requisitos e arquitetura podem não funcionar corretamente offline.

### Ambiguidades
1. **Perfil de Usuário Alvo da Documentação:** Não está explícito se este guia principal é voltado para engenheiros de dados executores, analistas de negócios consumidores ou administradores SRE, dificultando a dosagem de detalhes técnicos e de governança na página de entrada.
2. **Ambiente Alvo de Desenvolvimento:** Embora seja estritamente local, a `README.md` não especifica o sistema operacional local de referência esperado para os desenvolvedores (Linux, Windows via WSL, macOS), o que gera ambiguidades sobre o ferramental padrão de shell a ser adotado para executar os comandos locais.
