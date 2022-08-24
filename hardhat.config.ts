// require("@nomiclabs/hardhat-waffle");
import "@nomiclabs/hardhat-ethers";
require("@nomiclabs/hardhat-etherscan");
require("dotenv").config({ path: ".env" });

const GOERLI_API_KEY_URL = process.env.GOERLI_API_KEY_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;

const API_TOKEN = process.env.API_TOKEN;

module.exports = {
  solidity: "0.8.9",
  networks: {
    hardhat: {
      forking: {
        url: "",
      },
    },
    goerli: {
      url: GOERLI_API_KEY_URL,
      //@ts-ignore
      accounts: [PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: API_TOKEN,
  },
  lockGasLimit: 200000000000,
  gasPrice: 10000000000,
};
