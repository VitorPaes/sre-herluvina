# Story: Implementação do Plano de Segurança - Northwind Traders

**ID**: STORY-03  
**Status**: To Do  
**Autor**: SRE / Security Engineer  

Esta story gerencia a execução do plano de segurança e a automação dos testes de vulnerabilidade estruturados em [documents/06_security_test_plan.md](file:///workspaces/sre-herluvina/documents/06_security_test_plan.md). O escopo compreende a higienização de segredos em código, a ativação do Bandit (SAST), do Trivy (SCA), do OWASP ZAP (DAST), do Gitleaks (secret scanning) e a auditoria de postura do MinIO (Prowler), além do endurecimento (*hardening*) de containers Docker para operação local segura.

---

## 1. Critérios de Aceitação

*   **AC-01**: Hooks de pré-commit do Gitleaks ativados localmente impedindo commits com credenciais em texto plano (**TC-SEC-04**).
*   **AC-02**: Execução local do Bandit integrada para auditoria SAST do diretório de código Python (`app/`), com relatório livre de falhas de alta severidade (**TC-SEC-01**).
*   **AC-03**: Varredura SCA com Trivy ativa sobre dependências e imagens base Docker, garantindo ausência de CVEs críticas sem mitigação (**TC-SEC-02**).
*   **AC-04**: Containers Docker configurados para rodar sob usuário comum sem privilégios (*non-root*), isolando o host local.
*   **AC-05**: Dashboard analítico Streamlit protegido por HTTPS (SSL/TLS local) e camada de autenticação básica para acesso interno.
*   **AC-06**: Scripts automatizados de scans dinâmicos locais (OWASP ZAP para DAST e Prowler para postura S3) executáveis via terminal CLI (**TC-SEC-03** e **TC-SEC-05**).

---

## 2. Checklist de Progresso

Mapeamento de tarefas separado pelas 3 partes operacionais definidas no plano de segurança:

- [ ] **Etapa 1: Higienização de Código e Gestão de Segredos**
  - [ ] Instalar CLI do Gitleaks no host de desenvolvimento
  - [ ] Configurar hook `pre-commit` local via ferramenta git hooks
  - [ ] Adicionar arquivo `.env` e chaves privadas do MinIO explicitamente no `.gitignore`
  - [ ] Executar scan completo do histórico do Git com Gitleaks e sanar vazamentos históricos
- [ ] **Etapa 2: Análise Estática e Endurecimento de Build (SAST / SCA)**
  - [ ] Configurar e rodar Bandit localmente (`bandit -r app/`) gerando relatórios JSON de vulnerabilidades
  - [ ] Criar arquivo de regras de exceção do Bandit para ignorar falsos positivos aceitos
  - [ ] Integrar Trivy no processo de build local do docker-compose para escanear `requirements.txt`
  - [ ] Modificar o `Dockerfile` para incluir criação de grupo/usuário (`appuser`) e diretriz `USER appuser`
  - [ ] Ajustar permissões de escrita do volume `northwind.duckdb` no host para o novo `appuser` do container
- [ ] **Etapa 3: Defesa Operacional e Auditoria Dinâmica (DAST / Posture)**
  - [ ] Implementar login e senha criptografados locais para a interface Streamlit
  - [ ] Configurar certificados autoassinados via OpenSSL local para ativar HTTPS no Streamlit e MinIO
  - [ ] Configurar container do OWASP ZAP CLI local para rodar scans de vulnerabilidade contra a porta `8501`
  - [ ] Criar script script wrapper para rodar Prowler contra a API S3 local do container MinIO
  - [ ] Consolidar todas as ferramentas de scan em um script unificador `bin/run-security-scans.sh`
  - [ ] Atualizar status dos testes de segurança na Matriz de Rastreabilidade (RTM)

---

## 3. Lista de Arquivos Planejada (File List)

Esta lista especifica os arquivos de código e infraestrutura que serão criados ou editados no decorrer da story:

- [ ] `bin/run-security-scans.sh` -> Script unificador que dispara Bandit, Trivy, Gitleaks, ZAP e Prowler localmente.
- [ ] `Dockerfile` -> Modificado para implementar segurança de containers (Non-root user).
- [ ] `docker-compose.yml` -> Atualizado com configurações HTTPS (volumes de certificados) e isolamento de rede.
- [ ] `app/main.py` -> Atualizado com lógica de autenticação básica para os analistas de BI.
- [ ] `.gitleaks.toml` -> Configuração customizada de regras e exceções do Gitleaks.
- [ ] `documents/07_security_compliance_report.md` -> Relatório contendo as análises dos resultados obtidos nos testes dinâmicos de segurança.

---

## 4. Riscos e Ambiguidades

Abaixo estão listados os riscos estruturais e as ambiguidades identificadas na execução desta story.

### Riscos Técnicos de Implementação (3)
1.  **Bloqueio de Commits Locais por Falsos Positivos do Gitleaks**: O hook pre-commit do Gitleaks pode detectar falsos positivos (ex: strings de testes matemáticos de frete ou hashes normais interpretados como chaves privadas), impedindo a produtividade diária do desenvolvedor (retardando entregas de dbt/Python).
2.  **Perda de Acesso ao Arquivo DuckDB por Conflitos de Permissão Non-Root**: Ao alterar os containers para rodar sob um usuário não-privilegiado (`appuser`), a montagem do volume físico local `./data/northwind.duckdb` pode falhar por falta de permissão de escrita/leitura no host OS, paralisando o Streamlit e o dbt runner até que as ACLs do host sejam ajustadas manualmente.
3.  **Bypass Silencioso de Alertas de HTTPS no k6 e ZAP**: Para testar a segurança em ambiente puramente local sem domínios válidos, as ferramentas de teste (k6, OWASP ZAP) precisam rodar com flags de desabilitação de verificação SSL/TLS (`insecureSkipTLSVerify` ou similar). Isso pode fazer com que o desenvolvedor se acostume a ignorar certificados inválidos, abrindo brecha para ataques reais de falsificação de domínio no ambiente local de escritório.

### Ambiguidades Pendentes (2)
1.  **Origem e Armazenamento dos Certificados SSL Locais**: Resta ambíguo quem gerencia e renova os certificados SSL autoassinados gerados localmente via OpenSSL. Se os certificados expirarem silenciosamente sem um processo automático de renovação scriptado, o ecossistema local do Streamlit e MinIO parará de responder às chamadas analíticas da rede interna (quebrando o SLO de disponibilidade do RNF-09).
2.  **Mapeamento de Usuários Fictícios vs Identidades Reais**: Como o Streamlit operará offline (on-premises) sem um serviço de diretórios LDAP/AD unificado, a autenticação das contas de usuários do dashboard deverá ser chumbada em variáveis de ambiente locais do container. Isso gera ambiguidade sobre como gerenciar e atualizar senhas com segurança, sem expô-las no Git, caso novos analistas entrem ou saiam da Northwind Traders.

---
*Fim do Documento da Story.*
