require("dotenv").config();
require("@nomiclabs/hardhat-ethers");
require("@openzeppelin/hardhat-upgrades");
require("@nomiclabs/hardhat-etherscan");

const { API_URL, PRIVATE_KEY, ACCOUNT1_PK } = process.env;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.24",
  defaultNetwork: "localhost",
  networks: {
    hardhat: {
      chainId: 1337
    },
    localhost: {
      url: API_URL,
      accounts: "remote",
      gas: "auto",
      gasMultiplier: 4
    },
    base: {
      url: API_URL,
      accounts: [`0x${PRIVATE_KEY}`],
      gas: "auto",
      gasMultiplier: 1.1
    },
    basesepolia: {
      url: API_URL,
      accounts: [`0x${PRIVATE_KEY}`],
      gas: "auto",
      gasMultiplier: 1.5
    }
  },
  etherscan: {
    apiKey: "TJGFDFSCM8PZMMHSFFMUY8BW4T3U8CJSH2"
  }
};

