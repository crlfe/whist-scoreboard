import { Elm } from "../main/Main.elm";

import { version } from "../../package.json";
import license from "../../LICENSE.txt";
import thirdPartyLicenses from "./ThirdPartyLicenses.txt";

var localStorage = window.localStorage;
var localName = "whist-scoreboard";
var app = Elm.Main.init({
  flags: {
    languages: navigator.languages || [
      navigator.language || navigator.userLanguage
    ],
    version,
    licenses:
      license +
      "\n===\n" +
      thirdPartyLicenses +
      (window.electronLicenses ? "\n===\n" + window.electronLicenses : ""),
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
