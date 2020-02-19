import { app, BrowserWindow, Menu, shell } from "electron";
import { autoUpdater } from "electron-updater";
import path from "path";

// Hide deprecation warning; https://github.com/electron/electron/issues/18397
app.allowRendererProcessReuse = true;

// Clear the default menu.
Menu.setApplicationMenu(null);

function createMainWindow() {
  const w = new BrowserWindow({
    webPreferences: {
      nodeIntegration: false,
      preload: path.join(app.getAppPath(), "preload.js")
    }
  });
  w.loadFile("web/index.html").then(() => {
    w.webContents.on("new-window", (event, url) => {
      shell.openExternal(url);
      event.preventDefault();
    });
  });
}

app.on("ready", () => {
  try {
    autoUpdater.checkForUpdatesAndNotify().catch(console.error);
  } catch (err) {
    console.error(err);
  }

  createMainWindow();
});

app.on("activate", () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createMainWindow();
  }
});

app.on("window-all-closed", () => {
  app.quit();
});
