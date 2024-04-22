const { ethers } = require("hardhat");

const MEH_TOKEN = process.env.MEH_TOKEN;

//npx hardhat run scripts/deploy.js --network base
async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("deploying contracts with the account:", deployer.address);

  const weiAmount = (await deployer.getBalance()).toString();
  console.log("account balance:", await ethers.utils.formatEther(weiAmount));

  const gasPrice = await deployer.getGasPrice();
  console.log(`current gas price: ${gasPrice}`);

  // const Meh = await ethers.getContractFactory("Meh");
  // const meh = await Meh.deploy();
  // console.log("meh deployed to address:", meh.address);

    const MehAirdrop = await ethers.getContractFactory("MehAirdropV1");
    const mehAirdrop = await MehAirdrop.deploy(
        MEH_TOKEN
    );
    console.log("mehAirdrop deployed to address:", mehAirdrop.address);

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
