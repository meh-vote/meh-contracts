const { ethers } = require("hardhat");

const MEH_TOKEN = process.env.MEH_TOKEN;
const MEH_AD_V2 = process.env.MEH_AD_V2;
const ERC_AD = process.env.ERC_AD;
const MEH_CCIP_RECEIVER = process.env.MEH_CCIP_RECEIVER;
const LINK_TOKEN = process.env.LINK_TOKEN;
const CCIP_ETH_ROUTER = process.env.CCIP_ETH_ROUTER;
const CHAIN_BASE_SELECTOR = process.env.CHAIN_BASE_SELECTOR;

//npx hardhat run scripts/ad/deploy.js --network sepolia
//npx hardhat run scripts/ad/deploy.js --network mainnet
async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("deploying contracts with the account:", deployer.address);

    const weiAmount = (await deployer.getBalance()).toString();
    console.log("account balance:", await ethers.utils.formatEther(weiAmount));

    const gasPrice = await deployer.getGasPrice();
    console.log(`current gas price: ${gasPrice}`);

    const ERCAd = await ethers.getContractFactory("ERCAd");
    const ercAd = await ERCAd.deploy(
        "MehAdV2",
        "Meh"
    );
    console.log("ercad deployed to address:", ercAd.address);

    const MehAdV2 = await ethers.getContractFactory("MehAdV2");

    const mehAdV2 = await MehAdV2.deploy(
        MEH_CCIP_RECEIVER, // base ccip receiver contract
        CCIP_ETH_ROUTER, // eth ccip router
        LINK_TOKEN, // link token
        ercAd.address,
        CHAIN_BASE_SELECTOR
    );
    console.log("mehAdV2 deployed to address:", mehAdV2.address);

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
