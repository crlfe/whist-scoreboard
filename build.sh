#!/bin/sh
set -e

rm -rf dist
mkdir dist
cp -a static/* dist
elm make src/Main.elm --optimize --output=dist/main.tmp.js
(
  head --lines=-2 "dist/main.tmp.js"
  echo '$author$project$Main$main($elm$json$Json$Decode$succeed(0))(0)();'
  echo '})()'
) \
| terser --compress 'pure_funcs="F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9",pure_getters,keep_fargs=false,unsafe_comps,unsafe' \
| terser --mangle \
> dist/index.js

rm -f dist/main.tmp.js
