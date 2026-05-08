# Interface Desktop — 57 Agents Contabilidade

> **Regra inviolável:** nenhum dos 57 agentes será reprogramado ou modificado durante a construção desta interface. A interface é camada de apresentação apenas.

---

## Visão Geral

App desktop Electron com interface HTML + CSS + JS que:

1. Ao abrir, inicia `claude` automaticamente no terminal embutido
2. Exibe os 57 agentes como cards clicáveis organizados por categoria
3. Ao clicar num card, abre painel de detalhe com o conteúdo de `como_usar.md` formatado visualmente
4. Botão "Enviar ao terminal" manda o comando de invocação direto ao terminal embutido
5. Usuário edita os parâmetros `[nome]`, `[mês/ano]` no terminal e pressiona Enter

A interface não altera, não substitui e não reescreve nenhum agente.

---

## Arquitetura de Arquivos

```
57 Agents/
├── agentes.md                ← este documento (plano de construção)
├── interface/
│   ├── package.json          ← dependências Electron
│   ├── main.js               ← processo principal Electron (janela, terminal PTY)
│   ├── preload.js            ← bridge segura entre Electron e interface
│   ├── index.html            ← estrutura principal da interface
│   ├── styles.css            ← visual dark theme, grid, cards, painel detalhe
│   ├── app.js                ← lógica: cards, filtro, busca, detalhe, terminal
│   └── agents-data.js        ← dados dos 57 agentes (extraídos de como_usar.md)
├── como_usar.md              ← fonte de dados do painel de detalhe (não modificar)
├── all_contents.json         ← fonte auxiliar de dados (não modificar)
├── MODELOS/                  ← agentes .md (não modificar)
└── README.md                 ← documentação de instalação (não modificar)
```

---

## Layout da Interface

```
┌────────────────────────────────────────────────────────────────┐
│  57 Agents Contabilidade                    ● 57 carregados   │
├──────────┬─────────────────────────────────────────────────────┤
│ SIDEBAR  │  GRID DE CARDS (7 categorias)                      │
│          │                                                     │
│ [Todos]  │  ── Apuração & Tributário ──────────────────────   │
│ Cat 1 ●  │  [01 DAS Simples] [02 ICMS/ISS] [03 PIS/COFINS]   │
│ Cat 2    │  [04 IRPJ/CSLL]   [05 Conf.Guia]                  │
│ Cat 3    │                                                     │
│ Cat 4    │  ── Obrigações Acessórias ──────────────────────   │
│ Cat 5    │  [06 SPED]  [07 ECF/ECD]  [08 DCTFWeb] ...        │
│ Cat 6    │                                                     │
│ Cat 7    │  ... (demais categorias)                           │
│          │                                                     │
│ [Busca]  │                                                     │
├──────────┴─────────────────────────────────────────────────────┤
│  TERMINAL INTEGRADO (xterm.js)                                 │
│  $ claude                                                      │
│  > █                                                           │
└────────────────────────────────────────────────────────────────┘
```

Ao clicar num card, o painel de detalhe desliza sobre o grid (sem fechar o terminal):

```
┌─────────────────────────────────────────────────┐
│  01 — DAS Simples Nacional          [X fechar]  │
│  slug: apuracao-simples-nacional                │
│  ● Apuração & Tributário                        │
├─────────────────────────────────────────────────┤
│  O QUE FAZ                                      │
│  Apuração mensal do DAS para empresas           │
│  optantes pelo Simples Nacional...              │
├─────────────────────────────────────────────────┤
│  QUANDO ACIONAR                                 │
│  ✓ Enviar faturamento de empresa optante        │
│  ✓ Mencionar PGDAS-D, alíquota efetiva, RBT12  │
│  ✓ Pedir conferência de DAS gerado              │
├─────────────────────────────────────────────────┤
│  NÃO USE PARA                                   │
│  ✗ MEI — use apuracao-mei                       │
├─────────────────────────────────────────────────┤
│  O QUE ENTREGA                                  │
│  • Tabela de receitas segregadas                │
│  • Cálculo Python passo a passo                 │
│  • DAS por anexo + memória CSV                  │
├─────────────────────────────────────────────────┤
│  COMO INVOCAR                                   │
│  "use o agente apuracao-simples-nacional        │
│   para apurar o DAS de [mês/ano] do             │
│   cliente [nome]"                               │
│                                                 │
│  [Copiar comando]  [Enviar ao terminal ↓]       │
└─────────────────────────────────────────────────┘
```

---

## Etapas de Construção

### Etapa 1 — agents-data.js (dados dos 57 agentes)

**Fonte:** `como_usar.md` — parse do arquivo para extrair por agente:
- `id` — número (01–57)
- `slug` — ex: `apuracao-simples-nacional`
- `name` — ex: `DAS Simples Nacional`
- `category` — número 1–7
- `categoryName` — nome da categoria
- `description` — primeira linha do "O que faz" (resumo para o card)
- `whatItDoes` — texto completo do "O que faz"
- `triggerWhen` — array de strings do "Ative quando"
- `notFor` — array de strings do "NÃO use para"
- `delivery` — array de strings do "Entrega"
- `invokeCmd` — string do "Invocar"

