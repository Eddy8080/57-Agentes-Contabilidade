const { app, BrowserWindow, ipcMain } = require('electron');
const path = require('path');
const pty  = require('@homebridge/node-pty-prebuilt-multiarch');
const fs   = require('fs');
const os   = require('os');

let mainWindow;
let ptyProcess;

// ── Logger ──────────────────────────────────────────────
const LOG_FILE = path.join(__dirname, '..', '57agents-debug.log');

function log(tag, msg) {
  const ts   = new Date().toISOString().replace('T', ' ').slice(0, 23);
  const line = `[${ts}] [${tag}] ${msg}`;
  console.log(line);
  try { fs.appendFileSync(LOG_FILE, line + '\n'); } catch (_) {}
}

// Limpa log antigo ao iniciar (mantém apenas a sessão atual)
try { fs.writeFileSync(LOG_FILE, `=== 57 Agents — ${new Date().toISOString()} ===\n`); } catch (_) {}
// ────────────────────────────────────────────────────────

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1280,
    height: 800,
    minWidth: 960,
    minHeight: 600,
    frame: false,
    backgroundColor: '#0d1117',
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
    },
  });

  mainWindow.loadFile('index.html');
}

function createShell() {
  const isWin = os.platform() === 'win32';
  const shell  = isWin ? 'powershell.exe' : 'bash';
  const args   = isWin ? ['-NoLogo'] : [];

  log('PTY', `Iniciando shell: ${shell} ${args.join(' ')}`);
  log('PTY', `cwd: ${os.homedir()}`);

  ptyProcess = pty.spawn(shell, args, {
    name: 'xterm-256color',
    cols: 120,
    rows: 30,
    cwd: os.homedir(),
    env: {
      ...process.env,
      FORCE_COLOR: '3',
      COLORTERM: 'truecolor',
      TERM: 'xterm-256color',
    },
    useConpty: true,
    handleFlowControl: true
  });

  log('PTY', `Shell PID: ${ptyProcess.pid}`);

  let claudeStarted = false;
  let rawBuffer = '';
  let chunkCount  = 0;

  // Fail-safe: se em 6s a detecção não disparar, tenta mesmo assim
  const failSafeTimeout = setTimeout(() => {
    if (!claudeStarted) {
      claudeStarted = true;
      log('PTY', 'FAILSAFE 6s acionado — prompt não detectado. Enviando claude mesmo assim.');
      log('PTY', `Buffer atual (plain): ${rawBuffer.replace(/\x1b\[[0-9;?]*[a-zA-Z]/g,'').replace(/\x1b[^[\]]/g,'').slice(-200)}`);
      ptyProcess.write('claude\r');
    }
  }, 6000);

  ptyProcess.onData(data => {
    if (mainWindow) mainWindow.webContents.send('terminal-output', data);

    if (!claudeStarted) {
      rawBuffer += data;
      chunkCount++;

      // Loga os primeiros chunks para diagnóstico
      if (chunkCount <= 5) {
        const preview = JSON.stringify(data.slice(0, 120));
        log('PTY', `chunk #${chunkCount} (${data.length}b): ${preview}`);
      } else if (chunkCount === 6) {
        log('PTY', '... (chunks seguintes omitidos do log)');
      }

      // Remove sequências ANSI antes de testar para evitar falso positivo
      const plain = rawBuffer
        .replace(/\x1b\[[0-9;?]*[a-zA-Z]/g, '')
        .replace(/\x1b[^[\]]/g, '');

      const isShellReady =
        /[A-Z]:\\[^\r\n>]*>/.test(plain) ||
        plain.includes('PS C:\\')         ||
        plain.includes('$ ');

      if (isShellReady) {
        claudeStarted = true;
        clearTimeout(failSafeTimeout);
        // Mostra qual padrão casou
        const match = /[A-Z]:\\[^\r\n>]*>/.exec(plain);
        log('PTY', `Prompt detectado! Padrão: "${match ? match[0] : (plain.includes('PS C:\\') ? 'PS C:\\' : '$ ')}"`);
        log('PTY', `Enviando "claude" em 400ms...`);
        setTimeout(() => {
          log('PTY', 'claude enviado ao PTY.');
          ptyProcess.write('claude\r');
        }, 400);
      }
    }
  });

  ptyProcess.onExit(({ exitCode, signal }) => {
    log('PTY', `Shell encerrado — exitCode=${exitCode} signal=${signal}`);
    if (mainWindow) mainWindow.webContents.send('terminal-exit');
  });
}

app.whenReady().then(() => {
  createWindow();
  createShell();
});

app.on('window-all-closed', () => {
  if (ptyProcess) ptyProcess.kill();
  if (process.platform !== 'darwin') app.quit();
});

// Texto digitado no xterm.js → PTY
ipcMain.on('terminal-input', (_event, data) => {
  if (ptyProcess) ptyProcess.write(data);
});

// Redimensionamento do xterm.js → PTY (mantém cols/rows sincronizados)
ipcMain.on('terminal-resize', (_event, { cols, rows }) => {
  if (ptyProcess) ptyProcess.resize(cols, rows);
});

// Retorna slugs instalados em ~/.claude/agents/
ipcMain.handle('get-installed-agents', () => {
  const agentsDir = path.join(os.homedir(), '.claude', 'agents');
  try {
    return fs.readdirSync(agentsDir)
      .filter(f => f.endsWith('.md'))
      .map(f => f.replace('.md', ''));
  } catch {
    return [];
  }
});

// Controles da janela frameless
ipcMain.on('window-minimize', () => mainWindow.minimize());
ipcMain.on('window-maximize', () => {
  mainWindow.isMaximized() ? mainWindow.unmaximize() : mainWindow.maximize();
});
ipcMain.on('window-close', () => mainWindow.close());
