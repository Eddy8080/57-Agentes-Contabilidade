# 57 Agents Contabilidade — Referência Completa

> **57 subagentes especializados** para escritórios contábeis brasileiros, prontos para uso no Claude Code. Cada agente é um especialista em uma rotina específica — apuração, obrigações acessórias, folha, conciliação, atendimento, operação interna — e atua proativamente quando o contexto da conversa bate com sua especialidade.

---

## Instalação

### Passo 1 — Instalar Node.js LTS

Baixe e instale o **Node.js LTS v22+** (v20 funciona, porém em fim de vida):

```
https://nodejs.org/en/download
```

Verificar versão instalada:

```
node -v
```

### Passo 2 — Instalar Claude Code CLI

```
npm install -g @anthropic-ai/claude-code
```

Iniciar:

```
claude
```

### Passo 3 — Instalar os Agents

**Opção A — Todos de uma vez (terminal):**

```bash
cd /caminho/dos/agents
mkdir -p ~/.claude/agents
for z in *.zip; do
  unzip -o -j "$z" "*.md" -d ~/.claude/agents/ -x "COMO-INSTALAR.md"
done
```

**Opção B — Individual:**

1. Baixe o zip do agente desejado (ex: `01-apuracao-simples-nacional.zip`)
2. Descompacte — dentro tem o `.md` do agente
3. Copie para `~/.claude/agents/` (global) ou `.claude/agents/` (por projeto)
4. Reinicie o Claude Code com `/exit` e abra novamente

**Confirmação:**

```
/agents
```

---

## Interface DigIAna

**DigIAna** é a interface gráfica do 57 Agents — janela Electron frameless com os 57 agentes em cards visuais e terminal PTY real (PowerShell + Claude Code) integrado.

### Como iniciar

```cmd
cd interface
npm start
```

**Após o build** (`npm run build` na pasta `interface`), basta clicar no ícone gerado em `dist/` — nenhum terminal necessário.

Se o terminal não aparecer na primeira execução em uma máquina nova, compile o módulo nativo:

```cmd
cd interface
interface\rebuild-native.bat
npm start
```

### Funcionalidades

1. Janela frameless 1280×800 px com 57 agentes organizados por categoria
2. Terminal PowerShell embutido (xterm.js + ConPTY)
3. Detecta o prompt do shell e envia `claude` automaticamente
4. Clicar em um card → abre painel de detalhe com descrição completa
5. Botão **Enviar ao terminal** pré-preenche o invokeCmd (sem Enter — usuário revisa e confirma)
6. Botão **Copiar comando** copia o invokeCmd para a área de transferência
7. Terminal flutuante arrastável e redimensionável

### Comportamento do terminal flutuante

| Ação | Como fazer |
|---|---|
| Abrir / fechar | Botão "Terminal" no header ou tecla `T` |
| Arrastar | Clique e arraste pela barra de título |
| Redimensionar | Alça no canto inferior direito |
| Minimizar | Botão `─` na barra do terminal |
| Fechar (✕) | Oculta o terminal; próximo card enviado executa `cls` primeiro |
| Copiar | `Ctrl+C` com seleção ativa |
| Colar | `Ctrl+V` ou clique direito |
| Interromper processo | `Ctrl+C` sem seleção |

### Estrutura dos arquivos

```
interface/
├── main.js              — Electron main process; spawna o PTY e cria a janela
├── preload.js           — Ponte IPC contextBridge (window.terminal, window.agents)
├── app.js               — Renderer: cards, scroll, interação com terminal
├── agents-data.js       — Dados dos 57 agentes (nome, categoria, invokeCmd)
├── index.html           — HTML/CSS da interface
├── rebuild-native.bat   — Compila node-pty para Windows (VS BuildTools)
└── package.json         — Electron v28, xterm v5, node-pty
```

### Pré-requisitos para compilação nativa

Necessários apenas se `rebuild-native.bat` precisar ser executado:

| Componente | Versão testada |
|---|---|
| Node.js | v20.x ou v22.x |
| VS BuildTools | v145 — MSVC 14.50+ |
| Windows SDK | 10.0.26100.0 |
| Electron | v28.3.3 (ABI 119) |

Download VS BuildTools: `https://aka.ms/vs/18/release/vs_buildtools.exe`
Marcar: **Desktop development with C++** + **Windows 11 SDK 10.0.26100**

### Diagnóstico

O arquivo `57agents-debug.log` (raiz do projeto) registra toda a execução do PTY.

Indicadores de funcionamento correto:

```
[PTY] Iniciando shell: powershell.exe
[PTY] Shell PID: XXXX
[PTY] Prompt detectado! Padrão: "PS C:\..."
[PTY] claude enviado ao PTY
```

### Detalhes técnicos — node-pty no Windows

O `@homebridge/node-pty-prebuilt-multiarch` v0.11.14 não possui prebuild Windows. O `rebuild-native.bat` aplica 4 ajustes automaticamente:

1. **Path com espaço** — source copiado para `C:\57tmp-pty-build` antes de compilar
2. **VS BuildTools não detectado** — usa `@electron/node-gyp` que suporta VS2026
3. **GetCommitHash.bat** — patch em `deps/winpty/src/winpty.gyp` com prefixo `.\`
4. **DelayImp.lib** — paths de libs MSVC e Windows SDK adicionados em `binding.gyp`

---

## Como Usar os Agents

- **Automático** — "preciso apurar o DAS de abril/2026 desse cliente" → Claude delega automaticamente para `apuracao-simples-nacional`
- **Manual** — "use o agente `holerite` para gerar o holerite de João de maio/2026"
- **Em pipeline** — combine agents em sequência para processos completos (ver seção Pipelines)

---

## Catálogo de Agents

### Categoria 1 — Apuração & Tributário

#### 01 — DAS Simples Nacional · `apuracao-simples-nacional`

| Campo | Detalhe |
|---|---|
| **O que faz** | Apuração mensal do DAS para empresas optantes pelo Simples Nacional. Calcula receitas segregadas por anexo (I a V), alíquota efetiva, RBT12 e fator R. |
| **Ative quando** | Enviar faturamento de empresa optante; mencionar PGDAS-D, alíquota efetiva, RBT12, Anexo I-V, fator R ou sublimite estadual. |
| **NÃO use para** | MEI — use **28** |
| **Entrega** | Tabela de receitas segregadas + cálculo Python passo a passo + alíquota efetiva justificada + DAS por anexo. |
| **Invocar** | `"use o agente apuracao-simples-nacional para apurar o DAS de [mês/ano] do cliente [nome]"` |

#### 02 — ICMS / ISS · `icms-iss`

| Campo | Detalhe |
|---|---|
| **O que faz** | Apuração de ICMS e ISS. Cobre alíquotas internas/interestaduais, ICMS-ST, DIFAL, retenção ISS pelo tomador e municipalidade competente. |
| **Ative quando** | Apurar ICMS de operação interestadual ou interna; mencionar ICMS-ST, MVA, DIFAL; enquadrar serviço na LC 116. |
| **NÃO use para** | PIS/COFINS — use **03** · SPED Fiscal — use **06** |
| **Entrega** | Cálculo Python + base de cálculo + alíquota correta + DARF/DAS/DARM gerado. |
| **Invocar** | `"use o agente icms-iss para calcular o ICMS da NF [número] operação interestadual de [UF] para [UF]"` |

#### 03 — PIS / COFINS · `pis-cofins`

| Campo | Detalhe |
|---|---|
| **O que faz** | Apuração de PIS e COFINS nos regimes cumulativo e não-cumulativo. Cobre monofásico e exclusão do ICMS da base (Tema 69 STF). |
| **Ative quando** | Apurar PIS/COFINS mensal; mencionar regime cumulativo, não-cumulativo, monofásico, exclusão ICMS da base, créditos. |
| **NÃO use para** | EFD-Contribuições em si — use **32** · Recuperação créditos extemporâneos — use **45** |
| **Entrega** | Cálculo Python + base com exclusões corretas + créditos identificados + DARF gerado. |
| **Invocar** | `"use o agente pis-cofins para apurar PIS/COFINS de [mês/ano] do cliente [nome] no regime [cumulativo/não-cumulativo]"` |

#### 04 — IRPJ / CSLL · `irpj-csll`

| Campo | Detalhe |
|---|---|
| **O que faz** | Apuração de IRPJ e CSLL nos regimes Lucro Presumido, Lucro Real e Lucro Arbitrado. Cobre apuração trimestral × anual com estimativa. |
| **Ative quando** | Apurar IRPJ/CSLL mensais ou trimestrais; mencionar Lucro Presumido, Lucro Real, LALUR, balancete de redução. |
| **NÃO use para** | Análise estratégica de regime — use **44** · Escrituração ECD/ECF — use **07** |
| **Entrega** | Cálculo Python + base de cálculo + alíquotas com adicional + DARFs IRPJ e CSLL. |
| **Invocar** | `"use o agente irpj-csll para apurar IRPJ e CSLL do trimestre [tri/ano] da empresa [nome] no Lucro Presumido"` |

#### 05 — Conferência de Guia · `conferencia-guia`

| Campo | Detalhe |
|---|---|
| **O que faz** | Conferência cruzada de todas as guias de tributos antes do envio ao cliente. Compara guias contra declarações e apurações. |
| **Ative quando** | Gerou guias e quer revisão antes de enviar; mencionar conferência, batimento, divergência, erro em guia. |
| **NÃO use para** | Apurar tributo — use **01**, **02**, **03** ou **04** |
| **Entrega** | Tabela de conferência cruzada + divergências + checklist + plano de correção (DARF retificador). |
| **Invocar** | `"use o agente conferencia-guia para revisar todas as guias de [mês/ano] do cliente [nome] antes do envio"` |

---

### Categoria 2 — Obrigações Acessórias

#### 06 — SPED Fiscal · `sped-fiscal`

| Campo | Detalhe |
|---|---|
| **O que faz** | Geração e validação do arquivo EFD-ICMS-IPI. Escrituração de NFs, apuração de ICMS e IPI. Registros C, D, E. |
| **Ative quando** | Gerar e validar arquivo SPED Fiscal mensal; erro no PVA e precisa de diagnóstico. |
| **Entrega** | Estrutura do arquivo com blocos preenchidos + plano de correção + checklist PVA. |
| **Invocar** | `"use o agente sped-fiscal para montar o arquivo EFD-ICMS-IPI de [mês/ano]"` |

#### 07 — ECF / ECD · `ecf-ecd`

| Campo | Detalhe |
|---|---|
| **O que faz** | ECD: livro Diário/Razão digital. ECF: apuração de IRPJ/CSLL com LALUR/LACS digital. |
| **Ative quando** | Gerar e transmitir ECD ou ECF anuais; erro no PVA-ECD ou PVA-ECF. |
| **Entrega** | Estrutura ECD e ECF preenchida + plano de contas referencial + checklist. |
| **Invocar** | `"use o agente ecf-ecd para gerar a ECD do exercício [ano]"` |

#### 08 — DCTFWeb · `dctfweb`

| Campo | Detalhe |
|---|---|
| **O que faz** | DCTFWeb mensal — confessa débitos federais, vincula DARFs pagos e PER/DCOMP. |
| **Ative quando** | Fechou eSocial S-1299 e Reinf R-2099/R-4099; hora de transmitir. |
| **Entrega** | Tabela de débitos esperados × confessados + recibo de transmissão. |
| **Invocar** | `"use o agente dctfweb para gerar a DCTFWeb de [mês/ano]"` |

#### 09 — EFD-Reinf · `efd-reinf`

| Campo | Detalhe |
|---|---|
| **O que faz** | EFD-Reinf — transmissão dos eventos R-2000 e R-4000 (retenções INSS e IRRF). |
| **Ative quando** | Fechar competência mensal para gerar a DCTFWeb. |
| **Entrega** | Sequência de eventos transmitidos + recibo de transmissão. |
| **Invocar** | `"use o agente efd-reinf para enviar os eventos da competência [mês/ano]"` |

#### 10 — eSocial · `esocial`

| Campo | Detalhe |
|---|---|
| **O que faz** | eSocial — todos os eventos: iniciais, não-periódicos e periódicos (S-1200, S-2200, etc.). |
| **Ative quando** | Transmitir eventos eSocial; rejeição de evento e precisa de diagnóstico. |
| **Entrega** | Cronograma de envios + diagnóstico de rejeições + checklist. |
| **Invocar** | `"use o agente esocial para montar o cronograma de envios de [mês/ano]"` |

---

### Categoria 3 — Folha & Departamento Pessoal

#### 11 — Holerite · `holerite`

| Campo | Detalhe |
|---|---|
| **O que faz** | Emissão e conferência de holerite completo — proventos e descontos (INSS, IRRF, VT). |
| **Ative quando** | Emitir holerite mensal; conferir holerite gerado por sistema. |
| **Entrega** | Holerite pronto + cálculo Python passo a passo + checklist. |
| **Invocar** | `"use o agente holerite para gerar o holerite de [mês/ano]"` |

#### 12 — Férias e 13º Salário · `ferias-13-salario`

| Campo | Detalhe |
|---|---|
| **O que faz** | Cálculo de férias (período aquisitivo, abono pecuniário) e 13º (1ª e 2ª parcelas). |
| **Ative quando** | Calcular férias ou 13º salário; médias variáveis de 12 meses. |
| **Entrega** | Cálculo Python + holerite específico + DARF IRRF 13º. |
| **Invocar** | `"use o agente ferias-13-salario para calcular as férias de [nome]"` |

#### 13 — Rescisão CLT · `rescisao-clt-calculo`

| Campo | Detalhe |
|---|---|
| **O que faz** | Cálculo financeiro completo de rescisão CLT por qualquer motivo (sem justa causa, acordo 484-A, pedido, etc.). |
| **Ative quando** | Precisar calcular o TRCT de qualquer funcionário. |
| **Entrega** | TRCT detalhado + cálculo Python + GRRF. |
| **Invocar** | `"use o agente rescisao-clt-calculo para calcular a rescisão de [nome]"` |

#### 14 — INSS / FGTS · `inss-fgts`

| Campo | Detalhe |
|---|---|
| **O que faz** | Apuração e recolhimento do INSS empresa e FGTS via FGTS Digital. |
| **Ative quando** | Apurar e recolher INSS e FGTS mensais; conferir cálculo do sistema. |
| **Entrega** | Cálculo Python + GPS + DAE FGTS + checklist eSocial. |
| **Invocar** | `"use o agente inss-fgts para apurar GPS e DAE de [mês/ano]"` |

#### 15 — Admissão · `admissao`

| Campo | Detalhe |
|---|---|
| **O que faz** | Admissão completa CLT — documentos, eSocial S-2200, contrato, CTPS Digital. |
| **Ative quando** | Vai admitir um novo funcionário; precisa de checklist e prazos. |
| **Entrega** | Checklist completo + minuta de contrato + cronograma D-7/D-1/D-0. |
| **Invocar** | `"use o agente admissao para gerar o checklist para admitir [nome]"` |

---

### Categoria 4 — Conciliação & Financeiro

#### 16 — Conciliação Bancária · `conciliacao-bancaria`

| Campo | Detalhe |
|---|---|
| **O que faz** | Match item a item entre extrato bancário (OFX/CSV) e razão contábil. |
| **Ative quando** | Fecha o mês (pré-balancete); cliente novo com saldos divergentes. |
| **Entrega** | Espelho de conciliação + lista de pendências + lançamentos a fazer. |
| **Invocar** | `"use o agente conciliacao-bancaria para conciliar o banco [nome]"` |

#### 17 — Cobrança de Honorários · `cobranca-honorarios`

| Campo | Detalhe |
|---|---|
| **O que faz** | Cobrança de honorários atrasados — régua escalonada de 5 etapas. |
| **Ative quando** | Cliente atrasou pagamento; precisa de régua de cobrança. |
| **Entrega** | Régua em 5 etapas + 5 modelos prontos + estratégia de protesto. |
| **Invocar** | `"use o agente cobranca-honorarios para montar a régua do cliente [nome]"` |

#### 18 — DRE Gerencial · `dre-gerencial`

| Campo | Detalhe |
|---|---|
| **O que faz** | DRE gerencial com margem de contribuição, ponto de equilíbrio e KPIs. |
| **Ative quando** | Tomar decisão de preço ou mix de produtos; mencionar MC%, PE. |
| **Entrega** | DRE gerencial estruturada + análise de sensibilidade. |
| **Invocar** | `"use o agente dre-gerencial para montar a DRE de [mês/ano]"` |

#### 19 — Fluxo de Caixa Projetado · `fluxo-caixa-projetado`

| Campo | Detalhe |
|---|---|
| **O que faz** | Fluxo de caixa realizado e projetado com 3 cenários (otimista/realista/pessimista). |
| **Ative quando** | Cliente com sazonalidade; necessidade de capital de giro. |
| **Entrega** | Planilha CSV semanal/mensal com 3 cenários e alertas de déficit. |
| **Invocar** | `"use o agente fluxo-caixa-projetado para projetar o fluxo de [mês]"` |

---

### Categoria 5 — Atendimento ao Cliente

#### 20 — Triagem WhatsApp · `triagem-whatsapp`

| Campo | Detalhe |
|---|---|
| **O que faz** | Classifica mensagens por tipo, área e urgência. Gera respostas FAQ. |
| **Ative quando** | Lote de mensagens recebidas; precisa de régua de resposta automática. |
| **Entrega** | Tabela de triagem + 15 templates FAQ + protocolo de SLA. |
| **Invocar** | `"use o agente triagem-whatsapp para classificar as mensagens de hoje"` |

#### 21 — Documentos Pendentes · `documentos-pendentes`

| Campo | Detalhe |
|---|---|
| **O que faz** | Controle de documentos que o cliente precisa enviar (NFs, extratos, contratos). |
| **Ative quando** | Cobrar documentos para fechar o mês; risco de atrasar obrigação. |
| **Entrega** | Lista de pendências em CSV + régua de cobrança automática + cronograma reverso. |
| **Invocar** | `"use o agente documentos-pendentes para listar o que o cliente precisa enviar"` |

#### 22 — Onboarding Cliente · `onboarding-cliente`

| Campo | Detalhe |
|---|---|
| **O que faz** | Contrato, procuração e-CAC, termo LGPD, cadastro no software contábil. |
| **Ative quando** | Cliente novo assinou; precisa formalizar a entrada no escritório. |
| **Entrega** | Pacote completo (contrato + procuração + LGPD) + checklist operacional. |
| **Invocar** | `"use o agente onboarding-cliente para gerar o pacote de entrada de [nome]"` |

#### 23 — Follow-up Cliente · `follow-up-cliente`

| Campo | Detalhe |
|---|---|
| **O que faz** | Atualização proativa pós-fechamento, reunião trimestral, gestão de churn. |
| **Ative quando** | Estruturar régua de comunicação; cliente VIP precisa de atenção especial. |
| **Entrega** | Régua de comunicação + 5 modelos prontos + métricas NPS. |
| **Invocar** | `"use o agente follow-up-cliente para criar modelos de comunicação mensal"` |

---

### Categoria 6 — Operação Interna

#### 24 — Cadastro de NF · `cadastro-nf`

| Campo | Detalhe |
|---|---|
| **O que faz** | Classificação de notas fiscais (CFOP, CST, NCM) para escrituração. |
| **Ative quando** | Recebeu lote de NFs; divergência entre XML e PDF. |
| **Entrega** | Planilha de classificação + plano de correção de NFs problemáticas. |
| **Invocar** | `"use o agente cadastro-nf para classificar as NFs de entrada de [nome]"` |

#### 25 — Lembrete de Prazo · `lembrete-prazo`

| Campo | Detalhe |
|---|---|
| **O que faz** | Controle de prazos legais e declarações. Gera calendário ICS. |
| **Ative quando** | Montar calendário fiscal mensal ou anual para o cliente. |
| **Entrega** | Calendário em CSV/ICS + régua de avisos D-7/D-3/D-0. |
| **Invocar** | `"use o agente lembrete-prazo para gerar o calendário fiscal de [mês]"` |

#### 26 — Relatório Mensal · `relatorio-mensal`

| Campo | Detalhe |
|---|---|
| **O que faz** | Relatório executivo de 1 página com KPIs (receita, despesa, lucro). |
| **Ative quando** | Acabou o fechamento; enviar síntese de valor ao cliente VIP. |
| **Entrega** | Relatório de 1 página + tabela de KPIs + comentário do contador. |
| **Invocar** | `"use o agente relatorio-mensal para gerar o relatório de [mês/ano]"` |

#### 27 — Backup do Escritório · `backup-escritorio`

| Campo | Detalhe |
|---|---|
| **O que faz** | Política 3-2-1 e teste de restore mensal. Adequação LGPD. |
| **Ative quando** | Estruturar a política de backup; incidente de segurança ocorrido. |
| **Entrega** | Política escrita + script de teste mensal + plano de resposta em 48h. |
| **Invocar** | `"use o agente backup-escritorio para criar a política de backup"` |

---

### Categoria 7 — Especializações

#### 28 — Apuração MEI · `apuracao-mei`

| Campo | Detalhe |
|---|---|
| **O que faz** | DAS-MEI mensal, DASN-SIMEI anual e controle do limite de faturamento (R$ 81k). |
| **Ative quando** | Cliente é MEI; faturamento acumulado próximo a R$ 65k. |
| **Invocar** | `"use o agente apuracao-mei para gerar o DAS-MEI de [mês]"` |

#### 29 — Cálculo IPI · `calculo-ipi`

| Campo | Detalhe |
|---|---|
| **O que faz** | Apuração de IPI para indústria e equiparados. Cobre regimes de suspensão e Bloco K. |
| **Invocar** | `"use o agente calculo-ipi para apurar o IPI de [mês]"` |

#### 30 — IRRF na Folha · `calculo-irrf-folha`

| Campo | Detalhe |
|---|---|
| **O que faz** | IRRF sobre CLT, pró-labore e RPA. Aplica tabela progressiva 2026. |
| **Invocar** | `"use o agente calculo-irrf-folha para calcular o IRRF de [nome]"` |

#### 31 — Retenções (Tomador) · `retencoes-tributarias-tomador`

| Campo | Detalhe |
|---|---|
| **O que faz** | Retenções (IRRF, CSRF, INSS, ISS) que o tomador deve fazer ao pagar a NF. |
| **Invocar** | `"use o agente retencoes-tributarias-tomador para calcular as retenções da NF [número]"` |

#### 32 — EFD-Contribuições · `efd-contribuicoes`

| Campo | Detalhe |
|---|---|
| **O que faz** | Escrituração de PIS/COFINS por CST, Bloco M e F. Concilia com DCTFWeb. |
| **Invocar** | `"use o agente efd-contribuicoes para montar a EFD de [mês]"` |

#### 33 — DIMOB · `dimob`

| Campo | Detalhe |
|---|---|
| **O que faz** | Declaração para imobiliárias e construtoras sobre locação e venda. |
| **Invocar** | `"use o agente dimob para gerar a DIMOB de [ano]"` |

#### 34 — DMED · `dmed`

| Campo | Detalhe |
|---|---|
| **O que faz** | Declaração para prestadores de serviços médicos e operadoras de saúde. |
| **Invocar** | `"use o agente dmed para gerar a DMED de [ano]"` |

#### 35 — Folha de Pagamento Mensal · `folha-pagamento-mensal`

| Campo | Detalhe |
|---|---|
| **O que faz** | Processamento completo da folha CLT com adicionais e descontos. |
| **Invocar** | `"use o agente folha-pagamento-mensal para processar a folha de [mês]"` |

#### 36 — Plano de Contas CPC · `plano-contas-cpc`

| Campo | Detalhe |
|---|---|
| **O que faz** | Estruturação com mapeamento referencial fiscal (Anexo III IN RFB 2.003) e aderência aos CPCs. |
| **Invocar** | `"use o agente plano-contas-cpc para criar o plano de contas de [nome]"` |

#### 37 — Lançamentos Contábeis Padrão · `lancamentos-contabeis-padrao`

| Campo | Detalhe |
|---|---|
| **O que faz** | Catálogo operacional de lançamentos D/C para operações cotidianas. |
| **Invocar** | `"use o agente lancamentos-contabeis-padrao para mostrar lançamentos de [operação]"` |

#### 38 — Conciliação Cartões · `conciliacao-cartoes-credenciadora`

| Campo | Detalhe |
|---|---|
| **O que faz** | Bate vendas via cartão com os repasses da credenciadora (MDR, antecipação, chargebacks). |
| **Invocar** | `"use o agente conciliacao-cartoes-credenciadora para conciliar cartões de [mês]"` |

#### 39 — Conciliação Fornecedores · `conciliacao-fornecedores`

| Campo | Detalhe |
|---|---|
| **O que faz** | Match NFs recebidas × pagamentos × histórico de contas a pagar. |
| **Invocar** | `"use o agente conciliacao-fornecedores para conciliar fornecedores de [mês]"` |

#### 40 — Conciliação Clientes · `conciliacao-clientes`

| Campo | Detalhe |
|---|---|
| **O que faz** | Match NFs emitidas × recebimentos. Monta aging de contas a receber. |
| **Invocar** | `"use o agente conciliacao-clientes para montar o aging de clientes de [mês]"` |

#### 41 — Fechamento Mensal · `fechamento-mensal`

| Campo | Detalhe |
|---|---|
| **O que faz** | Roteiro completo de fechamento contábil em até 5 dias úteis. |
| **Invocar** | `"use o agente fechamento-mensal para guiar o fechamento de [mês]"` |

#### 42 — Balancete — Análise · `balancete-analise`

| Campo | Detalhe |
|---|---|
| **O que faz** | Verifica integridade, coerência e calcula indicadores financeiros (liquidez, ROE, PMR). |
| **Invocar** | `"use o agente balancete-analise para revisar o balancete de [mês]"` |

#### 43 — Ativo Imobilizado / Depreciação · `ativo-imobilizado-depreciacao`

| Campo | Detalhe |
|---|---|
| **O que faz** | Gestão do imobilizado, cálculo de depreciação (linear, unidades) e teste de impairment. |
| **Invocar** | `"use o agente ativo-imobilizado-depreciacao para cadastrar bem [descrição]"` |

#### 44 — Análise de Regime Tributário · `analise-tributaria-regime`

| Campo | Detalhe |
|---|---|
| **O que faz** | Comparativo Simples × Lucro Presumido × Lucro Real com projeção 12 meses e sensibilidade ±20%. |
| **Invocar** | `"use o agente analise-tributaria-regime para comparar os regimes de [nome]"` |

#### 45 — Recuperação Créditos PIS/COFINS · `recuperacao-creditos-pis-cofins`

| Campo | Detalhe |
|---|---|
| **O que faz** | Recuperação retroativa dos últimos 5 anos (Tema 69 STF — exclusão ICMS; Tema 779 STJ — insumos amplos). |
| **Invocar** | `"use o agente recuperacao-creditos-pis-cofins para levantar créditos dos últimos 5 anos"` |

#### 46 — Revisão Fiscal / Cruzamento SPED · `revisao-fiscal-cruzamento-sped`

| Campo | Detalhe |
|---|---|
| **O que faz** | Cruzamento entre todas as obrigações (ECD/ECF/EFD/eSocial/DCTFWeb) para identificar divergências. |
| **Invocar** | `"use o agente revisao-fiscal-cruzamento-sped para cruzar obrigações de [ano]"` |

#### 47 — Malha Fina PF · `malha-fina-pf-diagnostico`

| Campo | Detalhe |
|---|---|
| **O que faz** | Diagnóstico de pendências de IRPF no e-CAC e preparação de retificadora ou defesa. |
| **Invocar** | `"use o agente malha-fina-pf-diagnostico para analisar pendência do e-CAC de [nome]"` |

#### 48 — Malha Fina PJ · `malha-fina-pj-diagnostico`

| Campo | Detalhe |
|---|---|
| **O que faz** | Diagnóstico de intimações, inconsistências e autos de infração na malha PJ. |
| **Invocar** | `"use o agente malha-fina-pj-diagnostico para analisar intimação recebida"` |

#### 49 — Due Diligence Contábil · `due-diligence-contabil`

| Campo | Detalhe |
|---|---|
| **O que faz** | Identificação de passivos ocultos, contingências e ajuste de EBITDA pré-M&A. |
| **Invocar** | `"use o agente due-diligence-contabil para iniciar DD da empresa [nome]"` |

#### 50 — Valuation PME · `valuation-pme`

| Campo | Detalhe |
|---|---|
| **O que faz** | Avaliação por DCF, múltiplos comparáveis (EV/EBITDA) e patrimonial. |
| **Invocar** | `"use o agente valuation-pme para avaliar a empresa [nome]"` |

#### 51 — IRPF — Declaração Completa · `irpf-declaracao-completa`

| Campo | Detalhe |
|---|---|
| **O que faz** | Declaração anual com múltiplas fontes, bens, direitos e dívidas. Cobre Simples × Completa. |
| **Invocar** | `"use o agente irpf-declaracao-completa para preparar IRPF de [nome]"` |

#### 52 — Abertura de Empresa / CNPJ · `abertura-empresa-cnpj`

| Campo | Detalhe |
|---|---|
| **O que faz** | Processo REDESIM completo — viabilidade, DBE, contrato social, opção tributária. |
| **Invocar** | `"use o agente abertura-empresa-cnpj para abrir uma [LTDA/SLU] para [nome]"` |

#### 53 — Alteração Contratual · `alteracao-contratual`

| Campo | Detalhe |
|---|---|
| **O que faz** | Mudança de sócios, capital, endereço ou objeto via REDESIM. |
| **Invocar** | `"use o agente alteracao-contratual para redigir alteração de [tipo]"` |

#### 54 — Encerramento / Baixa · `encerramento-empresa-baixa`

| Campo | Detalhe |
|---|---|
| **O que faz** | Baixa regular ou com débitos, distrato e declarações fracionadas. |
| **Invocar** | `"use o agente encerramento-empresa-baixa para estruturar baixa de [nome]"` |

#### 55 — Parcelamento Receita Federal · `parcelamento-receita-federal`

| Campo | Detalhe |
|---|---|
| **O que faz** | Simulação e adesão a parcelamentos federais e transações tributárias (Lei 13.988/2020). |
| **Invocar** | `"use o agente parcelamento-receita-federal para simular parcelamento de [valor]"` |

#### 56 — Resposta a Fiscalização · `resposta-fiscalizacao-intimacao`

| Campo | Detalhe |
|---|---|
| **O que faz** | Resposta a intimações e autos de infração com fundamentação legal e prazos. |
| **Invocar** | `"use o agente resposta-fiscalizacao-intimacao para responder auto de [data]"` |

#### 57 — Reforma Tributária — CBS/IBS · `reforma-tributaria-cbs-ibs`

| Campo | Detalhe |
|---|---|
| **O que faz** | Simulação de impacto da EC 132/2023 (LC 214/2025). Split payment, cashback, transição 2026–2032. |
| **Invocar** | `"use o agente reforma-tributaria-cbs-ibs para simular impacto no cliente [nome]"` |

---

## Pipelines Recomendados

> **O que são Pipelines?** Sequências de agents que devem ser usados em ordem para garantir que o dado flua corretamente entre etapas — evitando erros de integridade e retificações custosas.

| Processo | Sequência |
|---|---|
| Fechamento mensal completo | 24 → 16 → 38 → 39 → 40 → 41 → 42 → 26 |
| Folha CLT mensal | 35 → 11 → 14 → 10 → 09 → 08 |
| Abertura de empresa | 52 → 36 → 22 |
| Fiscalização recebida | 48 → 46 → 56 |
| Onboarding cliente novo | 22 → 36 → 25 |
| MEI próximo do limite (migração) | 28 → 44 → 52 |
| Admissão de funcionário CLT | 15 → 10 → 11 |
| Rescisão de funcionário CLT | 13 → 10 → 14 |
| Apuração mensal Lucro Presumido | 03 → 04 → 05 → 08 → 09 |
| Encerramento de empresa (baixa) | 54 → 07 → 08 |
| Planejamento tributário anual | 42 → 44 → 26 |
| IRPF declaração anual (PF) | 51 → 47 |
| Regularização de dívida federal | 46 → 48 → 55 |
| Indústria / apuração IPI | 29 → 06 → 46 |
| Venda / M&A de empresa | 49 → 50 → 53 |
| 13º Salário (1ª e 2ª parcela) | 12 → 11 → 10 |
| Recuperação créditos PIS/COFINS | 45 → 08 |

---

## Notas Técnicas

### Tokens e agents no Claude Code

Os 57 agents ficam instalados globalmente em `%USERPROFILE%\.claude\agents\`.
A cada nova conversa no Claude Code eles são carregados no contexto — consumindo **~16.5k tokens** (~8,3% dos 200k disponíveis).

| Dimensão | Comportamento |
|---|---|
| Ocupação do contexto (200k) | Sempre consome 16.5k em toda conversa nova |
| Custo de processamento (API) | Pode ser reduzido pelo **prompt caching** da Anthropic |
| Fechar e reabrir o projeto | Nova conversa = recarrega tudo do zero |

> **Prompt caching:** se o conteúdo dos agents não mudou desde a última chamada recente, a Anthropic reutiliza o cache e cobra menos — mas os tokens **sempre** ocupam o contexto.

Como o projeto usa Claude Code exclusivamente para contabilidade, os 16.5k tokens são sempre relevantes — não há desperdício.

### Instalação / atualização dos agents

```
Downloads\Agentes\agents\*.md  →  copiar para  →  %USERPROFILE%\.claude\agents\
```

Os cards da interface enviam o comando ao terminal embutido; o Claude Code processa usando o agent instalado correspondente.

### Barra superior de agents.html

```
┌──────────────────────────────────────────────────────────────────┐  ← topo fixo
│  Atualizado: 15/05/2026 10:33          ☽ Tema        🖨 PDF     │
├──────────────────────────────────────────────────────────────────┤
│  TOC lateral    │  conteúdo de agentes.md renderizado            │
```

| Elemento | Como funciona |
|---|---|
| **Atualizado: DD/MM/AAAA HH:MM** | Lê `fs.statSync('agentes.md').mtime` — data/hora real do último save |
| **☽ Tema** | Alterna dark ↔ light; ícone muda (lua → sol); preferência em `localStorage` |
| **🖨 PDF** | `window.print()` — barra e TOC ocultam no print; fundo vai a branco |

### Sincronização agentes.md → agents.html

O `generate-agents-html.js` converte este arquivo em `agents.html` com TOC lateral navegável.

**Camada 1 — VS Code (watcher automático):**
O arquivo `.vscode/tasks.json` tem uma task `"runOn": "folderOpen"` que inicia `node generate-agents-html.js --watch` ao abrir o projeto. Na primeira vez o VS Code pergunta — responda **Allow**. Após isso, salvar este arquivo regenera `agents.html` em ~150ms automaticamente.

**Camada 2 — Electron (watcher embutido):**
Quando o app DigIAna está aberto, `main.js` também inicia o watcher via `require('../generate-agents-html.js')`.

**CLI (fallback):**

```
npm run agents        # gera agents.html uma vez
npm run agents:watch  # inicia o watcher no terminal
```

---

## Plano da Interface Desktop

> **Regra inviolável:** nenhum dos 57 agentes será reprogramado ou modificado durante a construção desta interface. A interface é camada de apresentação apenas.

### Layout

```
┌────────────────────────────────────────────────────────────────┐
│  57 Agents Contabilidade                    ● 57 carregados   │
├──────────┬─────────────────────────────────────────────────────┤
│ SIDEBAR  │  GRID DE CARDS (7 categorias)                      │
│          │                                                     │
│ [Todos]  │  ── Apuração & Tributário ──────────────────────   │
│ Cat 1 ●  │  [01 DAS Simples] [02 ICMS/ISS] [03 PIS/COFINS]   │
│ Cat 2    │  [04 IRPJ/CSLL]   [05 Conf.Guia]                  │
│ ...      │                                                     │
│ [Busca]  │                                                     │
├──────────┴─────────────────────────────────────────────────────┤
│  TERMINAL FLUTUANTE (xterm.js + ConPTY)                        │
│  $ claude                                                      │
└────────────────────────────────────────────────────────────────┘
```

Ao clicar num card, painel deslizante da direita (420px) exibe detalhe completo do agente.

### Etapas de Construção

| Etapa | Descrição | Status |
|---|---|---|
| 1 | agents-data.js — parse de como_usar.md | ✅ Concluída |
| 2 | package.json + main.js + preload.js (Electron) | ✅ Concluída |
| 3 | index.html — estrutura completa | ✅ Concluída |
| 4 | styles.css — dark theme + cores por categoria | ✅ Concluída |
| 5 | app.js — lógica completa + terminal | ✅ Concluída |
| 6 | Pipelines recomendados (visual) | Pendente |

### Regras de Construção

1. `como_usar.md` e todos os `.md` de agentes são **somente leitura**
2. Sem frameworks CSS (sem Bootstrap, sem Tailwind) — CSS puro
3. Sem frameworks JS (sem React, sem Vue) — JS puro
4. Electron é a única dependência npm
5. Terminal embutido abre com `claude` automaticamente ao iniciar

### Cores por Categoria

| Cat | Nome | Cor |
|---|---|---|
| 1 | Apuração & Tributário | `#f78166` vermelho |
| 2 | Obrigações Acessórias | `#d2a8ff` lilás |
| 3 | Folha & DP | `#79c0ff` azul claro |
| 4 | Conciliação & Financeiro | `#56d364` verde |
| 5 | Atendimento ao Cliente | `#ffa657` laranja |
| 6 | Operação Interna | `#e3b341` amarelo |
| 7 | Especializações | `#8b949e` cinza |

---

## Avisos Legais

- Os agents refletem CTN, RIR/2018, IN RFB, LC 87/96, LC 116/2003, LC 123/2006, LC 190/2022, EC 132/2023 (Reforma Tributária), Resolução CFC 1.546/2024 e legislação especial vigentes em 2026.
- Outputs gerados são **rascunhos** — o contador responsável deve revisar e assumir a responsabilidade técnica (CRC, Resolução CFC 1.546/2024).
- Templates e exemplos usam dados fictícios.
- Uso permitido para clientes ASV Digital / Bravy. Não redistribuir sem autorização.
