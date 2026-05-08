# Como Usar os 57 Agents Contabilidade

Referência completa de todos os agentes — o que cada um faz, quando acionar, o que NÃO fazer com ele e o que ele entrega.

**Como invocar qualquer agente:**
- Automático: descreva a tarefa — o agente certo ativa sozinho quando o contexto bate.
- Manual: `"use o agente <slug> para <tarefa>"`
- O slug é o nome técnico listado em cada seção abaixo.

---

## CATEGORIA 1 — APURAÇÃO & TRIBUTÁRIO (01–05)

---

### 01 — DAS Simples Nacional
**Slug:** `apuracao-simples-nacional`
**O que faz:** Apuração mensal do DAS para empresas optantes pelo Simples Nacional. Calcula receitas segregadas por anexo (I a V), aplica alíquota efetiva, considera RBT12 e fator R.
**Ative quando:**
- Enviar faturamento de empresa optante para gerar o DAS
- Mencionar PGDAS-D, alíquota efetiva, RBT12, Anexo I-V, fator R ou sublimite estadual
- Pedir conferência de DAS gerado pelo sistema
- Suspeitar de erro de classificação de atividade no Simples

**NÃO use para:** MEI (use `28-apuracao-mei`)
**Entrega:** Tabela de receitas segregadas + cálculo passo a passo em Python + alíquota efetiva justificada + DAS por anexo + memória em CSV + checklist de validação contra PGDAS-D
**Invocar:** `"use o agente apuracao-simples-nacional para apurar o DAS de [mês/ano] do cliente [nome]"`

---

### 02 — ICMS / ISS
**Slug:** `icms-iss`
**O que faz:** Apuração de ICMS (LC 87/96 — Lei Kandir; legislação estadual de cada UF) e ISS (LC 116/2003; lista de serviços; legislação municipal). Cobre alíquotas internas/interestaduais, ICMS-ST (MVA, antecipação, ressarcimento), DIFAL (LC 190/2022), retenção ISS pelo tomador e municipalidade competente.
**Ative quando:**
- Apurar ICMS de operação interestadual ou interna
- Mencionar ICMS-ST, MVA, DIFAL, alíquota interestadual, substituição tributária, GIA, GIA-ST
- Enquadrar serviço na lista da LC 116 e calcular ISS
- Recebeu NF e quer saber se ISS é devido e onde
- Dúvida sobre retenção ISS pelo tomador

**NÃO use para:** PIS/COFINS (use `03`) · SPED Fiscal (use `06`)
**Entrega:** Cálculo Python passo a passo + base de cálculo + alíquota correta + DARF/DAS/DARM gerado + checklist de conferência + alerta para ST e DIFAL se aplicável
**Invocar:** `"use o agente icms-iss para calcular o ICMS da NF [número] operação interestadual de [UF] para [UF]"`

---

### 03 — PIS / COFINS
**Slug:** `pis-cofins`
**O que faz:** Apuração de PIS e COFINS nos regimes cumulativo (0,65% + 3%) e não-cumulativo (1,65% + 7,6%). Cobre monofásico (combustíveis, medicamentos, bebidas), exclusão do ICMS da base (Tema 69 STF — RE 574.706, modulação 15/03/2017) e créditos sobre insumos (Tema 779 STJ — essencialidade e relevância).
**Ative quando:**
- Apurar PIS/COFINS mensal
- Mencionar regime cumulativo, não-cumulativo, monofásico, exclusão ICMS da base, créditos, EFD-Contribuições
- Verificar se empresa optante pelo Lucro Real tem direito a crédito
- Dúvida sobre crédito de insumo

**NÃO use para:** EFD-Contribuições em si (use `32`) · Recuperação de créditos extemporâneos (use `45`)
**Entrega:** Cálculo Python + base com exclusões corretas (Tema 69) + créditos identificados (não-cumulativo) + DARF gerado + checklist + alerta de regime especial
**Invocar:** `"use o agente pis-cofins para apurar PIS/COFINS de [mês/ano] do cliente [nome] no regime [cumulativo/não-cumulativo]"`

---

### 04 — IRPJ / CSLL
**Slug:** `irpj-csll`
**O que faz:** Apuração de IRPJ (Lei 9.430/96 + RIR/2018) e CSLL (Lei 7.689/88) nos regimes Lucro Presumido (15% + adicional 10% sobre excedente de R$ 20k/mês), Lucro Real (ajustes LALUR) e Lucro Arbitrado. Cobre apuração trimestral × anual com estimativa e balancete de redução/suspensão.
**Ative quando:**
- Apurar IRPJ e CSLL mensais ou trimestrais
- Mencionar Lucro Presumido, Lucro Real, LALUR, balancete de redução, estimativa, adições/exclusões, prejuízo fiscal
- Dúvida sobre adicional de IRPJ (10% sobre excedente)

**NÃO use para:** Análise estratégica de regime (use `44`) · Escrituração ECD/ECF (use `07`)
**Entrega:** Cálculo Python + base de cálculo + alíquotas com adicional + DARFs IRPJ e CSLL + estimativa mensal se Lucro Real anual + checklist + alerta sobre prejuízo fiscal e compensação
**Invocar:** `"use o agente irpj-csll para apurar IRPJ e CSLL do trimestre [tri/ano] da empresa [nome] no Lucro Presumido"`

---

### 05 — Conferência de Guia
**Slug:** `conferencia-guia`
**O que faz:** Conferência cruzada de todas as guias de tributos antes do envio ao cliente. Compara DAS × PGDAS-D; DARF IRPJ/CSLL × DCTFWeb; DARF PIS/COFINS × EFD-Contribuições; GPS INSS × DCTFWeb; DAE FGTS; GIA ICMS × SPED Fiscal; DAM ISS × NFS-e municipal; DARF IRRF × DCTFWeb. Detecta código errado, vencimento incorreto, valor divergente, período errado, CNPJ errado, ausência de juros/multa.
**Ative quando:**
- Gerou guias e quer revisão antes de enviar ao cliente
- Mencionar conferência, batimento, divergência, erro em guia, autorregularização
- Cliente reclamando de erro em pagamento
- Preparando fechamento mensal — quer auditar todas as guias do mês

**NÃO use para:** Apurar tributo (use `01`, `02`, `03` ou `04`)
**Entrega:** Tabela de conferência cruzada (apuração × guia × declaração) + divergências + checklist de itens conferidos + lista guias OK / guias com problema + plano de correção (DARF retificador) + Python validador de campos
**Invocar:** `"use o agente conferencia-guia para revisar todas as guias de [mês/ano] do cliente [nome] antes do envio"`

---

## CATEGORIA 2 — OBRIGAÇÕES ACESSÓRIAS (06–10)

---

### 06 — SPED Fiscal
**Slug:** `sped-fiscal`
**O que faz:** Geração e validação do arquivo EFD-ICMS-IPI (Convênio ICMS 143/2006). Escrituração de NFs de entrada e saída, apuração de ICMS e IPI. Registros C100/C170/C190 (NFs), D100 (CT-e), E100/E110 (apuração ICMS), E200/E220 (ICMS-ST), E520/E530 (IPI). Cobre validação no PVA, assinatura digital, transmissão e retificação.
**Ative quando:**
- Gerar e validar arquivo SPED Fiscal mensal
- Mencionar EFD, registros C100, blocos, PVA, validador SPED, apuração ICMS
- Erro no PVA e precisa de diagnóstico
- Precisa retificar SPED enviado

**NÃO use para:** EFD-Contribuições (use `32`)
**Entrega:** Estrutura do arquivo com blocos preenchidos + lista de pendências comuns + plano de correção por bloco + checklist PVA + cronograma de envio mensal + alertas sobre retificação (prazo 5 anos)
**Invocar:** `"use o agente sped-fiscal para montar o arquivo EFD-ICMS-IPI de [mês/ano] do cliente [nome]"`