**Entrega:** `interface/agents-data.js` com `const AGENTS_DATA = [...]` de 57 objetos.

---

### Etapa 2 — package.json + main.js + preload.js (Electron)

**package.json** — dependências mínimas:
- `electron` — app desktop
- `node-pty` — PTY real para o terminal embutido
- `xterm` — renderizador do terminal na interface

**main.js** — processo principal:
- Cria a janela Electron (sem barra de título nativa — frameless com controles customizados)
- Cria processo PTY conectado ao PowerShell
- Abre automaticamente com `claude` ao iniciar
- Detecta agentes instalados em `%USERPROFILE%\.claude\agents\` e passa para a interface

**preload.js** — bridge segura (contextBridge):
- Expõe `window.terminal.send(texto)` — envia texto ao PTY
- Expõe `window.terminal.onData(callback)` — recebe output do PTY
- Expõe `window.agents.getInstalled()` — lista de slugs instalados

**Entrega:** `interface/package.json`, `interface/main.js`, `interface/preload.js`

---

### Etapa 3 — index.html (estrutura)

Estrutura HTML com:
- Header: logo + título + contador de agentes + controles de janela (minimizar, maximizar, fechar)
- Sidebar: botões de categoria + campo de busca
- Grid principal: área de cards organizada por categoria
- Painel de detalhe: overlay deslizante com todas as seções do agente
- Terminal: seção inferior com o xterm.js montado

**Entrega:** `interface/index.html`

---

### Etapa 4 — styles.css (visual)

**Tema dark:**
- Fundo: `#0d1117` / Cards: `#161b22` / Sidebar: `#010409`
- Destaque: `#58a6ff`
- Fonte: `Inter` ou `system-ui`

**Cores por categoria (badge no card):**
| Cat | Nome | Cor |
|-----|------|-----|
| 1 | Apuração & Tributário | `#f78166` vermelho |
| 2 | Obrigações Acessórias | `#d2a8ff` lilás |
| 3 | Folha & DP | `#79c0ff` azul claro |
| 4 | Conciliação & Financeiro | `#56d364` verde |
| 5 | Atendimento ao Cliente | `#ffa657` laranja |
| 6 | Operação Interna | `#e3b341` amarelo |
| 7 | Especializações | `#8b949e` cinza |

**Estados do card:**
- Normal: borda `#30363d`
- Hover: elevação + borda `#58a6ff` suave
- Selecionado: fundo `#1f2937` + borda `#58a6ff` sólida
- Instalado: badge verde "● instalado"
- Não instalado: opacidade 60% + badge "não instalado"

**Painel de detalhe:** desliza da direita, largura 420px, seções com fundo levemente diferente

**Terminal:** altura fixa 200px, fundo `#010409`, fonte monospace

**Entrega:** `interface/styles.css`

---

### Etapa 5 — app.js (lógica)

1. **init:** monta os cards progressivamente com animação de entrada; marca instalados vs não instalados
2. **renderCards:** gera HTML dos cards por categoria a partir de `AGENTS_DATA`
3. **filterByCategory:** filtra o grid pela categoria da sidebar
4. **searchAgents:** busca em tempo real por nome, slug ou descrição
5. **showDetail:** abre painel com todas as seções do agente selecionado, formatadas
6. **sendToTerminal:** ao clicar "Enviar ao terminal", chama `window.terminal.send(invokeCmd)` e fecha o painel
7. **copyCommand:** copia o `invokeCmd` para o clipboard + toast "Copiado!"
8. **terminalInit:** monta o xterm.js na div do terminal e conecta ao PTY via `window.terminal.onData`

**Entrega:** `interface/app.js`

---

### Etapa 6 — Pipelines (seção extra)

Seção "Pipelines Recomendados" com os 9 fluxos como sequência visual de círculos numerados conectados por setas. Clicar num número do pipeline abre o detalhe daquele agente.

**Entrega:** seção adicionada ao `index.html` + estilos + lógica em `app.js`

---

## Regras de Construção

1. `como_usar.md` e todos os `.md` de agentes são somente leitura
2. `all_contents.json` é auxiliar — fonte principal é `como_usar.md`
3. Sem frameworks CSS (sem Bootstrap, sem Tailwind) — CSS puro
4. Sem frameworks JS (sem React, sem Vue) — JS puro
5. Electron é a única dependência npm
6. O terminal embutido abre com `claude` automaticamente ao iniciar o app

---

## Status das Etapas

| Etapa | Descrição | Status |
|---|---|---|
| 1 | agents-data.js — parse de como_usar.md | ✅ Concluída |
| 2 | package.json + main.js + preload.js (Electron) | ✅ Concluída |
| 3 | index.html — estrutura completa | ✅ Concluída |
| 4 | styles.css — dark theme + cores por categoria | ✅ Concluída |
| 5 | app.js — lógica completa + terminal | ✅ Concluída |
| 6 | Pipelines recomendados | Pendente |

---

*Próxima etapa: confirmar arquitetura e iniciar Etapa 1.*
