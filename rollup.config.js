import path from "path";

import elm from "rollup-plugin-elm";
import { terser } from "rollup-plugin-terser";

const pure_funcs = [
  "F2",
  "F3",
  "F4",
  "F5",
  "F6",
  "F7",
  "F8",
  "F9",
  "A2",
  "A3",
  "A4",
  "A5",
  "A6",
  "A7",
  "A8",
  "A9"
];

export default {
  input: "web/index.js",
  output: {
    dir: "dist",
    format: "iife"
  },
  plugins: [
    elm({
      include: "src/**/*.elm",
      compiler: {
        debug: false,
        optimize: true,
        pathToElm: path.resolve(__dirname, "./node_modules/.bin/elm")
      },
    }),
    terser({
      ecma: 3,
      compress: {
        pure_funcs,
        pure_getters: true,
        keep_fargs: false,
        unsafe_comps: true,
        unsafe: true,
        passes: 4
      },
      mangle: true
    })
  ]
};
