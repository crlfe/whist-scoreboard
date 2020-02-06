import { Elm } from "../main/Main.elm";

var localStorage = window.localStorage;
var localName = "whist-scoreboard";
var app = Elm.Main.init({
  flags: {
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
