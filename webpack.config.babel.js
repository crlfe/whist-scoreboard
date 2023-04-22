import { CleanWebpackPlugin } from "clean-webpack-plugin";
import CopyWebpackPlugin from "copy-webpack-plugin";
import { LicenseWebpackPlugin } from "license-webpack-plugin";
import path from "path";
import webpack from "webpack";

const webConfig = (target, mode) => ({
  context: path.resolve(__dirname),
  entry: {
    index: "./src/web",
  },
  target,
  output: {
    path: path.resolve(__dirname, "dist", target),
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
              optimize: mode === "production",
            },
          },
        ],
      },
      {
        test: /\.txt$/,
        use: "raw-loader",
      },
    ],
  },
  plugins: [
    new CleanWebpackPlugin(),
    new CopyWebpackPlugin({
      patterns: [{ from: "static" }],
    }),
    new webpack.DefinePlugin({
      "process.env.NODE_ENV": JSON.stringify(mode),
    }),
  ],
  devServer:
    target !== "web"
      ? undefined
      : {
          client: {
            overlay: false,
          },
        },
});

export default (env, argv) => [
  // Default target for webpack-dev-server must be first.
  webConfig("web", argv.mode),
  webConfig("electron-renderer", argv.mode),
  {
    context: path.resolve(__dirname),
    entry: {
      index: "./src/app",
      preload: "./src/app/preload",
    },
    target: "electron-main",
    output: {
      path: path.resolve(__dirname, "dist", "electron-main"),
    },
    module: {
      rules: [
        {
          test: /\.txt$/,
          use: "raw-loader",
        },
      ],
    },
    plugins: [
      new CleanWebpackPlugin(),
      new LicenseWebpackPlugin({
        outputFilename: "ThirdPartyLicenses.txt",
      }),
    ],
  },
];
