require("@nomicfoundation/hardhat-toolbox");
require("hardhat-abi-exporter");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.21",
  // https://github.com/hbriese/hardhat-abi-exporter/blob/master/README.md
  // https://www.npmjs.com/package/hardhat-abi-exporter
  // npx hardhat export-abi --no-compile
  abiExporter: {
    path: "./abi",
    runOnCompile: true,
    clear: true,
    flat: true,
    spacing: 2,
    pretty: true,
  },
};
