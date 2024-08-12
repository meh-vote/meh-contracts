require("dotenv").config();
require("@nomiclabs/hardhat-ethers");
require("@openzeppelin/hardhat-upgrades");
require("@nomiclabs/hardhat-etherscan");

const {
  API_URL,
  PRIVATE_KEY,
  MAX_PRIVATE,
  ACCOUNT1_PK
} = process.env;

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
      gas: 8000000,
      gasPrice: 3000000000,
    },
    basesepolia: {
      url: API_URL,
      accounts: [`0x${PRIVATE_KEY}`],
      gas: 8000000,
      gasPrice: 3000000000,
    },
    sepolia: {
      url: API_URL,
      accounts: [`0x${PRIVATE_KEY}`],
      gas: "auto",
      gasMultiplier: 1.5
    },
    mainnet: {
      url: API_URL,
      accounts: [`0x${PRIVATE_KEY}`],
      gas: "auto",
      gasMultiplier: 1.1
    }
  },
  etherscan: {
    apiKey: "CVCXCX6C1I5AAE4RETWE79G63FU8G8VR39",
    apiURL: "https://api.basescan.org/api",
    customChains: [
      {
        network: "base",
        chainId: 8453,
        urls: {
          apiURL: "https://api.basescan.org/api",
          browserURL: "https://basescan.org"
        }
      },
    ]
  }
};

