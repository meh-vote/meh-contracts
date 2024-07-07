const { ethers } = require("hardhat");

const MEH_TOKEN = process.env.MEH_TOKEN;
const CCIP_BASE_ROUTER = process.env.CCIP_BASE_ROUTER;
const CHAIN_ETH_SELECTOR = process.env.CHAIN_ETH_SELECTOR;

//npx hardhat run scripts/ad/deployMehCCIPReceiver.js --network basesepolia
//npx hardhat run scripts/ad/deployMehCCIPReceiver.js --network base
async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("deploying contracts with the account:", deployer.address);

    const weiAmount = (await deployer.getBalance()).toString();
    console.log("account balance:", await ethers.utils.formatEther(weiAmount));

    const gasPrice = await deployer.getGasPrice();
    console.log(`current gas price: ${gasPrice}`);

    const MehCCIPReceiver = await ethers.getContractFactory("MehCCIPReceiver");
    const mehCCIPReceiver = await MehCCIPReceiver.deploy(
        CCIP_BASE_ROUTER,
        MEH_TOKEN
    );
    console.log("mehCCIPReceiver deployed to address:", mehCCIPReceiver.address);

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });