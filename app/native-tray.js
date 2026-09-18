const path = require('path');
const { app, BrowserWindow, Menu, nativeImage, Tray } = require('electron');

let tray = null;

function getMainWindow() {
  const windows = BrowserWindow.getAllWindows().filter(
    (window) => !window.isDestroyed(),
  );

  return (
    windows.find((window) =>
      /\/pc-dist\/(?:index|login)\.html(?:[?#]|$)/.test(
        window.webContents.getURL(),
      ),
    ) ||
    windows.find((window) => window.isVisible()) ||
    windows[0]
  );
}

function openZalo() {
  const window = getMainWindow();
  if (!window) return;

  if (window.isMinimized()) window.restore();
  if (!window.isVisible()) window.show();
  window.focus();
}

function createTray() {
  if (tray) return tray;

  const iconPath = path.join(__dirname, '..', 'assets', 'Zalo.png');
  const icon = nativeImage.createFromPath(iconPath);

  if (icon.isEmpty()) {
    console.error(`Unable to load tray icon: ${iconPath}`);
    return null;
  }

  tray = new Tray(icon);
  tray.setToolTip('Zalo');
  tray.setContextMenu(
    Menu.buildFromTemplate([
      { label: 'Open Zalo', click: openZalo },
      { type: 'separator' },
      { label: 'Exit', click: () => app.quit() },
    ]),
  );
  tray.on('double-click', openZalo);

  return tray;
}

function setup() {
  app
    .whenReady()
    .then(createTray)
    .catch((error) => console.error('Unable to create the Zalo tray:', error));
  app.once('will-quit', () => {
    if (tray) tray.destroy();
    tray = null;
  });
}

module.exports = { setup };
