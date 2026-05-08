# analise-tributaria-regime — Agente Claude Code

Subagente especialista do pacote **57 Agents Contabilidade** (Bravy / ASV Digital).

## O que esse agente faz

Veja o arquivo `44-analise-tributaria-regime.md` (descricao completa, frameworks dominados, tabelas de referencia e fluxo operacional).

## Como instalar

### Pre-requisitos

- [Claude Code](https://docs.claude.com/claude-code) instalado e logado
- Terminal com `unzip`

### Instalacao em 30 segundos

**1. Descompacte este zip:**

```bash
unzip 44-analise-tributaria-regime.zip
```

**2. Copie o agente para o seu projeto Claude Code:**

```bash
mkdir -p .claude/agents
cp 44-analise-tributaria-regime.md .claude/agents/

# OU para uso em TODOS os projetos (global):
mkdir -p ~/.claude/agents
cp 44-analise-tributaria-regime.md ~/.claude/agents/
```

**3. Reinicie o Claude Code** (saia com `/exit` e abra de novo).

**4. Pronto.** Confirme com `/agents`. Voce deve ver `analise-tributaria-regime` na lista.

## Como usar

### Modo automatico (recomendado)

Ele e acionado sozinho quando voce descreve uma tarefa que bate com a especialidade dele.

### Modo manual

```
> use o agente analise-tributaria-regime para [tarefa]
```

## Boas praticas

- **Contexto e tudo.** Quanto mais dados (numeros, datas, nomes), melhor a entrega.
- **Nao revise voce mesmo.** O agente entrega rascunho profissional — sua revisao final e obrigatoria antes de transmitir / declarar / pagar.
- **Combine agentes.** Esse agente do pacote `57 Agents Contabilidade` funciona em pipeline com os outros 56. Veja o catalogo completo em `https://github.com/asv-digital/agents-contabilidade`.

## Suporte

- Pacote completo: https://github.com/asv-digital/agents-contabilidade
- Suporte: produtos@asv.digital

## Licenca

Uso permitido para clientes ASV Digital / Bravy. Nao redistribuir.
