import licenses from "./ThirdPartyLicenses.txt";

process.once("loaded", () => {
  global.electronLicenses = licenses;
});
