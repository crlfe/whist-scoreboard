import { CleanWebpackPlugin } from "clean-webpack-plugin";
import CopyWebpackPlugin from "copy-webpack-plugin";
import { LicenseWebpackPlugin } from "license-webpack-plugin";
import path from "path";
import webpack from "webpack";

const webConfig = (target, mode) => ({
  context: path.resolve(__dirname),
  entry: {
    index: "./src/web"
  },
  target,
  output: {
    path: path.resolve(__dirname, "dist", target)
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
              optimize: mode === "production"
            }
          }
        ]
      }
    ]
  },
  plugins: [
    new CleanWebpackPlugin(),
    new CopyWebpackPlugin([{ from: "static" }]),
    new webpack.DefinePlugin({
      "process.env.NODE_ENV": JSON.stringify(mode)
    })
  ]
});

export default (env, argv) => [
  {
    context: path.resolve(__dirname),
    entry: {
      index: "./src/app"
    },
    target: "electron-main",
    output: {
      path: path.resolve(__dirname, "dist", "electron-main")
    },
    plugins: [
      new CleanWebpackPlugin(),
      new LicenseWebpackPlugin({
        outputFilename: "ThirdPartyLicenses.txt"
      })
    ]
  },
  webConfig("electron-renderer", argv.mode),
  webConfig("web", argv.mode)
];
