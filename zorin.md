# Guia de Configuração do Ambiente no Zorin OS (Linux)

Este guia contém o passo a passo exato para configurar e rodar o projeto **57 Agents Contabilidade** no seu ambiente com **Zorin OS**, sincronizando o código via GitHub e os arquivos de dados locais via Google Drive.

---

## 🔗 Informações de Origem

- **Repositório GitHub:** `https://github.com/Eddy8080/57-Agentes-Contabilidade.git`
- **Pasta no Google Drive:** [57_Agents no Google Drive](https://drive.google.com/drive/u/0/folders/1K9yF-hjKinOtmJ6QFhONZQjsnC0d6YdZ)

---

## 📋 Passo a Passo de Execução no Zorin OS

### 1. Clonar o Repositório Git
Abra o terminal no Zorin OS e clone o projeto no seu diretório de projetos (ex: `~/projetos`):

```bash
mkdir -p ~/projetos
cd ~/projetos
git clone https://github.com/Eddy8080/57-Agentes-Contabilidade.git "57 Agents"
cd "57 Agents"
```

---

### 2. Sincronizar Arquivos do Google Drive
Como o seu Zorin OS já está conectado à sua conta do Google Drive via Contas Online do GNOME / Nautilus, os arquivos do Drive estarão montados em `google-drive://` ou no ponto de montagem local.

Você precisa copiar (ou criar link simbólico) dos seguintes arquivos da pasta `57_Agents` do Drive para a raiz do projeto:
- `all_contents.json`
- `manual_57agents.html`
- `agents.html`
- `generate-agents-html.js` *(se aplicável)*

**Opção A — Se a pasta estiver montada localmente no gerenciador de arquivos (Exemplo):**
```bash
# Copiar da pasta sincronizada do Drive para a raiz do repositório
cp "/caminho/do/GoogleDrive/57_Agents/all_contents.json" .
cp "/caminho/do/GoogleDrive/57_Agents/manual_57agents.html" .
cp "/caminho/do/GoogleDrive/57_Agents/agents.html" .
```

**Opção B — Link Simbólico (Recomendado para manter atualizado automaticamente sem copiar):**
```bash
# Cria links diretos para que qualquer alteração no Drive reflita no projeto
ln -s "/caminho/do/GoogleDrive/57_Agents/all_contents.json" ./all_contents.json
ln -s "/caminho/do/GoogleDrive/57_Agents/manual_57agents.html" ./manual_57agents.html
ln -s "/caminho/do/GoogleDrive/57_Agents/agents.html" ./agents.html
```

---

### 3. Instalar Dependências e Módulos Nativos no Zorin OS
No Linux, as dependências com código C++ nativo (como `@homebridge/node-pty-prebuilt-multiarch`) precisam ser instaladas e compiladas para o ambiente Linux x64:

```bash
# 1. Instalar dependências da raiz (se houver)
npm install

# 2. Entrar na pasta da interface e instalar dependências do Electron
cd interface
npm install

# 3. Recompilar módulos nativos para o Electron no Linux
npm run rebuild
```

---

### 4. Executar a Aplicação em Modo de Desenvolvimento
Com as dependências instaladas e os arquivos de dados posicionados:

```bash
# A partir da pasta interface:
npm start

# Ou a partir da raiz do projeto:
# npm start
```

---

## ⚠️ Regras Importantes de Sincronização

1. **Nunca envie `node_modules` ou `venv` para o Google Drive ou GitHub.** Ambos devem ser gerados localmente no Zorin OS.
2. **Atualizações de Código:** Sempre use `git pull` e `git push`.
3. **Atualizações de Dados Locais:** Os arquivos pesados/gerados (`all_contents.json`, etc.) ficam sincronizados de forma transparente via pasta `57_Agents` do Google Drive.
