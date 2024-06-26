const { ethers } = require("hardhat");

const MEH_TOKEN = process.env.MEH_TOKEN;
const MEH_AD_V2 = process.env.MEH_AD_V2;
const ERC_AD = process.env.ERC_AD;

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
    const mehAdV2 = await MehAdV2.deploy(
        "0xEf4C3545edf08563bbC112D5CEf0A10B396Ea12E", // mainnet link ccip contract
        "0xD3b06cEbF099CE7DA4AcCf578aaebFDBd6e88a93", // base sepolia router
        "0xE4aB69C077896252FAFBD49EFD26B5D171A32410", // link token
        MEH_TOKEN,
        ERC_AD
    );
    console.log("mehAdV2 deployed to address:", mehAdV2.address);

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
