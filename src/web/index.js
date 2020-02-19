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

try {
  const hitServer =
    process.env.NODE_ENV === "production"
      ? "https://crlfe.ca"
      : "http://localhost:5000";
  const img = new Image();
  img.src = `${hitServer}/f/hit?e=whist-scoreboard-${version}`;
  img.addEventListener("load", function() {});
} catch (err) {}
