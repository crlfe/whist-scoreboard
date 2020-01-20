#!/bin/sh
set -e

rm -rf dist
mkdir dist
cp -a static/* dist
elm make src/Main.elm --optimize --output=dist/main.tmp.js
(
  echo '(function(){'
  cat "dist/main.tmp.js"
  cat "static/index.js"
  echo '})()'
) \
| terser --compress 'pure_funcs="F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9",pure_getters,keep_fargs=false,unsafe_comps,unsafe' \
| terser --mangle \
> dist/index.js

rm -f dist/main.tmp.js
