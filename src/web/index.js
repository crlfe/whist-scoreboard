import { Elm } from "../main/Main.elm";
import { version } from "../../package.json";

var localStorage = window.localStorage;
var localName = "whist-scoreboard";
var app = Elm.Main.init({
  flags: {
    languages: navigator.languages || [
      navigator.language || navigator.userLanguage
    ],
    width: window.innerWidth,
    height: window.innerHeight,
    storage: (function() {
      try {
        return JSON.parse(localStorage.getItem(localName));
      } catch {
        localStorage.removeItem(localName);
        return null;
      }
    })()
  }
});

app.ports.storage.subscribe(function(data) {
  localStorage.setItem(localName, JSON.stringify(data));
});

try {
  const img = new Image();
  img.src = `https://crlfe.ca/f/hit?e=whist-scoreboard-${version}`;
  img.addEventListener("load", function() {});
} catch (err) {}
