#!/bin/sh
set -e
rm -rf dist
mkdir dist

live-server --host=localhost dist &
nodemon -w src -w static -e '*' --exec "
  rsync -a static/ dist
  echo '<script>Elm.Main.init()</script>' >> dist/index.html
  elm make src/Main.elm --output dist/index.js
"
