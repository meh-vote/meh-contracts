const { ethers } = require("hardhat");

const MEH_TOKEN = process.env.MEH_TOKEN;

//npx hardhat run scripts/deploy.js --network basesepolia
async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("deploying contracts with the account:", deployer.address);

    const weiAmount = (await deployer.getBalance()).toString();
    console.log("account balance:", await ethers.utils.formatEther(weiAmount));

    const gasPrice = await deployer.getGasPrice();
    console.log(`current gas price: ${gasPrice}`);


    const MehVote = await ethers.getContractFactory("MehVoteV1");
    const mehVote = await MehVote.deploy(
        MEH_TOKEN
    );
    console.log("mehVote deployed to address:", mehVote.address);

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
