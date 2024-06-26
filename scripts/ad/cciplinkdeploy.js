const { ethers } = require("hardhat");


//npx hardhat run scripts/ad/cciplinkdeploy.js --network sepolia
async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("deploying contracts with the account:", deployer.address);

    const weiAmount = (await deployer.getBalance()).toString();
    console.log("account balance:", await ethers.utils.formatEther(weiAmount));

    const gasPrice = await deployer.getGasPrice();
    console.log(`current gas price: ${gasPrice}`);



    const MehCCIPLink = await ethers.getContractFactory("MehCCIPLink");
    const mehCCIPLink = await MehCCIPLink.deploy(
        "0x779877A7B0D9E8603169DdbD7836e478b4624789"
    );
    console.log("mehCCIPLink deployed to address:", mehCCIPLink.address);

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });