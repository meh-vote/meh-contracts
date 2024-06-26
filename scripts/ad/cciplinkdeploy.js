const { ethers } = require("hardhat");

const LINK_TOKEN = process.env.LINK_TOKEN;
const CCIP_ETH_ROUTER = process.env.CCIP_ETH_ROUTER;
const CHAIN_ETH_SELECTOR = process.env.CHAIN_ETH_SELECTOR;

//npx hardhat run scripts/ad/cciplinkdeploy.js --network sepolia
//npx hardhat run scripts/ad/cciplinkdeploy.js --network mainnet
async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("deploying contracts with the account:", deployer.address);

    const weiAmount = (await deployer.getBalance()).toString();
    console.log("account balance:", await ethers.utils.formatEther(weiAmount));

    const gasPrice = await deployer.getGasPrice();
    console.log(`current gas price: ${gasPrice}`);

    const MehCCIPLink = await ethers.getContractFactory("MehCCIPLink");
    const mehCCIPLink = await MehCCIPLink.deploy(
        LINK_TOKEN,
        CCIP_ETH_ROUTER,
        CHAIN_ETH_SELECTOR
    );
    console.log("mehCCIPLink deployed to address:", mehCCIPLink.address);

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });