require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config();
/** @type import('hardhat/config').HardhatUserConfig */


const SEPOLIA_URL=process.env.SEPOLIA_URL;
const PRIVATE_URL=process.env.PRIVATE_URL;


module.exports = {
  solidity: "0.8.12",

  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  defaultNetwork: "sepolia",
  networks: {
    hardhat: {},
    sepolia: {
      url: SEPOLIA_URL,
      accounts: [`0x${PRIVATE_URL}`]
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./client/src" 
  },
};
