import { CleanWebpackPlugin } from "clean-webpack-plugin";
import CopyWebpackPlugin from "copy-webpack-plugin";
import path from "path";

export default (env, argv) => ({
  context: path.resolve(__dirname),
  entry: {
    index: "./src/web/index.js"
  },
  output: {
    path: path.resolve(__dirname, "dist", "web")
  },
  module: {
    rules: [
      {
        test: /\.elm$/,
        use: [
          "elm-hot-webpack-loader",
          {
            loader: "elm-webpack-loader",
            options: {
              optimize: argv.mode === "production"
            }
          }
        ]
      }
    ]
  },
  plugins: [
    new CleanWebpackPlugin(),
    new CopyWebpackPlugin([{ from: "static" }])
  ]
});
