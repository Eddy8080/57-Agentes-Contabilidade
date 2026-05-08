(function () {
  'use strict';

  // ═══════════════════════════════════════════════════════
  // ESTADO GLOBAL
  // ═══════════════════════════════════════════════════════
  let installedSlugs  = [];   // slugs presentes em ~/.claude/agents/
  let activeCategory  = 0;    // 0 = todos
  let searchTerm      = '';
  let selectedAgent    = null;
  let termInstance     = null;  // xterm.js Terminal
  let fitAddon         = null;
  let termVisible      = false;
  let termMinimized    = false;
  let termNeedsCls     = false;  // true quando usuário fecha com ✕
  let termOpened       = false;  // true após o primeiro open() do xterm
  let toastTimer       = null;


  // ═══════════════════════════════════════════════════════
  // INICIALIZAÇÃO
  // ═══════════════════════════════════════════════════════
  async function init() {
    updateStatus('Carregando agentes...', false);

    // Tenta detectar agentes instalados em ~/.claude/agents/
    if (window.agents) {
      try {
        installedSlugs = await window.agents.getInstalled();
      } catch (_) {
        installedSlugs = [];
      }
    }

    renderCards(AGENTS_DATA);
    initTerminal();
    bindEvents();

    setTimeout(() => updateStatus('Pronto — Escolha um card', true), 5000);
  }


  // ═══════════════════════════════════════════════════════
  // RENDERIZAÇÃO DOS CARDS
  // ═══════════════════════════════════════════════════════
  function renderCards(agents) {
    const container = document.getElementById('cards-container');
    container.innerHTML = '';

    if (agents.length === 0) {
      container.innerHTML = `
        <div id="cards-empty">
          <svg width="32" height="32" viewBox="0 0 16 16" fill="none">
            <circle cx="8" cy="8" r="6.5" stroke="#484f58" stroke-width="1.2"/>
            <path d="M5.5 5.5l5 5M10.5 5.5l-5 5"
                  stroke="#484f58" stroke-width="1.2" stroke-linecap="round"/>
          </svg>
          Nenhum agente encontrado
        </div>`;
      return;
    }

    // Agrupa por categoria mantendo ordem numérica
    const groups = {};
    agents.forEach(agent => {
      if (!groups[agent.category]) {
        groups[agent.category] = { name: agent.categoryName, agents: [] };
      }
      groups[agent.category].agents.push(agent);
    });

    let delay = 0;
    Object.keys(groups)
      .sort((a, b) => a - b)
      .forEach(cat => {
        const group = groups[cat];
        const groupEl = document.createElement('div');
        groupEl.className = 'category-group';

        // Título do grupo — exibe sempre (facilita leitura)
        const catColor = getCatColor(parseInt(cat));
        const titleEl = document.createElement('div');
        titleEl.className = 'category-group-title';
        titleEl.innerHTML = `
          <span class="cat-dot" style="background:${catColor}"></span>
          ${escHtml(group.name)}
          <span style="color:var(--text-muted);font-weight:400;margin-left:4px">
            (${group.agents.length})
          </span>`;
        groupEl.appendChild(titleEl);

        // Grid de cards
        const grid = document.createElement('div');
        grid.className = 'cards-grid';
        group.agents.forEach(agent => {
          grid.appendChild(buildCard(agent, delay));
          delay += 20;
        });

        groupEl.appendChild(grid);
        container.appendChild(groupEl);
      });
  }

  function buildCard(agent, delayMs) {
    const installed = installedSlugs.length === 0
      || installedSlugs.includes(agent.slug);

    const card = document.createElement('div');
    card.className = 'agent-card' + (installed ? '' : ' not-installed');
    card.dataset.id = agent.id;
    card.style.animationDelay = `${delayMs}ms`;

    const statusBadge = installedSlugs.length > 0
      ? (installed
          ? `<span class="badge-installed">● instalado</span>`
          : `<span class="badge-not-installed">○ não instalado</span>`)
      : '';

    // Rótulo curto da categoria (antes do "&")
    const catShort = agent.categoryName.split('&')[0].trim();

    card.innerHTML = `
      <div class="card-header">
        <span class="card-number">${String(agent.id).padStart(2, '0')}</span>
        <div class="card-badges">
          <span class="badge-cat" data-cat="${agent.category}">${escHtml(catShort)}</span>
          ${statusBadge}
        </div>
      </div>
      <div class="card-name">${escHtml(agent.name)}</div>
      <div class="card-description">${escHtml(agent.description)}</div>`;

    card.addEventListener('click', () => {
      showDetail(agent);
    });
    return card;
  }


  // ═══════════════════════════════════════════════════════
  // FILTRO POR CATEGORIA
  // ═══════════════════════════════════════════════════════
  function filterByCategory(cat) {
    activeCategory = cat;
    // Limpa busca ao trocar de categoria
    searchTerm = '';
    document.getElementById('search-input').value = '';
    document.getElementById('search-clear').classList.add('hidden');

    const filtered = cat === 0
      ? AGENTS_DATA
      : AGENTS_DATA.filter(a => a.category === cat);

    renderCards(filtered);
    closeDetail();
  }


  // ═══════════════════════════════════════════════════════
  // BUSCA EM TEMPO REAL
  // ═══════════════════════════════════════════════════════
  function searchAgents(term) {
    searchTerm = term.toLowerCase().trim();
    document.getElementById('search-clear')
      .classList.toggle('hidden', !term);

    // Parte do subset da categoria ativa
    const base = activeCategory === 0
      ? AGENTS_DATA
      : AGENTS_DATA.filter(a => a.category === activeCategory);

    if (!searchTerm) {
      renderCards(base);
      return;
    }

    const filtered = base.filter(a =>
      a.name.toLowerCase().includes(searchTerm)       ||
      a.slug.toLowerCase().includes(searchTerm)       ||
      a.description.toLowerCase().includes(searchTerm)||
      a.whatItDoes.toLowerCase().includes(searchTerm)
    );

    renderCards(filtered);
  }


  // ═══════════════════════════════════════════════════════
  // PAINEL DE DETALHE
  // ═══════════════════════════════════════════════════════
  function showDetail(agent) {
    selectedAgent = agent;

    // Destaca o card clicado
    document.querySelectorAll('.agent-card').forEach(c =>
      c.classList.toggle('selected', parseInt(c.dataset.id) === agent.id)
    );

    // Número e nome
    document.getElementById('detail-number').textContent =
      `Agente ${String(agent.id).padStart(2, '0')}`;
    document.getElementById('detail-name').textContent    = agent.name;
    document.getElementById('detail-slug').textContent    = agent.slug;

    // Badge de categoria
    const badge = document.getElementById('detail-category-badge');
    badge.textContent  = agent.categoryName;
    badge.dataset.cat  = agent.category;
    badge.className    = 'badge-cat';
    badge.style.fontSize    = '10px';
    badge.style.display     = 'inline-block';
    badge.style.marginTop   = '2px';

    // O que faz
    document.getElementById('detail-what').textContent = agent.whatItDoes;

    // Listas
    fillList('detail-trigger',  agent.triggerWhen);
    fillList('detail-notfor',   agent.notFor);
    fillList('detail-delivery', agent.delivery);

    // Oculta seção "não usar" se vazia
    document.getElementById('detail-notfor-section')
      .classList.toggle('hidden', agent.notFor.length === 0);

    // Comando de invocação
    document.getElementById('detail-invoke-text').textContent =
      `"${agent.invokeCmd}"`;

    // Exibe o painel
    document.getElementById('detail-panel').classList.remove('hidden');
  }

  function closeDetail() {
    selectedAgent = null;
    document.getElementById('detail-panel').classList.add('hidden');
    document.querySelectorAll('.agent-card.selected')
      .forEach(c => c.classList.remove('selected'));
  }

  function fillList(id, items) {
    const ul = document.getElementById(id);
    ul.innerHTML = items.map(i => `<li>${escHtml(i)}</li>`).join('');
  }


  // ═══════════════════════════════════════════════════════
  // COPIAR COMANDO
  // ═══════════════════════════════════════════════════════
  function copyCommand() {
    if (!selectedAgent) return;
    navigator.clipboard
      .writeText(`"${selectedAgent.invokeCmd}"`)
      .then(() => showToast('Comando copiado!'));
  }


  // ═══════════════════════════════════════════════════════
  // ENVIAR AO TERMINAL
  // ═══════════════════════════════════════════════════════
  function sendToTerminal() {
    if (!selectedAgent || !window.terminal) return;

    const wasVisible = termVisible;
    const cmd        = selectedAgent.invokeCmd; // captura ANTES do closeDetail()
    termNeedsCls = false;

    showTerminal();
    closeDetail(); // zera selectedAgent — cmd já está salvo acima
    showToast('Comando enviado ao terminal ↓');

    if (wasVisible) {
      // Ctrl+C interrompe geração em andamento; /clear limpa a tela dentro do Claude Code
      window.terminal.send('\x03');
      setTimeout(() => {
        window.terminal.send('\r/clear\r');
        setTimeout(() => {
          window.terminal.send(cmd);
          if (termInstance) termInstance.focus();
        }, 600);
      }, 250);
    } else {
      // Terminal estava oculto → aguarda animação de abertura
      setTimeout(() => {
        window.terminal.send(cmd);
        if (termInstance) termInstance.focus();
      }, 300);
    }
  }


  // ═══════════════════════════════════════════════════════
  // SHOW / HIDE / MINIMIZE DO TERMINAL FLUTUANTE
  // ═══════════════════════════════════════════════════════
  function showTerminal() {
    if (termVisible) return;
    termVisible   = true;
    termMinimized = false;
    const el = document.getElementById('terminal-float');
    el.classList.remove('hidden', 'minimized');
    document.getElementById('btn-terminal-toggle').classList.add('active');
    document.getElementById('tf-minimize').textContent = '─';
    document.getElementById('tf-minimize').title = 'Minimizar';

    if (!termOpened && termInstance) {
      termOpened = true;
      termInstance.open(document.getElementById('xterm-mount'));

      // Copiar / Colar — configurado após open()
      termInstance.attachCustomKeyEventHandler(e => {
        if (e.type !== 'keydown') return true;
        if (e.ctrlKey && !e.shiftKey && e.key === 'c') {
          if (termInstance.hasSelection()) {
            navigator.clipboard.writeText(termInstance.getSelection()).catch(() => {});
            showToast('Texto copiado!');
            return false;
          }
          return true; // sem seleção → ^C vai ao PTY (interrompe agente)
        }
        if (e.ctrlKey && e.shiftKey && e.key === 'C') {
          if (termInstance.hasSelection()) {
            navigator.clipboard.writeText(termInstance.getSelection()).catch(() => {});
            showToast('Texto copiado!');
          }
          return false;
        }
        if (e.ctrlKey && (e.key === 'v' || e.key === 'V')) {
          navigator.clipboard.readText().then(text => {
            if (text && window.terminal) window.terminal.send(text);
          }).catch(() => {});
          return false;
        }
        return true;
      });

      document.getElementById('xterm-mount').addEventListener('contextmenu', e => {
        e.preventDefault();
        navigator.clipboard.readText().then(text => {
          if (text && window.terminal) window.terminal.send(text);
        }).catch(() => {});
      });
    }

    // Fit após o elemento estar visível e renderizado
    setTimeout(() => {
      if (fitAddon) fitAddon.fit();
      if (window.terminal && termInstance)
        window.terminal.resize(termInstance.cols, termInstance.rows);
      if (termInstance) termInstance.focus();
    }, 80);
  }

  function hideTerminal(byUser = false) {
    termVisible   = false;
    termMinimized = false;
    if (byUser) termNeedsCls = true;
    document.getElementById('terminal-float').classList.add('hidden');
    document.getElementById('btn-terminal-toggle').classList.remove('active');
  }

  function toggleTerminalVisible() {
    termVisible ? hideTerminal() : showTerminal();
  }

  function minimizeTerminal() {
    termMinimized = !termMinimized;
    const el  = document.getElementById('terminal-float');
    const btn = document.getElementById('tf-minimize');
    el.classList.toggle('minimized', termMinimized);
    btn.textContent = termMinimized ? '□' : '─';
    btn.title       = termMinimized ? 'Restaurar' : 'Minimizar';
    if (!termMinimized) {
      setTimeout(() => {
        if (fitAddon) fitAddon.fit();
        if (window.terminal && termInstance)
          window.terminal.resize(termInstance.cols, termInstance.rows);
      }, 10);
    }
  }


  // ═══════════════════════════════════════════════════════
  // DRAG & RESIZE DO TERMINAL FLUTUANTE
  // ═══════════════════════════════════════════════════════
  function initDrag(handle, target) {
    let dragging = false, ox = 0, oy = 0;

    handle.addEventListener('mousedown', e => {
      if (e.target.closest('.tf-btn')) return;
      dragging = true;
      const r = target.getBoundingClientRect();
      // Converte para left/top absoluto (remove inset/margin/transform de centralização)
      target.style.left      = r.left + 'px';
      target.style.top       = r.top  + 'px';
      target.style.right     = 'auto';
      target.style.bottom    = 'auto';
      target.style.margin    = '0';
      target.style.transform = 'none';
      ox = e.clientX - r.left;
      oy = e.clientY - r.top;
      document.addEventListener('mousemove', onMove);
      document.addEventListener('mouseup',   onUp);
      e.preventDefault();
    });

    function onMove(e) {
      if (!dragging) return;
      target.style.left = Math.max(0, e.clientX - ox) + 'px';
      target.style.top  = Math.max(0, e.clientY - oy) + 'px';
    }

    function onUp() {
      dragging = false;
      document.removeEventListener('mousemove', onMove);
      document.removeEventListener('mouseup',   onUp);
    }
  }

  function initResize(handle, target) {
    let resizing = false, sx = 0, sy = 0, sw = 0, sh = 0;

    handle.addEventListener('mousedown', e => {
      resizing = true;
      const r = target.getBoundingClientRect();
      sx = e.clientX; sy = e.clientY;
      sw = r.width;   sh = r.height;
      document.addEventListener('mousemove', onMove);
      document.addEventListener('mouseup',   onUp);
      e.preventDefault();
    });

    function onMove(e) {
      if (!resizing) return;
      target.style.width  = Math.max(360, sw + (e.clientX - sx)) + 'px';
      target.style.height = Math.max(160, sh + (e.clientY - sy)) + 'px';
      if (fitAddon) fitAddon.fit();
      if (window.terminal && termInstance)
        window.terminal.resize(termInstance.cols, termInstance.rows);
    }

    function onUp() {
      resizing = false;
      document.removeEventListener('mousemove', onMove);
      document.removeEventListener('mouseup',   onUp);
    }
  }


  // ═══════════════════════════════════════════════════════
  // TERMINAL XTERM.JS
  // ═══════════════════════════════════════════════════════
  function initTerminal() {
    if (typeof Terminal === 'undefined') return;

    termInstance = new Terminal({
      fontFamily: "'Cascadia Code', 'Consolas', 'Courier New', monospace",
      fontSize:   12,
      lineHeight: 1.35,
      cursorBlink: true,
      cursorStyle: 'bar',
      scrollback:  3000,
      allowTransparency: true,
      theme: {
        background:      '#010409',
        foreground:      '#e6edf3',
        cursor:          '#58a6ff',
        cursorAccent:    '#0d1117',
        selectionBackground: 'rgba(88,166,255,0.25)',
        black:   '#484f58', red:     '#ff7b72',
        green:   '#3fb950', yellow:  '#d29922',
        blue:    '#58a6ff', magenta: '#bc8cff',
        cyan:    '#39c5cf', white:   '#b1bac4',
        brightBlack:   '#6e7681', brightRed:     '#ffa198',
        brightGreen:   '#56d364', brightYellow:  '#e3b341',
        brightBlue:    '#79c0ff', brightMagenta: '#d2a8ff',
        brightCyan:    '#56d4dd', brightWhite:   '#f0f6fc',
      },
    });

    // FitAddon — xterm-addon-fit expõe window.FitAddon.FitAddon no UMD
    const FitClass = window.FitAddon
      ? (window.FitAddon.FitAddon || window.FitAddon)
      : null;
    if (FitClass) {
      fitAddon = new FitClass();
      termInstance.loadAddon(fitAddon);
    }

    // PTY → xterm (output) e xterm → PTY (input)
    if (window.terminal) {
      window.terminal.onData(data => { if (termInstance) termInstance.write(data); });
      window.terminal.onExit(() => {
        if (termInstance) termInstance.write('\r\n\x1b[33m⚡ Sessão encerrada.\x1b[0m\r\n');
        updateStatus('Sessão encerrada', false);
      });
    }

    termInstance.onData(data => {
      if (window.terminal) window.terminal.send(data);
    });

    // Drag e resize (não dependem de open())
    initDrag(document.getElementById('tf-header'),         document.getElementById('terminal-float'));
    initResize(document.getElementById('tf-resize-handle'), document.getElementById('terminal-float'));

    // Refaz fit ao redimensionar (só após open)
    new ResizeObserver(() => {
      if (!fitAddon || !termOpened) return;
      fitAddon.fit();
      if (window.terminal) window.terminal.resize(termInstance.cols, termInstance.rows);
    }).observe(document.getElementById('tf-body'));

    // open() é feito em showTerminal() na primeira exibição (lazy open)
    // — evita fit() em elemento display:none que quebraria as dimensões do PTY
  }




  // ═══════════════════════════════════════════════════════
  // STATUS DO HEADER
  // ═══════════════════════════════════════════════════════
  function updateStatus(text, ready) {
    document.getElementById('status-text').textContent = text;
    document.getElementById('status-dot').className =
      ready ? 'dot-ready' : 'dot-loading';
  }


  // ═══════════════════════════════════════════════════════
  // TOAST
  // ═══════════════════════════════════════════════════════
  function showToast(msg) {
    const el = document.getElementById('toast');
    el.textContent = msg;
    el.classList.remove('hidden');
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => el.classList.add('hidden'), 1800);
  }


  // ═══════════════════════════════════════════════════════
  // UTILITÁRIOS
  // ═══════════════════════════════════════════════════════
  function escHtml(str) {
    return String(str)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  }

  function getCatColor(cat) {
    const map = {
      1:'#f78166', 2:'#d2a8ff', 3:'#79c0ff',
      4:'#56d364', 5:'#ffa657', 6:'#e3b341', 7:'#8b949e'
    };
    return map[cat] || '#8b949e';
  }


  // ═══════════════════════════════════════════════════════
  // EVENT LISTENERS
  // ═══════════════════════════════════════════════════════
  function bindEvents() {
    // Botões de categoria
    document.querySelectorAll('.cat-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        document.querySelectorAll('.cat-btn')
          .forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        filterByCategory(parseInt(btn.dataset.cat));
      });
    });

    // Campo de busca
    document.getElementById('search-input')
      .addEventListener('input', e => searchAgents(e.target.value));

    // Limpar busca
    document.getElementById('search-clear').addEventListener('click', () => {
      document.getElementById('search-input').value = '';
      searchAgents('');
      document.getElementById('search-input').focus();
    });

    // Fechar painel de detalhe
    document.getElementById('detail-close')
      .addEventListener('click', closeDetail);

    // Botões de ação do painel
    document.getElementById('btn-copy')
      .addEventListener('click', copyCommand);
    document.getElementById('btn-send')
      .addEventListener('click', sendToTerminal);

    // Controles do terminal flutuante
    document.getElementById('btn-terminal-toggle')
      .addEventListener('click', toggleTerminalVisible);
    document.getElementById('tf-minimize')
      .addEventListener('click', minimizeTerminal);
    document.getElementById('tf-close-btn')
      .addEventListener('click', () => hideTerminal(true));

    // Esc: fecha painel detalhe | T: toggle terminal
    document.addEventListener('keydown', e => {
      if (e.key === 'Escape') { closeDetail(); return; }
      if ((e.key === 't' || e.key === 'T') && document.activeElement.tagName !== 'INPUT') {
        toggleTerminalVisible();
      }
    });
  }


  // ═══════════════════════════════════════════════════════
  // PONTO DE ENTRADA
  // ═══════════════════════════════════════════════════════
  document.addEventListener('DOMContentLoaded', init);

})();
