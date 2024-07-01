const API_KEY = process.env.API_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const PUBLIC_KEY = process.env.PUBLIC_KEY;

const MEH_CCIP_LINK= process.env.MEH_CCIP_LINK;
const MEH_AD_V2 = process.env.MEH_AD_V2;

//npx hardhat run scripts/ad/cciplinksetsource.js --network mainnet
//npx hardhat run scripts/ad/cciplinksetsource.js --network sepolia
async function main() {
    const MehCCIP = await ethers.getContractFactory("MehCCIPLink");
    const mehCCIP = await MehCCIP.attach(MEH_CCIP_LINK);


    await mehCCIP.setSourceContractAddress(
        MEH_AD_V2
    );

    console.log("done");

}

main();