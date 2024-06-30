const { ethers } = require("hardhat");

const MEH_TOKEN = process.env.MEH_TOKEN;
const MEH_AD_V2 = process.env.MEH_AD_V2;
const ERC_AD = process.env.ERC_AD;
const MEH_CCIP_LINK = process.env.MEH_CCIP_LINK;
const LINK_TOKEN = process.env.LINK_TOKEN;
const CCIP_ROUTER = process.env.CCIP_ROUTER;
const DESTINATION_CHAIN_SELECTOR = process.env.DESTINATION_CHAIN_SELECTOR;

//npx hardhat run scripts/ad/deploy.js --network basesepolia
//npx hardhat run scripts/ad/deploy.js --network base
async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("deploying contracts with the account:", deployer.address);

    const weiAmount = (await deployer.getBalance()).toString();
    console.log("account balance:", await ethers.utils.formatEther(weiAmount));

    const gasPrice = await deployer.getGasPrice();
    console.log(`current gas price: ${gasPrice}`);

    // const ERCAd = await ethers.getContractFactory("ERCAd");
    // const ercAd = await ERCAd.deploy(
    //     "MehAdV2",
    //     "Meh"
    // );
    // console.log("ercad deployed to address:", ercAd.address);

    const MehAdV2 = await ethers.getContractFactory("MehAdV2");
    console.log(MEH_CCIP_LINK);
    console.log(CCIP_ROUTER);
    console.log(LINK_TOKEN);
    console.log(MEH_TOKEN);
    console.log(ERC_AD);
    console.log(DESTINATION_CHAIN_SELECTOR);
    const mehAdV2 = await MehAdV2.deploy(
        MEH_CCIP_LINK, // mainnet link ccip contract
        CCIP_ROUTER, // base router
        LINK_TOKEN, // link token
        MEH_TOKEN,
        ERC_AD,
        DESTINATION_CHAIN_SELECTOR
    );
    console.log("mehAdV2 deployed to address:", mehAdV2.address);

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