---

### 07 — ECF / ECD
**Slug:** `ecf-ecd`
**O que faz:** ECD (Escrituração Contábil Digital — IN RFB 2.003/2021): livro Diário/Razão digital + balanço + DRE com plano de contas referencial. ECF (Escrituração Contábil Fiscal — IN RFB 2.004/2021): apuração de IRPJ/CSLL com LALUR/LACS digital. Cobre validação no PVA-ECD/ECF, hash, blocos J/K e retificação.
**Ative quando:**
- Gerar e transmitir ECD ou ECF anuais
- Mencionar escrituração contábil digital, J100, J150, K030, LALUR digital, plano de contas referencial
- Erro no PVA-ECD ou PVA-ECF
- Precisa retificar ECD/ECF de ano anterior

**NÃO use para:** SPED Fiscal (use `06`)
**Entrega:** Estrutura ECD e ECF com blocos preenchidos + plano de contas referencial mapeado + checklist de validação + cronograma de entrega (ECD: último dia útil junho · ECF: último dia útil julho)
**Invocar:** `"use o agente ecf-ecd para gerar a ECD do exercício [ano] da empresa [nome]"`

---

### 08 — DCTFWeb
**Slug:** `dctfweb`
**O que faz:** DCTFWeb mensal — confessa débitos federais (INSS CPP/RAT/Terceiros, INSS retido, IRRF folha, IRRF PF/PJ, CSRF, IRPJ/CSLL, PIS/COFINS, IPI), vincula DARFs pagos e PER/DCOMP, retifica quando há ajuste em eSocial ou Reinf.
**Ative quando:**
- Fechou eSocial S-1299 e Reinf R-2099/R-4099 — hora de transmitir a DCTFWeb
- Mencionar DCTFWeb mensal, 13º salário ou aferição
- Precisa incluir lançamentos manuais (IRPJ/CSLL/PIS/COFINS/IPI)
- Suspensão de débito por decisão judicial

**Entrega:** Tabela de débitos esperados × confessados + plano de retificação se divergente + DARFs por código de receita + recibo de transmissão
**Invocar:** `"use o agente dctfweb para gerar a DCTFWeb de [mês/ano] após o fechamento do eSocial e EFD-Reinf"`

---

### 09 — EFD-Reinf
**Slug:** `efd-reinf`
**O que faz:** EFD-Reinf — transmissão dos eventos: R-1000 (cadastro), R-2010 (retenção INSS 11% serviço tomado), R-2020 (idem prestador), R-2050/R-2055 (rural), R-2099 (fechamento periódico), R-4010/R-4020 (substitui DIRF a partir de 2024 — IRRF PF/PJ), R-4099 (fechamento).
**Ative quando:**
- Fechar competência mensal (enviar eventos antes de gerar a DCTFWeb)
- Mencionar Reinf, R-1000, R-2099, R-4010, retenção 11% ou geração de DCTFWeb

**Entrega:** Sequência de eventos a transmitir + R-2099/R-4099 com confirmação + cruzamento com DCTFWeb + recibo de transmissão
**Invocar:** `"use o agente efd-reinf para enviar os eventos da competência [mês/ano]"`

---

### 10 — eSocial
**Slug:** `esocial`
**O que faz:** eSocial — todos os eventos dos 5 grupos: S-1000 (iniciais), S-2000 (não-periódicos), S-1200 (periódicos), S-3000 (exclusão), S-5000 (totalizadores). Eventos críticos: S-2200 admissão, S-2299 desligamento, S-1200 remuneração, S-1210 pagamentos, S-2230 afastamentos, S-2240 condições ambientais. Prazos: admissão D-1; desligamento D+10; periódicos até dia 15.
**Ative quando:**
- Transmitir eventos eSocial gerais
- Mencionar S-2200/2299/1200/1210, leiautes, totalizadores, DCTFWeb cruzamento, FGTS Digital
- Rejeição de evento e precisa de diagnóstico
- Precisa de cronograma mensal completo de envios

**NÃO use para:** Cálculo da folha em si (use `35`) · Admissão completa com checklist (use `15`)
**Entrega:** Cronograma de eventos por mês + lista de eventos pendentes + diagnóstico de rejeições + checklist de envio + alerta para totalizadores S-5000 + plano de retificação
**Invocar:** `"use o agente esocial para montar o cronograma de envios de [mês/ano]"`

---

## CATEGORIA 3 — FOLHA & DEPARTAMENTO PESSOAL (11–15)

---

### 11 — Holerite
**Slug:** `holerite`
**O que faz:** Emissão e conferência de holerite completo — proventos (salário, HE, adicional noturno, periculosidade, insalubridade, DSR, comissões, 13º proporcional, férias proporcional) e descontos (INSS faixas progressivas 2026, IRRF tabela 2026 com desconto simplificado R$ 564,80, VT 6%, pensão alimentícia, faltas, VR, plano de saúde). Cobre folha mensal, adiantamento, holerite de férias, holerite de 13º (1ª e 2ª parcela) e TRCT.
**Ative quando:**
- Emitir holerite mensal de funcionário
- Mencionar holerite, contracheque, recibo de pagamento, INSS conforme faixa, IRRF, VT 6%, adiantamento
- Conferir holerite gerado por sistema
- Dúvida sobre rubrica específica

**NÃO use para:** Rescisão CLT (use `13`) · Processo de admissão (use `15`)
**Entrega:** Holerite formatado pronto para impressão + cálculo Python passo a passo (proventos → descontos → líquido) + tabela INSS/IRRF 2026 aplicada + checklist + alerta para gestante, INSS teto, dependentes IR
**Invocar:** `"use o agente holerite para gerar o holerite de [mês/ano] do funcionário [nome] com salário [valor]"`

---

### 12 — Férias e 13º Salário
**Slug:** `ferias-13-salario`
**O que faz:** Férias — período aquisitivo, gozo, abono pecuniário (10 dias — isento por Lei 7.713/88 art. 6º), parcelamento em 3 períodos (pós-Reforma 2017). 13º — 1ª parcela até 30/11 sem desconto; 2ª parcela até 20/12 com INSS + IRRF. Médias variáveis de 12 meses (HE, comissões, DSR).
**Ative quando:**
- Calcular férias ou 13º salário
- Mencionar aviso de férias 30 dias, abono pecuniário, médias variáveis 12 meses, 13º proporcional

**Entrega:** Cálculo Python + holerite específico de férias ou 13º + DARF 0561 (IRRF separado para 13º)
**Invocar:** `"use o agente ferias-13-salario para calcular as férias do funcionário [nome] com período aquisitivo [data início] a [data fim]"`

---

### 13 — Rescisão CLT
**Slug:** `rescisao-clt-calculo`
**O que faz:** Cálculo financeiro completo de rescisão CLT por qualquer motivo — sem justa causa (40% FGTS), justa causa (sem FGTS), pedido de demissão, acordo mútuo 484-A (multa 20%), fim de contrato, aposentadoria, falecimento, rescisão indireta. Aviso prévio por Lei 12.506/2011 (3 dias por ano completo, máx 90 dias). Descontos respeitando: Súm 463 STJ (aviso indenizado isento IR), Tema 481 STJ (férias indenizadas isento), RE 595.838 (multa 40% isento).
**Ative quando:** Precisar calcular o TRCT de qualquer funcionário por qualquer motivo
**Entrega:** TRCT detalhado + cálculo Python + GRRF
**Invocar:** `"use o agente rescisao-clt-calculo para calcular a rescisão de [nome] demitido sem justa causa com [n] anos de empresa"`

---

