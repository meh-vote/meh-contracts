const { ethers } = require("hardhat");

const MEH_TOKEN = process.env.MEH_TOKEN;
const MEH_ROYALTIES = process.env.MEH_ROYALTIES;

const ERC_AD = process.env.ERC_AD;
const MEH_AD_V1 = process.env.MEH_AD_V1;

//npx hardhat run scripts/deploy.js --network basesepolia
//npx hardhat run scripts/deploy.js --network base
async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("deploying contracts with the account:", deployer.address);

    const weiAmount = (await deployer.getBalance()).toString();
    console.log("account balance:", await ethers.utils.formatEther(weiAmount));

    const gasPrice = await deployer.getGasPrice();
    console.log(`current gas price: ${gasPrice}`);

    const MehAdV1 = await ethers.getContractFactory("MehAdV1");
    const mehAdV1 = await MehAdV1.deploy(
        "MehAdV1",
        "SIG",
        MEH_TOKEN
    );
    console.log("mehAdV1 deployed to address:", mehAdV1.address);

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
