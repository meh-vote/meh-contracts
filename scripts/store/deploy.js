const { ethers } = require("hardhat");

const MEH_TOKEN = process.env.MEH_TOKEN;
const MEH_STORE_V1 = process.env.MEH_STORE_V1;
const MEH_STORE_NFT = process.env.MEH_STORE_NFT;
const USDC_TOKEN = process.env.USDC_TOKEN;


//npx hardhat run scripts/store/deploy.js --network basesepolia
//npx hardhat run scripts/store/deploy.js --network base
async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("deploying contracts with the account:", deployer.address);

    const weiAmount = (await deployer.getBalance()).toString();
    console.log("account balance:", await ethers.utils.formatEther(weiAmount));

    const gasPrice = await deployer.getGasPrice();
    console.log(`current gas price: ${gasPrice}`);

    const MehStoreNFT = await ethers.getContractFactory("MehStoreNFT");
    const mehStoreNFT = await MehStoreNFT.deploy();
    console.log("mehStoreNFT deployed to address:", mehStoreNFT.address);

    const MehStoreV1 = await ethers.getContractFactory("MehStoreV1");

    const mehStoreV1 = await MehStoreV1.deploy(
        USDC_TOKEN,
        mehStoreNFT.address,
        MEH_TOKEN
    );
    console.log("mehStoreV1 deployed to address:", mehStoreV1.address);

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