### 14 — INSS / FGTS
**Slug:** `inss-fgts`
**O que faz:** Apuração e recolhimento do INSS empresa (20% patronal + RAT 1/2/3% + GILRAT/FAP + Terceiros/Sistema S 5,8%) e FGTS (8% via FGTS Digital). Cobre desoneração da folha (CPRB Lei 12.546/2011), GPS, DAE FGTS Digital, eSocial totalizadores S-5001/S-5003, retenção de 11% sobre cessão de mão de obra (Lei 9.711/98) e multa rescisória 40%.
**Ative quando:**
- Apurar e recolher INSS e FGTS mensais
- Mencionar contribuição patronal, RAT, FAP, FGTS Digital, GPS, DAE, retenção 11%, desoneração, CPRB
- Querer conferir cálculo do sistema
- Rescisão e precisa do FGTS + multa 40%

**NÃO use para:** INSS/IRRF do funcionário no holerite (use `11`)
**Entrega:** Cálculo Python passo a passo + GPS gerada + DAE FGTS gerado + alerta sobre RAT e Terceiros + verificação desoneração CPRB + checklist cruzado com eSocial
**Invocar:** `"use o agente inss-fgts para apurar GPS e DAE de [mês/ano] da empresa [nome] com folha de R$ [valor]"`

---

### 15 — Admissão
**Slug:** `admissao`
**O que faz:** Admissão completa CLT — coleta de documentos (RG, CPF, CTPS Digital, ASO, foto, dependentes), exame admissional (NR-7), eSocial S-2200 (D-1), contrato de trabalho (CLT 442), opção FGTS, vale-transporte (Lei 7.418/85), CTPS Digital (Portaria 1.195/2019), PIS/NIT, Livro de Registro (CLT 41). Cobre CLT comum, intermitente (CLT 452-A), aprendiz (Lei 10.097/2000), terceirizado (Lei 13.429/2017), estagiário.
**Ative quando:**
- Vai admitir um novo funcionário
- Mencionar admissão, contratação, contrato CLT, ASO, exame admissional, S-2200, registro de empregado
- Precisa de checklist de documentos e prazos
- Quer modelo de contrato de trabalho

**NÃO use para:** Cálculo de holerite mensal (use `11`) · Fechamento de folha (use `35`)
**Entrega:** Checklist completo de admissão (documentos + ASO + eSocial + contrato + CTPS) + minuta de contrato + cronograma D-7/D-1/D-0 + alertas para intermitente/aprendiz/estagiário + Python validador de admissão
**Invocar:** `"use o agente admissao para gerar o checklist e contrato para admitir [nome] como [cargo] a partir de [data]"`

---

## CATEGORIA 4 — CONCILIAÇÃO & FINANCEIRO (16–19)

---

### 16 — Conciliação Bancária
**Slug:** `conciliacao-bancaria`
**O que faz:** Conciliação bancária mensal com tolerância ZERO — match item a item entre extrato bancário (OFX/CSV/PDF) e razão contábil. Identifica tarifas, IOF, juros, débitos automáticos, cheques pendentes e depósitos em trânsito.
**Ative quando:**
- Fecha o mês (pré-balancete) e precisa bater o saldo bancário
- Cliente novo com saldos divergentes desde o início

**Entrega:** Espelho de conciliação + saldo final batido + lista de pendências para regularizar + lançamentos a fazer
**Invocar:** `"use o agente conciliacao-bancaria para conciliar o banco [nome] de [mês/ano] do cliente [nome]"`

---

### 17 — Cobrança de Honorários
**Slug:** `cobranca-honorarios`
**O que faz:** Cobrança de honorários contábeis atrasados — régua escalonada de 5 etapas até ação judicial. Aplica mora (CC 397), título executivo extrajudicial (CPC 784 III), monitória (CPC 700), Cadastro de Inadimplentes (Serasa/SPC/Boa Vista) e protesto extrajudicial (Lei 9.492/97). Fundamentado na Resolução CFC 1.546/2024.
**Ative quando:**
- Cliente atrasou pagamento de honorários
- Mencionar inadimplência de cliente, executar honorários, monitória, suspensão de serviços, distrato
- Precisa de régua de cobrança escalonada
- Cliente sumiu sem pagar

**NÃO use para:** Cálculo de tributo do cliente (use os agentes de apuração)
**Entrega:** Régua em 5 etapas (lembrete → notificação → suspensão → extrajudicial → judicial) + cálculo Python do valor atualizado + 5 modelos prontos + minuta de monitória ou execução + estratégia de protesto + checklist
**Invocar:** `"use o agente cobranca-honorarios para montar a régua de cobrança do cliente [nome] com [valor] em atraso desde [data]"`

---

### 18 — DRE Gerencial
**Slug:** `dre-gerencial`
**O que faz:** DRE gerencial com separação de custos variáveis × fixos, margem de contribuição (MC%), ponto de equilíbrio (PE), comparativos realizado × orçado × ano anterior, análise por produto/cliente/centro de custo.
**Ative quando:**
- Precisa tomar decisão de preço, mix de produtos ou fechamento de loja/unidade
- Mencionar margem de contribuição, MC%, ponto de equilíbrio, custo variável, orçamento, KPIs gerenciais

**Entrega:** DRE gerencial estruturada + cálculo do PE + análise de sensibilidade + recomendações estratégicas
**Invocar:** `"use o agente dre-gerencial para montar a DRE gerencial de [mês/ano] do cliente [nome]"`

---

### 19 — Fluxo de Caixa Projetado
**Slug:** `fluxo-caixa-projetado`
**O que faz:** Fluxo de caixa direto realizado e projetado — diário (4 semanas), semanal (3 meses), mensal (12 meses), com 3 cenários (otimista, realista, pessimista). Entradas pelo regime de caixa (não competência). Suporte a antecipação de recebíveis e decisões de capital de giro.
**Ative quando:**
- Cliente com sazonalidade ou prazo de recebimento descompassado do pagamento
- Mencionar projeção, DCF realizado, antecipação de recebíveis, capital de giro

**Entrega:** Planilha CSV semanal/mensal com 3 cenários + identificação de déficits e excedentes por período
**Invocar:** `"use o agente fluxo-caixa-projetado para projetar o fluxo de caixa de [mês inicial] a [mês final] do cliente [nome]"`

---

## CATEGORIA 5 — ATENDIMENTO AO CLIENTE (20–23)

---

### 20 — Triagem WhatsApp
**Slug:** `triagem-whatsapp`
**O que faz:** Triagem de mensagens do WhatsApp central do escritório — classifica por tipo (urgente/rotina/spam), área (fiscal/pessoal/cobrança/consulta/cliente novo), urgência (prazo iminente/médio/sem prazo) e encaminha para o responsável correto. Gera resposta padrão (FAQ) e identifica escalações. Aplica Resolução CFC 1.546/2024 e LGPD.
**Ative quando:**
- Recebeu lote de mensagens no WhatsApp do escritório e precisa triar
- Mencionar triagem, atendimento, FAQ, classificação de mensagem, escalação
- Precisa de régua de resposta automática
- Quer monitorar mensagens não respondidas

**NÃO use para:** CRM completo · Envio em massa
**Entrega:** Tabela de triagem (mensagem → área → urgência → responsável → ação) + 15 templates FAQ + critérios de escalação + protocolo de SLA por urgência + Python contador de mensagens não respondidas
**Invocar:** `"use o agente triagem-whatsapp para classificar as mensagens recebidas hoje no WhatsApp do escritório"`

---

### 21 — Documentos Pendentes
**Slug:** `documentos-pendentes`
**O que faz:** Controle de documentos pendentes que o cliente precisa enviar para o escritório fechar mês/trimestre/ano (NFs, extratos, comprovantes de despesas, holerites, contratos, atas). Classifica por prazo (urgente/normal/opcional) e envia régua de cobrança automática.
**Ative quando:**
- Precisar cobrar documentos do cliente para fechar a contabilidade
- Mencionar pendências, documentos em aberto, NF não recebida, extrato bancário não enviado
- Risco de atrasar obrigação acessória por falta de documento
- Quer régua automática D-7/D-3/D-0

**NÃO use para:** Conciliação bancária (use `16`) · Cadastro de NF (use `24`)
**Entrega:** Lista de pendências por cliente em CSV + régua de cobrança automatizada (e-mail/WhatsApp) + cronograma reverso a partir do prazo legal + Python contador de impacto + checklist mensal
**Invocar:** `"use o agente documentos-pendentes para listar o que o cliente [nome] precisa enviar para fechar [mês/ano]"`

---

### 22 — Onboarding Cliente
**Slug:** `onboarding-cliente`
**O que faz:** Onboarding formal de cliente novo — contrato de prestação de serviços (Resolução CFC 803/96 + 1.546/2024), procuração eletrônica e-CAC, termo LGPD (Lei 13.709/2018), coleta de documentos societários, abertura de pasta digital, cadastro no software contábil (Domínio, Sage, Conta Azul, Onvio, Alterdata), conexão e-CAC + portais estadual/municipal + eSocial + FGTS Digital.
**Ative quando:**
- Cliente acabou de assinar e precisa formalizar a entrada no escritório
- Mencionar contrato contábil, procuração e-CAC, certificado digital, distrato com escritório anterior
- Precisa do fluxo da 1ª semana e do 1º mês
- Quer modelo padronizado de onboarding

**NÃO use para:** Triagem de primeiro contato (use `20`) · Follow-up rotineiro (use `23`)
**Entrega:** Pacote de onboarding (contrato + procuração + LGPD + termos) + checklist operacional 1ª semana / 1º mês + protocolo de transição com escritório anterior + cadastro no software + comunicação de boas-vindas
**Invocar:** `"use o agente onboarding-cliente para gerar o pacote completo de entrada do cliente [nome] [CNPJ]"`

---

### 23 — Follow-up Cliente
**Slug:** `follow-up-cliente`
**O que faz:** Rotina de follow-up com cliente ativo — atualização proativa pós-fechamento mensal (DARFs, DAS, balancete), reunião trimestral de planejamento tributário, comunicação de mudanças legislativas relevantes, gestão de cliente VIP × comum, retenção anti-churn e reativação de cliente "frio".
**Ative quando:**
- Precisa estruturar régua de comunicação com clientes
- Mencionar follow-up, atualização mensal, comunicação de DARF, NPS, satisfação, retenção, churn, reativação
- Cliente sumiu ou está reclamando
- Quer modelo de e-mail de atualização mensal

**NÃO use para:** Onboarding inicial (use `22`) · Cobrança de honorários atrasados (use `17`)
**Entrega:** Régua de comunicação por tipo de cliente + 5 modelos prontos (atualização mensal / decisão fiscal favorável / autuação / atraso na declaração / reativação) + protocolo de reclamação + métricas NPS + cronograma trimestral
**Invocar:** `"use o agente follow-up-cliente para criar os modelos de comunicação mensal para os clientes VIP do escritório"`

---

## CATEGORIA 6 — OPERAÇÃO INTERNA (24–27)

---

### 24 — Cadastro de NF
**Slug:** `cadastro-nf`
**O que faz:** Cadastro e classificação de notas fiscais para escrituração — NF-e (modelo 55), NFS-e (serviço), NFC-e (consumidor final, modelo 65), CT-e (transporte). Identifica CFOP correto, CST/CSOSN, NCM, alíquota ICMS, ICMS-ST, IPI e retenções (ISS, INSS, IRRF, PIS/COFINS quando tomador é PJ obrigada). Detecta NF problemática (CFOP errado, CST inconsistente, divergência XML × PDF).
**Ative quando:**
- Recebeu lote de NFs e precisa classificar para lançamento
- Mencionar CFOP, NCM, CST/CSOSN, escrituração, importação XML, integração ERP
- NF rejeitada ou divergente entre XML e PDF
- Precisa cadastrar fornecedor ou cliente novo no sistema

**NÃO use para:** Gerar o arquivo SPED Fiscal (use `06`)
**Entrega:** Planilha de classificação por NF (chave / fornecedor / valor / CFOP / CST / NCM / retenções) + lista de NFs com problema + plano de correção + script de importação XML + checklist de cadastro de fornecedor
**Invocar:** `"use o agente cadastro-nf para classificar as [n] NFs de entrada do cliente [nome] de [mês/ano]"`

---

### 25 — Lembrete de Prazo
**Slug:** `lembrete-prazo`
**O que faz:** Controle de prazos legais do escritório — calendário fiscal mensal (DAS dia 20; GPS dia 20; FGTS dia 20; DARFs último dia útil; ICMS varia por UF; ISS varia por município; eSocial S-1299 dia 15; SPED ICMS-IPI dia 25; EFD-Contribuições dia 14 do 2º mês) e declarações anuais (ECF, ECD, DEFIS, IRPF). Cria régua D-7/D-3/D-1/D-0 e calendário ICS importável.
**Ative quando:**
- Precisa montar calendário fiscal mensal ou anual
- Mencionar prazo, agenda fiscal, vencimento, ICS, antecedência
- Cliente novo precisa do mapa de prazos
- Quer integrar com Google Calendar ou Outlook

**NÃO use para:** Conferência de guia em si (use `05`)
**Entrega:** Calendário fiscal em CSV + arquivo ICS importável + régua D-7/D-3/D-1/D-0 + alertas de feriados + Python para calcular próxima data útil + plano de antecipação quando vencimento cai em sábado/domingo/feriado
**Invocar:** `"use o agente lembrete-prazo para gerar o calendário fiscal de [mês/ano] para o cliente [nome] em [UF] e [cidade]"`

---

### 26 — Relatório Mensal
**Slug:** `relatorio-mensal`
**O que faz:** Relatório mensal executivo entregue ao cliente — síntese de 1 página com KPIs principais (receita, despesas, lucro, margem, total tributário, % tributação efetiva), evolução vs mês anterior, alertas (autuações, prazos, oportunidades), próximos passos e comentário do contador. Foco em comunicação, não em escrituração técnica.
**Ative quando:**
- Acabou o fechamento mensal e quer enviar o relatório ao cliente
- Mencionar relatório gerencial, dashboard, KPI, comunicação ao cliente
- Cliente VIP precisa de apresentação executiva
- Quer modelo padronizado para todos os clientes

**NÃO use para:** Balancete técnico (use `42`) · DRE detalhado (use `18`)
**Entrega:** Relatório de 1 página + tabela de KPIs + gráficos textuais (ASCII/sugestões) + alertas (até 3) + próximos passos (3-5) + comentário do contador (3 linhas) + Python para gerar versão por cliente em batch
**Invocar:** `"use o agente relatorio-mensal para gerar o relatório executivo de [mês/ano] do cliente [nome]"`

---

### 27 — Backup do Escritório
**Slug:** `backup-escritorio`
**O que faz:** Política e operação de backup de arquivos do escritório — pastas de clientes, XMLs de NF-e, declarações (ECD/ECF/SPED/EFD), e-mails, contratos, eventos eSocial. Aplica regra 3-2-1 (3 cópias / 2 mídias / 1 off-site), criptografia (LGPD art. 46-47), retenção legal mínima de 5 anos (CC art. 1.194 + CTN art. 173), versionamento, teste mensal de restore e plano de resposta a incidente (LGPD art. 48 — ANPD em 48h).
**Ative quando:**
- Precisa estruturar a política de backup do escritório
- Mencionar LGPD, ANPD, ransomware, perda de dados, restore, retenção, OneDrive/Drive/Dropbox/AWS
- Sofreu incidente de segurança ou perda de dados
- Está abrindo escritório novo e precisa da infraestrutura

**NÃO use para:** Política operacional do cliente (este agente é para o escritório)
**Entrega:** Política de backup escrita + arquitetura técnica 3-2-1 recomendada + cronograma de execução automática + script de teste de restore mensal + plano de resposta a incidente em 48h + Termo de Responsabilidade do operador
**Invocar:** `"use o agente backup-escritorio para criar a política de backup do escritório com armazenamento no [serviço]"`

---

## CATEGORIA 7 — ESPECIALIZAÇÕES (28–57)

### 7A · Tributário (28–31)

---

### 28 — Apuração MEI
**Slug:** `apuracao-mei`
**O que faz:** MEI — DAS-MEI mensal (PGMEI), DASN-SIMEI anual, controle do limite de faturamento (R$ 81.000/ano), alerta de risco ao se aproximar de R$ 65k e gerenciamento do desenquadramento com migração para ME no Simples Nacional.
**Ative quando:**
- Cliente é MEI
- Mencionar PGMEI, DASN-SIMEI, NFS-e nacional, desenquadramento, fator empregado
- Faturamento acumulado do ano superou R$ 65.000
- MEI estourou o limite e precisa migrar

**NÃO use para:** Simples Nacional ME/EPP (use `01`) · MEI Caminhoneiro (regra própria, limite R$ 251.600)
**Entrega:** Tabela de controle anual + DAS gerado + diagnóstico de risco de desenquadramento + carta-aviso ao cliente em DOCX/MD se faturamento acumulado > R$ 65k
**Invocar:** `"use o agente apuracao-mei para gerar o DAS-MEI de [mês/ano] do cliente [nome] com faturamento de R$ [valor]"`

---

### 29 — Cálculo IPI
**Slug:** `calculo-ipi`
**O que faz:** Apuração mensal de IPI para indústria e equiparados — TIPI 2022 vigente, regimes de suspensão (drawback, RECOF, encomenda), crédito presumido de exportação (Lei 9.363/96) e Bloco K do SPED.
**Ative quando:**
- Tem cliente indústria ou equiparado com NF tributada por IPI
- Mencionar suspensão/drawback/RECOF/encomenda/crédito presumido de exportação
- Opera Zona Franca de Manaus ou ALC
- Precisa apurar débitos × créditos de IPI do mês

**Entrega:** Cálculo Python + apuração mensal créditos × débitos + DARF 5123 com vencimento + memória em CSV + checklist de 6 itens
**Invocar:** `"use o agente calculo-ipi para apurar o IPI de [mês/ano] da indústria [nome] com NCM [código]"`

---

### 30 — IRRF na Folha
**Slug:** `calculo-irrf-folha`
**O que faz:** IRRF na folha (CLT, pró-labore, RPA, autônomo) e em pagamentos PJ a PF (aluguel, juros, royalties). Aplica tabela progressiva 2026, deduções por dependentes (R$ 189,59), pensão alimentícia e INSS deduzido. Controla DARF separado para IRRF do 13º e analisa isenções (aviso prévio indenizado — Súm 463 STJ; férias indenizadas — Tema 481 STJ).
**Ative quando:**
- Calcula folha CLT e precisa do IRRF correto
- Mencionar DARF 0561, 0588, 3208, dependentes IR ou tabela progressiva
- Trata o 13º salário (requer DARF próprio)
- Verificar se aviso prévio indenizado ou férias indenizadas têm IRRF (não têm)

**Entrega:** Cálculo Python passo a passo + DARF correto por natureza (0561/0588/3208) + análise de não-incidência + CSV
**Invocar:** `"use o agente calculo-irrf-folha para calcular o IRRF do holerite de [nome] com salário bruto R$ [valor] e [n] dependentes"`

---

### 31 — Retenções Tributárias (Tomador)
**Slug:** `retencoes-tributarias-tomador`
**O que faz:** Retenções que o TOMADOR de serviço deve fazer ao pagar a NF — IRRF 1,5% (código 1708) ou 1% (limpeza/vigilância), CSRF 4,65% (código 5952, só se acumulado mensal ≥ R$ 215,05), INSS 11% sobre cessão de mão de obra (Lei 8.212 art. 31), ISS retido conforme lei municipal. Identifica quando a declaração de Simples Nacional dispensa a retenção (IN RFB 1.234/2012).
**Ative quando:**
- Recebeu NF de serviço de PJ para pagar e precisa verificar retenções
- Fornecedor apresentou declaração de Simples Nacional (verifica se dispensa)
- Serviço é cessão de mão de obra (construção, limpeza, vigilância, TI)
- Acumulado mensal próximo a R$ 215,05 (teto para CSRF)

**Entrega:** Cálculo com cada retenção identificada + DARFs prontos + valor líquido a pagar + comprovantes para o prestador + guia para EFD-Reinf R-2010/R-4020
**Invocar:** `"use o agente retencoes-tributarias-tomador para calcular as retenções da NF de R$ [valor] de [tipo de serviço] do fornecedor [nome]"`

---

### 7B · Obrigações (32–34)

---

### 32 — EFD-Contribuições
**Slug:** `efd-contribuicoes`
**O que faz:** EFD-Contribuições mensal — escrituração PIS/COFINS por CST (Tabela 4.3.3), Bloco M (apuração), F500 (regime de caixa Lucro Presumido), F600 (CSRF — retenções sofridas), Bloco P (CPRB), conciliação com DCTFWeb.
**Ative quando:**
- Prepara EFD-Contribuições mensal
- Mencionar PVA EFD-Contrib, M100/M200/M500/M600, CST 50/04/49, F600

**Entrega:** Validação por amostragem de NFs + apuração consolidada PIS/COFINS + cruzamento com DCTFWeb + checklist de 7 itens
**Invocar:** `"use o agente efd-contribuicoes para montar a EFD-Contribuições de [mês/ano] do cliente [nome]"`

---

### 33 — DIMOB
**Slug:** `dimob`
**O que faz:** DIMOB anual para imobiliárias, construtoras, incorporadoras e administradoras de bens — operações de venda, locação, intermediação e construção. Formata o arquivo TXT para envio pelo PGD conforme IN RFB 1.115.
**Ative quando:**
- Tem cliente imobiliário que precisa entregar a DIMOB anual
- Mencionar PGD DIMOB, IN RFB 1.115, Operação 01-04, aluguéis repassados, vendas parceladas

**Entrega:** Tabela de operações por tipo + arquivo TXT formatado para PGD + recibo + comprovante de IRRF a beneficiários
**Invocar:** `"use o agente dimob para gerar a DIMOB do exercício [ano] da imobiliária [nome]"`

---

### 34 — DMED
**Slug:** `dmed`
**O que faz:** DMED anual para prestadores de serviços médicos (hospitais, clínicas, médicos PJ, laboratórios) e operadoras de plano de saúde. É o espelho das deduções de saúde no IRPF do paciente — divergência gera malha fina para o paciente.
**Ative quando:**
- Tem cliente médico, hospital, laboratório ou operadora de plano de saúde
- Mencionar DMED, IN RFB 985, Quadro 12, dependentes plano de saúde

**Entrega:** Arquivo TXT para PGD + recibo + alerta sobre obrigatoriedade do CPF nos recibos médicos
**Invocar:** `"use o agente dmed para gerar a DMED do exercício [ano] da clínica [nome]"`

---

### 7C · Folha (35)

---

### 35 — Folha de Pagamento Mensal
**Slug:** `folha-pagamento-mensal`
**O que faz:** Folha CLT mensal completa — cálculo de salário base + adicionais (periculosidade, insalubridade, adicional noturno, horas extras) + descontos (INSS faixas progressivas, IRRF, VT 6%, plano de saúde, faltas) + FGTS 8% + aplicação do dissídio/CCT vigente. Emite holerite por empregado.
**Ative quando:**
- Fecha a folha de pagamento do mês
- Mencionar holerite, INSS efetivo, dissídio, periculosidade vs insalubridade, hora reduzida noturna, banco de horas

**Entrega:** Holerite por empregado em DOCX/MD + tabela consolidada do mês + cálculo Python passo a passo + checklist de 8 itens
**Invocar:** `"use o agente folha-pagamento-mensal para processar a folha de [mês/ano] do cliente [nome] com [n] funcionários"`

---

### 7D · Contábil (36–37)

---

### 36 — Plano de Contas CPC
**Slug:** `plano-contas-cpc`
**O que faz:** Estruturação do plano de contas com 100% de mapeamento referencial fiscal (Anexo III IN RFB 2.003) e aderência aos CPCs (CPC 26, 27, 4, 47, 48, 6 R2, 25). Inclui DRE estruturada e provisões mensais (férias, 13º, PCLD).
**Ative quando:**
- Implanta cliente novo no software contábil
- Abre empresa e precisa do plano de contas inicial
- Migra de ERP e precisa remapear contas
- Recebeu erro de "conta sem referencial" no PVA da ECD

**Entrega:** Plano de contas em CSV com 5 colunas + matriz de mapeamento referencial + lista de provisões mensais a configurar no ERP
**Invocar:** `"use o agente plano-contas-cpc para criar o plano de contas da empresa [nome] no regime [Presumido/Real/Simples]"`

---

### 37 — Lançamentos Contábeis Padrão
**Slug:** `lancamentos-contabeis-padrao`
**O que faz:** Catálogo operacional de lançamentos D/C para todas as operações cotidianas — vendas (com impostos como redutor da receita bruta), compras (com créditos), folha (encargos e provisões CPC 33), tributos sobre lucro, empréstimos (custo amortizado CPC 48), equivalência patrimonial (CPC 18), PCLD (CPC 48), arrendamento IFRS 16 (CPC 6 R2).
**Ative quando:**
- Pede modelo de lançamento contábil
- Conferindo livros e tem dúvida sobre a forma correta de um lançamento

**Entrega:** Lançamentos padronizados D/C com histórico explicativo + advertência sobre os erros típicos de cada operação
**Invocar:** `"use o agente lancamentos-contabeis-padrao para mostrar os lançamentos de [operação] com os impostos corretos"`

---

### 7E · Conciliação (38–40)

---

### 38 — Conciliação Cartões / Credenciadora
**Slug:** `conciliacao-cartoes-credenciadora`
**O que faz:** Conciliação de vendas via cartão (Cielo, Stone, Rede, GetNet, PagSeguro, SafraPay, Mercado Pago) com os repasses da credenciadora. Separa MDR (taxa), antecipação, chargebacks, vouchers e PIX QR. Reconhece a receita BRUTA com a taxa como despesa financeira separada (não líquida).
**Ative quando:**
- Cliente é comércio ou e-commerce com volume de vendas por cartão
- Conciliação mensal divergente entre o relatório da credenciadora e o caixa
- Antecipação de recebíveis de cartão a ser contabilizada

**Entrega:** Tabela vendas × repasses por data + classificação por modalidade (débito/crédito/parcelado/pix) + lançamentos D/C com taxa como despesa financeira
**Invocar:** `"use o agente conciliacao-cartoes-credenciadora para conciliar o relatório da [credenciadora] de [mês/ano] do cliente [nome]"`

---

### 39 — Conciliação de Fornecedores
**Slug:** `conciliacao-fornecedores`
**O que faz:** Conciliação do razão de fornecedores (contas a pagar) — match NFs recebidas × pagamentos × histórico. Identifica NFs em duplicidade, adiantamentos (separar em 1.1.5), retenções de NF de serviço (lançar passivo IRRF/CSRF/INSS retido), juros/multa e descontos por pagamento antecipado.
**Ative quando:**
- Fecha mês (foco nos 20 maiores fornecedores)
- Em auditoria com necessidade de circularização
- Cliente novo com histórico de contas a pagar não conciliadas

**Entrega:** Planilha por fornecedor com saldo apurado × razão contábil + modelo de circularização para os top fornecedores
**Invocar:** `"use o agente conciliacao-fornecedores para conciliar os 20 maiores fornecedores do cliente [nome] em [mês/ano]"`

---

### 40 — Conciliação de Clientes
**Slug:** `conciliacao-clientes`
**O que faz:** Conciliação do razão de clientes (contas a receber) — match NFs emitidas × recebimentos. Monta aging (a vencer / 1-30 / 31-60 / 61-90 / 91-180 / > 180 / > 360 dias). Calcula PCLD por modelo de perdas esperadas (CPC 48) e orienta baixa fiscal por perda (Lei 9.430/96 art. 9-14).
**Ative quando:**
- Fecha balancete e precisa conferir o saldo de clientes
- Revisa a carteira de recebíveis
- Precisa atualizar a PCLD ou dar baixa fiscal em créditos irrecuperáveis

**Entrega:** Tabela de aging completa + cálculo de PCLD por estágio (CPC 48) + ajuste contábil a lançar
**Invocar:** `"use o agente conciliacao-clientes para montar o aging de contas a receber do cliente [nome] em [mês/ano]"`

---

### 7F · Fechamento (41–43)

---

### 41 — Fechamento Mensal
**Slug:** `fechamento-mensal`
**O que faz:** Roteiro completo de fechamento contábil mensal em até 5 dias úteis — provisões (CPC 33: férias, 13º, PCLD), depreciação, conciliações (banco/cartão/fornecedores/clientes), encerramento de resultado mensal e geração de relatórios (balancete, DRE, BP, DFC CPC 03).
**Ative quando:** Usuário anuncia que vai fechar o mês
**Entrega:** Checklist mestre de fechamento + balancete + DRE + DFC + pacote analítico ao cliente em DOCX/MD
**Invocar:** `"use o agente fechamento-mensal para guiar o fechamento de [mês/ano] do cliente [nome]"`

---

### 42 — Balancete — Análise
**Slug:** `balancete-analise`
**O que faz:** Leitura e análise do balancete mensal — verifica integridade (D = C, sintética = soma das analíticas), coerência (saldo invertido, conta com natureza errada), variações > 20% vs mês anterior e calcula indicadores (liquidez corrente, endividamento, PMR, PMP, giro de estoque, ROE).
**Ative quando:** Após o fechamento, antes de entregar o balancete ao cliente
**Entrega:** Pacote analítico estruturado + alertas de inconsistência + recomendações de ajuste
**Invocar:** `"use o agente balancete-analise para revisar o balancete de [mês/ano] do cliente [nome]"`

---

### 43 — Ativo Imobilizado / Depreciação
**Slug:** `ativo-imobilizado-depreciacao`
**O que faz:** Ativo imobilizado (CPC 27) — reconhecimento (custo + frete + montagem + tributos não-recuperáveis), depreciação (linear, soma dos dígitos, unidades produzidas, acelerada por turnos RIR 322), vida útil contábil × fiscal (Anexo III IN 1.700), valor residual (revisão anual), impairment (CPC 1), CIAP (48 parcelas ICMS imobilizado), intangíveis (CPC 4), arrendamento IFRS 16 / CPC 6 R2.
**Ative quando:**
- Empresa compra ou vende imobilizado
- Revisão anual de vida útil e valor residual
- Teste de impairment obrigatório (CPC 1)
- Novo contrato de arrendamento/locação (IFRS 16)

**Entrega:** Cadastro do bem com todos os atributos + cálculo de depreciação mensal + lançamentos D/C + alerta de impairment se aplicável
**Invocar:** `"use o agente ativo-imobilizado-depreciacao para cadastrar o bem [descrição] adquirido por R$ [valor] com vida útil de [n] anos"`

---

### 7G · Análise Estratégica (44–46)

---

### 44 — Análise de Regime Tributário
**Slug:** `analise-tributaria-regime`
**O que faz:** Análise comparativa Simples Nacional × Lucro Presumido × Lucro Real com projeção de 12 meses. Considera ICMS, ISS, PIS/COFINS, IRPJ/CSLL e INSS/CPP. Inclui análise de sensibilidade ±20% no faturamento e margem.
**Ative quando:**
- Início do ano-calendário (Simples: até último dia útil de janeiro; Real/Presumido: 1ª DARF)
- Mudança relevante na empresa (novos sócios, nova atividade, expansão, queda de margem)
- Empresa próxima a estourar o limite do Simples (R$ 4,8 mi)
- Margem real menor que a margem presumida (pode indicar Lucro Real mais vantajoso)

**Entrega:** Comparativo com 3 cenários (Simples × Presumido × Real) + análise de sensibilidade ±20% + recomendação assinada por contador (CRC)
**Invocar:** `"use o agente analise-tributaria-regime para comparar os regimes da empresa [nome] com faturamento de R$ [valor]/ano e margem de [%]"`

---

### 45 — Recuperação Créditos PIS/COFINS
**Slug:** `recuperacao-creditos-pis-cofins`
**O que faz:** Recuperação retroativa de PIS/COFINS pagos a maior nos últimos 5 anos — Tema 69 STF (exclusão ICMS retroativa, modulação 15/03/2017), Tema 779 STJ (insumos amplos), monofásicos tributados indevidamente, créditos de exportação não aproveitados, crédito presumido sobre estoque (Lei 10.637 art. 11).
**Ative quando:**
- Cliente Lucro Real com mais de 5 anos de operação
- Cliente Lucro Presumido com Tema 69 retroativo (modulação 15/03/2017)
- Trabalho de revisão fiscal pré ou pós due diligence

**Entrega:** Memória de cálculo mês a mês com Selic + EFD-Contribuições retificadora + PER/DCOMP + acompanhamento da restituição
**Invocar:** `"use o agente recuperacao-creditos-pis-cofins para levantar créditos retroativos do cliente [nome] de [ano início] a [ano fim]"`

---

### 46 — Revisão Fiscal / Cruzamento SPED
**Slug:** `revisao-fiscal-cruzamento-sped`
**O que faz:** Cruzamento ECD × ECF × EFD ICMS/IPI × EFD-Contribuições × eSocial × EFD-Reinf × DCTFWeb para identificar divergências antes da malha fina ou em diligência. Classifica por valor e criticidade.
**Ative quando:**
- Auditoria interna trimestral preventiva
- Antes de transmitir a ECF (após gerar a ECD)
- Due diligence em processo de M&A
- Intimação recebida ou suspeita de divergência entre obrigações

**Entrega:** Espelho de divergências classificado por valor e criticidade + plano de ajuste com retificações na ordem correta (EFD → ECD → ECF → DCTFWeb)
**Invocar:** `"use o agente revisao-fiscal-cruzamento-sped para cruzar todas as obrigações do cliente [nome] de [ano]"`

---

### 7H · Malha Fina (47–48)

---

### 47 — Malha Fina PF
**Slug:** `malha-fina-pf-diagnostico`
**O que faz:** Diagnóstico de pendências de IRPF na malha fina — interpreta o extrato do e-CAC (Meu IRPF), identifica a causa (rendimento omitido, dedução indevida, dependente, ganho de capital), decide se é caso de retificadora ou defesa via e-CAC (prazo 30 dias), e prepara o documento correto.
**Ative quando:**
- Cliente PF recebeu comunicado de pendência de IRPF
- Intimação ou notificação da Receita Federal referente ao IRPF
- Verificação preventiva após entrega da declaração

**Entrega:** Extrato decifrado + decisão (retificar ou defender) + retificadora ou minuta de defesa + DARF código 0211 com Selic + multa se aplicável
**Invocar:** `"use o agente malha-fina-pf-diagnostico para analisar a pendência do cliente [nome] referente ao IRPF de [ano]"`

---

### 48 — Malha Fina PJ
**Slug:** `malha-fina-pj-diagnostico`
**O que faz:** Diagnóstico de intimações da malha PJ — TIF (Termo de Intimação Fiscal — 20 dias), Comunicado de Inconsistência, Auto de Infração (30 dias para impugnar ao DRJ), Despacho Decisório, Aviso de Lançamento. Identifica divergências entre os SPEDs e a DCTFWeb.
**Ative quando:**
- Empresa recebeu intimação da RFB, Sefaz ou prefeitura
- Pendência de regularidade na Certidão Negativa de Débitos (CND)
- Suspeita preventiva de divergência antes de pedir a CND

**Entrega:** Documento decifrado + plano (retificar / defender / parcelar) + minuta de resposta + cronograma das ações
**Invocar:** `"use o agente malha-fina-pj-diagnostico para analisar o auto de infração recebido pela empresa [nome]"`

---

### 7I · Consultoria (49–50)

---

### 49 — Due Diligence Contábil
**Slug:** `due-diligence-contabil`
**O que faz:** Due diligence contábil-fiscal-trabalhista pré-M&A ou pré-investimento (VC/PE) — identifica passivos ocultos, contingências (CPC 25), ajusta o EBITDA (Quality of Earnings). Relatório de findings classificado por severidade (alta/média/baixa). Escopo de 4 a 12 semanas com cut-off date e materialidade definidos.
**Ative quando:**
- Compra/venda de empresa, fusão ou aporte de capital
- Expansão por franquia, sucessão familiar ou herança
- NDA assinado e data room aberto para auditoria

**Entrega:** Findings classificados por severidade + EBITDA ajustado + cláusulas de R&W (Rep & Warranties) + escrow sugerido + relatório final assinado
**Invocar:** `"use o agente due-diligence-contabil para iniciar a DD da empresa [nome] com escopo [fiscal/trabalhista/full] e cut-off [data]"`

---

### 50 — Valuation PME
**Slug:** `valuation-pme`
**O que faz:** Valuation de PME por 3 métodos: DCF (FCFF/FCFE com projeção 5 anos), múltiplos comparáveis (EV/EBITDA, EV/Receita, P/E) e patrimonial (piso). Ajusta o EBITDA com one-offs, calcula WACC com prêmio Brasil + tamanho e aplica sensibilidade WACC × g.
**Ative quando:**
- Cliente quer vender a empresa ou captar investidor
- Sucessão familiar ou partilha em processo de divórcio
- Combinação de negócios (CPC 15) — aquisição com ágio/deságio

**Entrega:** Faixa de valor (mínimo-médio-máximo) + planilha DCF + análise de sensibilidade + relatório assinado
**Invocar:** `"use o agente valuation-pme para avaliar a empresa [nome] com EBITDA de R$ [valor] e crescimento esperado de [%] ao ano"`

---

### 7J · IRPF (51)

---

### 51 — IRPF — Declaração Completa
**Slug:** `irpf-declaracao-completa`
**O que faz:** Declaração de IRPF anual completa — múltiplas fontes (CLT, autônomo, aluguel, ganho de capital, B3, exterior Lei 14.754/2023, atividade rural), comparativo Simplificada × Completa (desconto simplificado R$ 564,80 ou deduções legais), dependentes (CPF obrigatório), bens e direitos em 31/12 e dívidas > R$ 5.000.
**Ative quando:**
- Período de entrega do IRPF (15/03 a 31/05 do ano seguinte)
- Precisa entregar retificadora de IRPF

**Entrega:** Declaração simulada Simplificada × Completa + DARFs (cota única ou parcelas) + lista de bens em 31/12 + comprovação documental necessária
**Invocar:** `"use o agente irpf-declaracao-completa para preparar a declaração de IRPF de [ano-base] do cliente [nome]"`

---

### 7K · Societário (52–54)

---

### 52 — Abertura de Empresa / CNPJ
**Slug:** `abertura-empresa-cnpj`
**O que faz:** Abertura de empresa via REDESIM (Lei 14.195/2021) — viabilidade de nome + endereço × CNAE, coleta do DBE (inscrições na RFB, Estado, Município, Bombeiros, Anvisa), contrato social com cláusulas obrigatórias (CC 997), registro na Junta Comercial e opção tributária.
**Ative quando:**
- Cliente vai abrir empresa nova ou segunda empresa
- Mencionar REDESIM, NIRE, MEI, ME, EPP, LTDA, SLU

**Entrega:** Checklist completo + cronograma de 5-15 dias + minuta de contrato social + plano de contas implantado
**Invocar:** `"use o agente abertura-empresa-cnpj para abrir uma [LTDA/SLU] de [atividade] em [cidade/UF]"`

---

### 53 — Alteração Contratual
**Slug:** `alteracao-contratual`
**O que faz:** Alterações contratuais via REDESIM — entrada/saída de sócios (cessão onerosa com DARF GCAP código 4600 ou cessão gratuita com ITCMD), aumento/redução de capital, mudança de objeto/CNAE, mudança de endereço (UF nova exige nova IE), transformação societária (LTDA ↔ S.A. mantém o CNPJ).
**Ative quando:**
- Muda o quadro societário, a atividade, o endereço ou o capital social
- Faz transformação societária

**Entrega:** Cláusulas da alteração + DBE atualizado + DARF GCAP se cessão onerosa + comunicação formal a bancos e fornecedores
**Invocar:** `"use o agente alteracao-contratual para redigir a alteração de entrada do sócio [nome] na empresa [nome]"`

---

### 54 — Encerramento / Baixa
**Slug:** `encerramento-empresa-baixa`
**O que faz:** Baixa de empresa via REDESIM — baixa regular (sem dívidas) ou com débito (Lei 11.598/07 art. 7º-A — débitos passam aos sócios), distrato social com liquidante, encerramento contábil (realizar ativo, pagar passivo, distribuir acervo), declarações fracionadas (ECF/ECD/DEFIS/DCTFWeb/EFDs/eSocial S-2299/Reinf) e ganho de capital do sócio na restituição.
**Ative quando:**
- Cliente vai encerrar a empresa
- Empresa parada acumulando obrigações sem atividade

**Entrega:** Distrato social + cronograma de baixa + lista de declarações fracionadas a entregar + plano de comunicação aos credores
**Invocar:** `"use o agente encerramento-empresa-baixa para estruturar a baixa da empresa [nome]"`

---

### 7L · Contencioso Fiscal (55–56)

---

### 55 — Parcelamento Receita Federal
**Slug:** `parcelamento-receita-federal`
**O que faz:** Parcelamentos federais — ordinário 60x (Lei 10.522/2002, multa reduzida 50%), simplificado online (até R$ 5 mi por débito), transação tributária (Lei 13.988/2020 — descontos até 65%, 145 meses), recuperação judicial tributária (Lei 14.112/2020, 120 meses) e programas pontuais (PERSE, PERT, PRR).
**Ative quando:**
- Cliente tem débitos federais e não tem caixa para pagar à vista
- Quer trocar dívida cara por dívida estruturada com Selic
- Quer aproveitar descontos da PGFN em transação tributária

**Entrega:** Simulação de cenários (à vista vs ordinário vs transação) + adesão passo a passo + DARFs mensais
**Invocar:** `"use o agente parcelamento-receita-federal para simular as opções de parcelamento de R$ [valor] de [tipo de débito] da empresa [nome]"`

---

### 56 — Resposta a Fiscalização
**Slug:** `resposta-fiscalizacao-intimacao`
**O que faz:** Resposta a fiscalização federal/estadual/municipal — TIF (20 dias), Auto de Infração (30 dias para impugnar ao DRJ), Despacho Decisório (30 dias), Aviso de Lançamento. Levanta decadência (CTN 173), prescrição (CTN 174), denúncia espontânea (CTN 138 — sem multa antes da fiscalização) e redução de multa qualificada (150% → 75% sem dolo).
**Ative quando:**
- Empresa recebeu MPF, TIF, auto de infração, despacho decisório ou aviso de lançamento
- Precisa pedir prorrogação de prazo
- Prepara impugnação ao DRJ ou recurso ao CARF

**Entrega:** Minuta de resposta com fundamentação legal + cronograma de prazos + protocolo de envio via e-CAC
**Invocar:** `"use o agente resposta-fiscalizacao-intimacao para responder o auto de infração [número] de [data] contra a empresa [nome]"`

---

### 7M · Reforma Tributária (57)

---

### 57 — Reforma Tributária — CBS/IBS
**Slug:** `reforma-tributaria-cbs-ibs`
**O que faz:** Especialista na Reforma Tributária sobre o Consumo (EC 132/2023 + LC 214/2025) — CBS (substitui PIS/COFINS/IPI), IBS (substitui ICMS/ISS), Imposto Seletivo (IS), regime de transição 2026-2032, regimes diferenciados (saúde, educação, transporte coletivo, agro), não-cumulatividade ampla com crédito financeiro, cashback, split payment e Comitê Gestor do IBS.
**Ative quando:**
- Simular impacto da Reforma Tributária no negócio do cliente
- Mencionar CBS, IBS, IS, EC 132, LC 214, split payment, cashback, transição tributária, alíquota teste 2026 (0,9% CBS + 0,1% IBS)
- Cliente quer planejamento tributário para 2026-2033
- Precisa de parecer sobre regime diferenciado

**NÃO use para:** Apuração Simples pré-Reforma (use `01`) · Lucro Real pré-Reforma (use `03`) · ICMS isolado (use `02`) · PIS/COFINS isolado (use `03`)
**Entrega:** Simulação paralela (regime atual × CBS/IBS) por ano de transição em CSV + identificação de regime diferenciado aplicável + matriz de impacto crédito-débito + plano de adequação 2026-2033 + checklist operacional (NF, contabilidade, fluxo de caixa, sistema)
**Invocar:** `"use o agente reforma-tributaria-cbs-ibs para simular o impacto da Reforma no cliente [nome] com faturamento de R$ [valor] e atividade [tipo]"`

---

## Pipelines Recomendados

| Pipeline | Sequência |
|---|---|
| Fechamento mensal completo | `24` → `16` → `38` → `39` → `40` → `41` → `42` → `26` |
| Folha CLT mensal | `35` → `11` → `14` → `10` (S-1200) → `09` (R-4010) → `08` |
| Abertura de empresa | `52` → `36` → `22` |
| Fiscalização recebida | `48` → `46` → `56` |
| Planejamento tributário anual | `44` → `03` → `04` → `05` |
| Recuperação fiscal retroativa | `45` → `46` |
| Due diligence M&A | `49` → `50` |
| Transição Reforma Tributária | `57` → `44` → ajuste do `36` |
| Onboarding cliente novo | `22` → `36` → `25` |

---

## Estrutura de Pastas

Todos os 57 agentes (01 a 57) estão em:

```
57 Agents/
└── MODELOS/
    ├── 01-apuracao-simples-nacional/
    │   ├── 01-apuracao-simples-nacional.md
    │   └── COMO-INSTALAR.md
    ├── 02-icms-iss/
    │   └── ...
    └── ... (57-reforma-tributaria-cbs-ibs)
```

Para instalar todos em uma sessão global do Claude Code, copie os `.md` principais para `~/.claude/agents/` (Mac/Linux) ou `%USERPROFILE%\.claude\agents\` (Windows). Para verificar os agentes ativos na sessão atual, use `/agents`.
