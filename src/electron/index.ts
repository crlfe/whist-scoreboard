import { app, BrowserWindow, Menu } from "electron";

const isDarwin = process.platform === "darwin";
const isDevelopment = process.env.NODE_ENV !== "production";

let mainWindow: BrowserWindow | null = null;

// Slightly pruned application menu, based on the example in
// <https://github.com/electron/electron/blob/master/docs/api/menu.md>.
// This has never actually been tested on a Mac.
const applicationMenuTemplate = [
  ...(!isDarwin
    ? []
    : [
        {
          label: app.name,
          submenu: [
            { role: "about" },
            { type: "separator" },
            { role: "services" },
            { type: "separator" },
            { role: "hide" },
            { role: "hideothers" },
            { role: "unhide" },
            { type: "separator" },
            { role: "quit" }
          ]
        }
      ]),
  {
    label: "File",
    submenu: [isDarwin ? { role: "close" } : { role: "quit" }]
  },
  {
    label: "Edit",
    submenu: [
      { role: "undo" },
      { role: "redo" },
      { type: "separator" },
      { role: "cut" },
      { role: "copy" },
      { role: "paste" },
      ...(isDarwin
        ? [
            { role: "pasteAndMatchStyle" },
            { role: "delete" },
            { role: "selectAll" },
            { type: "separator" },
            {
              label: "Speech",
              submenu: [{ role: "startspeaking" }, { role: "stopspeaking" }]
            }
          ]
        : [{ role: "delete" }, { type: "separator" }, { role: "selectAll" }])
    ]
  },
  {
    label: "View",
    submenu: [
      { role: "reload" },
      ...(false && !isDevelopment
        ? []
        : [{ role: "forcereload" }, { role: "toggledevtools" }]),
      { type: "separator" },
      { role: "resetzoom" },
      { role: "zoomin", accelerator: "CommandOrControl+=" },
      { role: "zoomout" },
      { type: "separator" },
      { role: "togglefullscreen" }
    ]
  }
];

function createMainWindow(): BrowserWindow {
  const window = new BrowserWindow({
    webPreferences: { nodeIntegration: true }
  });

  if (isDevelopment) {
    window.webContents.openDevTools();
    window
      .loadURL(`http://localhost:${process.env.ELECTRON_WEBPACK_WDS_PORT}`)
      .catch(console.error);
  } else {
    window.loadFile(`${__dirname}/index.html`).catch(console.error);
  }

  window.on("closed", () => {
    if (mainWindow === window) {
      mainWindow = null;
    }
  });

  return window;
}

Menu.setApplicationMenu(
  Menu.buildFromTemplate(
    applicationMenuTemplate as Electron.MenuItemConstructorOptions[]
  )
);

app.on("ready", () => {
  mainWindow = createMainWindow();
});

app.on("activate", () => {
  if (mainWindow == null) {
    mainWindow = createMainWindow();
  }
});

app.on("window-all-closed", () => {
  if (!isDarwin) {
    app.quit();
  }
});
