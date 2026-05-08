# 57 Agents Contabilidade — Claude Code para contadores

**57 subagentes especializados** para escritórios contábeis brasileiros, prontos para uso no Claude Code. Cada agente é um especialista em uma rotina específica do escritório — apuração, obrigações acessórias, folha, conciliação, atendimento, operação interna — que atua proativamente quando o contexto da conversa bate com sua especialidade.

## Como instalar (usando os zips desta pasta)

Voce tem **57 zips individuais** + este README. Pode instalar **um a um** (so quem voce vai usar) ou **todos de uma vez**.

### Opcao A — Instalar 1 agente individual

1. Baixe o zip do agente que voce quer (ex: `01-apuracao-simples-nacional.zip`).
2. Descompacte. Dentro tem o `.md` do agente + um `COMO-INSTALAR.md` com o passo a passo.
3. Copie o `.md` para `.claude/agents/` (no seu projeto) ou `~/.claude/agents/` (global).
4. Reinicie o Claude Code (`/exit` e abra de novo). Pronto.

### Opcao B — Instalar todos os 57 de uma vez (terminal)

```bash
cd /caminho/onde/voce/baixou/57-Agents-Contabilidade
mkdir -p ~/.claude/agents
for z in *.zip; do
  unzip -o -j "$z" "*.md" -d ~/.claude/agents/ -x "COMO-INSTALAR.md"
done
```

Reinicie o Claude Code. Confirme com `/agents`.

## Como usar

- **Automatico**: "preciso apurar o DAS de abril/2026 desse cliente" → Claude delega para `apuracao-simples-nacional`.
- **Manual**: "use o agente `tese-repetitiva` para verificar se há tema afetado".
- **Em pipeline**: `cadastro-nf` → `conciliacao-bancaria` → `fechamento-mensal` → `relatorio-mensal` → `cobranca-honorarios`.

## DigIAna — Interface Desktop

**DigIAna** é a interface gráfica do 57 Agents: uma janela Electron frameless que exibe os 57 agentes em cards visuais e integra um terminal PTY real (PowerShell + Claude Code) para uso direto no escritório.

### Como iniciar

```cmd
cd interface
npm start
```

Na primeira vez em uma máquina nova, o terminal pode não aparecer. Isso acontece porque o módulo nativo de PTY (`@homebridge/node-pty-prebuilt-multiarch`) não tem prebuild para Windows e precisa ser compilado. Nesse caso:

```cmd
cd interface
interface\rebuild-native.bat
npm start
```

### Pré-requisitos (compilação nativa)

Necessários apenas se `rebuild-native.bat` precisar ser executado:

| Componente | Versão testada |
|---|---|
| Node.js | v20.x |
| VS2026 BuildTools | v145 — MSVC 14.50.35717 |
| Windows SDK | 10.0.26100.0 |
| Electron | v28.3.3 (ABI 119) |

Download VS BuildTools: `https://aka.ms/vs/18/release/vs_buildtools.exe`
Marcar: **Desktop development with C++** + **Windows 11 SDK 10.0.26100**

### O que a interface faz

1. Abre janela frameless 1280×800 px com os 57 agentes organizados por categoria
2. Spawna um terminal PowerShell embutido (xterm.js + ConPTY)
3. Detecta o prompt do shell e envia `claude` automaticamente (modo prompt direto)
4. Ao clicar em um card → abre painel de detalhe com descrição completa do agente
5. Botão **Enviar ao terminal** abre a janela flutuante e pré-preenche o invokeCmd (sem Enter — o usuário revisa e confirma)
6. Botão **Copiar comando** copia o invokeCmd para a área de transferência
7. Terminal flutuante arrastável, redimensionável, com suporte a copy/paste

### Comportamento do terminal flutuante

- **Posição inicial**: centralizado na tela (900×500 px)
- **Arrastar**: clique e arraste pela barra do título
- **Redimensionar**: alça no canto inferior direito
- **Toggle**: botão "Terminal" no header ou tecla `T`
- **Minimizar**: botão `─` na barra do terminal
- **Fechar (✕)**: oculta o terminal e marca que a próxima sessão deve iniciar com `cls`
- **Limpa tela (cls)**: executado apenas quando o usuário fechou o terminal com ✕ e depois envia um novo card — nunca limpa automaticamente
- **Copy/paste**: `Ctrl+C` com seleção copia; `Ctrl+C` sem seleção interrompe processo; `Ctrl+V` ou clique direito cola

### Estrutura dos arquivos

```
interface/
├── main.js              — Electron main process; spawna o PTY e cria a janela
├── preload.js           — Ponte IPC contextBridge (window.terminal, window.agents, window.windowControls)
├── app.js               — Lógica do renderer; cards, scroll, interação com terminal
├── agents-data.js       — Dados dos 57 agentes (nome, categoria, invokeCmd)
├── index.html           — HTML/CSS da interface
├── rebuild-native.bat   — Compila node-pty do zero para Windows (VS2026)
└── package.json         — Electron v28, xterm v5, node-pty
```

### Log de diagnóstico

O arquivo `57agents-debug.log` (na raiz do projeto) registra toda a execução do PTY. Se o terminal não aparecer, consulte esse arquivo primeiro.

Indicadores de funcionamento correto:
```
[PTY] Iniciando shell: powershell.exe
[PTY] Shell PID: XXXX
[PTY] Prompt detectado! Padrão: "PS C:\..."
[PTY] claude enviado ao PTY
```

### Detalhes técnicos da compilação nativa (node-pty)

O `@homebridge/node-pty-prebuilt-multiarch` v0.11.14 não possui prebuild Windows. A compilação exige quatro ajustes específicos:

1. **Espaço no path**: O source é copiado para `C:\57tmp-pty-build` (sem espaço) antes de compilar — o gyp não processa paths com espaço
2. **VS2026 não detectado**: Usa `@electron/node-gyp` (incluso em `node_modules/@electron/node-gyp/`) que suporta VS2026; o node-gyp padrão só vai até VS2022
3. **GetCommitHash.bat**: Patch em `deps/winpty/src/winpty.gyp` — Windows CMD exige prefixo `.\` para executar `.bat` no diretório atual
4. **DelayImp.lib não encontrado**: Paths das libs MSVC e Windows SDK adicionados explicitamente em `binding.gyp > VCLinkerTool > AdditionalLibraryDirectories`

O script `rebuild-native.bat` aplica todos esses ajustes automaticamente.

---

## Catalogo (57 agentes — alinhados a 6 categorias da rotina do escritório)

### 1 · Apuração & Tributário (5)
- 01 DAS Simples Nacional
- 02 ICMS / ISS
- 03 PIS / COFINS
- 04 IRPJ / CSLL
- 05 Conferência de guia

### 2 · Obrigações Acessórias (5)
- 06 SPED Fiscal (EFD-ICMS-IPI)
- 07 ECF / ECD
- 08 DCTFWeb
- 09 EFD-Reinf
- 10 eSocial

### 3 · Folha & Departamento Pessoal (5)
- 11 Holerite
- 12 Férias e 13º
- 13 Rescisão CLT
- 14 INSS / FGTS
- 15 Admissão

### 4 · Conciliação & Financeiro (4)
- 16 Conciliação bancária
- 17 Cobrança honorários
- 18 DRE mensal
- 19 Fluxo de caixa

### 5 · Atendimento ao Cliente (4)
- 20 Triagem WhatsApp
- 21 Documentos pendentes
- 22 Onboarding cliente
- 23 Follow-up cliente

### 6 · Operação Interna (4)
- 24 Cadastro de NF
- 25 Lembrete de prazo (calendário fiscal)
- 26 Relatório mensal
- 27 Backup do escritório

### 7 · Especializações por área (30)

**Tributário** — 28 MEI · 29 IPI · 30 IRRF folha · 31 Retenções tomador
**Obrigações** — 32 EFD-Contribuições · 33 DIMOB · 34 DMED
**Folha** — 35 Folha de pagamento mensal
**Contábil** — 36 Plano de contas CPC · 37 Lançamentos contábeis padrão
**Conciliação** — 38 Cartões/credenciadora · 39 Fornecedores · 40 Clientes
**Fechamento** — 41 Fechamento mensal · 42 Balancete · 43 Ativo imobilizado/depreciação
**Análise estratégica** — 44 Análise de regime tributário · 45 Recuperação créditos PIS/COFINS · 46 Revisão fiscal/cruzamento SPED
**Malha fina** — 47 PF · 48 PJ
**Consultoria** — 49 Due diligence contábil · 50 Valuation PME
**IR Pessoa Física** — 51 IRPF declaração completa
**Societário** — 52 Abertura empresa · 53 Alteração contratual · 54 Encerramento/baixa
**Contencioso fiscal** — 55 Parcelamento Receita Federal · 56 Resposta a fiscalização
**Reforma Tributária** — 57 CBS / IBS (EC 132/2023)

## Avisos legais

- Os agentes refletem CTN, RIR/2018, IN RFB, LC 87/96, LC 116/2003, LC 123/2006, LC 190/2022, EC 132/2023 (Reforma Tributária), Resolução CFC 1.546/2024 e legislação especial vigentes em 2026.
- Outputs gerados são **rascunhos**; o contador responsável deve revisar e assumir a responsabilidade técnica (CRC, Resolução CFC 1.546/2024).
- Templates e exemplos usam dados fictícios.

## Licenca

Uso permitido para clientes ASV Digital / Bravy. Nao redistribuir sem autorizacao.
