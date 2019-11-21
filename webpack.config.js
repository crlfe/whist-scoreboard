const path = require("path");

const HtmlWebpackPlugin = require("html-webpack-plugin");
const { LicenseWebpackPlugin } = require("license-webpack-plugin");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const TerserPlugin = require("terser-webpack-plugin");
const { DefinePlugin } = require("webpack");

// TODO: Copy static files.

module.exports = (env, argv) => {
  const isProduction = argv.mode === "production";

  return {
    mode: isProduction ? "production" : "development",
    entry: {
      index: path.join(__dirname, "src/renderer/index.ts")
    },
    output: {
      filename: "[name].js",
      path: path.join(__dirname, "dist", "web")
    },
    target: "web",
    resolve: {
      extensions: [".js", ".ts"]
    },
    module: {
      rules: [
        {
          test: /\.css?$/,
          use: [
            {
              loader: MiniCssExtractPlugin.loader,
              options: {
                // you can specify a publicPath here
                // by default it uses publicPath in webpackOptions.output
                //publicPath: "../",
                hmr: !isProduction
              }
            },
            "css-loader"
          ]
        },
        {
          test: /\.tsx?$/,
          use: [
            {
              loader: "ts-loader",
              options: {
                transpileOnly: true
              }
            }
          ]
        }
      ]
    },
    plugins: [
      new MiniCssExtractPlugin({
        filename: "index.css"
      }),
      new HtmlWebpackPlugin({
        filename: "index.html",
        minify: isProduction,
        template: path.join(__dirname, "src/renderer/index.html")
      }),
      new LicenseWebpackPlugin({
        perChunkOutput: false
      }),
      new DefinePlugin({
        __static: JSON.stringify("")
      })
    ],
    optimization: {
      minimize: isProduction,
      noEmitOnErrors: isProduction,

      concatenateModules: true,
      minimizer: [
        new TerserPlugin({
          parallel: true,
          sourceMap: true
        })
      ]
    },
    devServer: {
      contentBase: path.join(__dirname, "static")
    }
  };
};
