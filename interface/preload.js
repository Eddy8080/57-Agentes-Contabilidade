const { contextBridge, ipcRenderer } = require('electron');

// Bridge segura: expõe apenas o necessário para a interface HTML
// Sem acesso direto ao Node.js pelo renderer (contextIsolation: true)

contextBridge.exposeInMainWorld('terminal', {
  send:   (data)         => ipcRenderer.send('terminal-input', data),
  resize: (cols, rows)   => ipcRenderer.send('terminal-resize', { cols, rows }),
  onData: (callback)     => ipcRenderer.on('terminal-output', (_e, d) => callback(d)),
  onExit: (callback)     => ipcRenderer.on('terminal-exit',   () => callback()),
});

contextBridge.exposeInMainWorld('agents', {
  // Retorna array de slugs instalados em ~/.claude/agents/
  // Ex: ["apuracao-simples-nacional", "icms-iss", ...]
  getInstalled: () => ipcRenderer.invoke('get-installed-agents'),
});

contextBridge.exposeInMainWorld('windowControls', {
  minimize: () => ipcRenderer.send('window-minimize'),
  maximize: () => ipcRenderer.send('window-maximize'),
  close:    () => ipcRenderer.send('window-close'),
  setTheme: (theme) => ipcRenderer.send('set-theme', theme),
});
