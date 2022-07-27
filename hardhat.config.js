require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-web3");
require("@typechain/hardhat");
require("hardhat-abi-exporter");
require("solidity-coverage");
require("dotenv/config");
require("hardhat-gas-reporter");
/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000
      }
    }
  },
  networks: {
    hardhat: {
      initialBaseFeePerGas: 0 // hardhat london fork error fix for coverage
    },
    testnet: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545",
      accounts: [process.env.PRIVATE_KEY_testnet]
    },
    mainnet: {
      url: "https://bsc-dataseed1.binance.org",
      chainId: 56,
      accounts: [process.env.PRIVATE_KEY_mainnet]
    }
  },
  paths: {
    sources: "./src/*",
    artifacts: "./build",
    tests: "./src/tests/*"
  },
  gasReporter: {
    enabled: true,
    currency: "USD"
  },
  abiExporter: {
    path: "./abi",
    clear: true,
    flat: true
  }
};
