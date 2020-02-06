import { app, BrowserWindow, Menu } from "electron";

// Hide deprecation warning; https://github.com/electron/electron/issues/18397
app.allowRendererProcessReuse = true;

// Clear the default menu.
Menu.setApplicationMenu(null);

function createMainWindow() {
  const w = new BrowserWindow({});
  w.loadFile("web/index.html");
}

app.on("ready", createMainWindow);

app.on("activate", () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createMainWindow();
  }
});

app.on("window-all-closed", () => {
  app.quit();
});
