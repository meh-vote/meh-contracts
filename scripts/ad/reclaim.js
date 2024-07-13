const API_KEY = process.env.API_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const PUBLIC_KEY = process.env.PUBLIC_KEY;
const MEH_TOKEN = process.env.MEH_TOKEN;
const MEH_AD_V1 = process.env.MEH_AD_V1;
const MEH_AD_V2 = process.env.MEH_AD_V2;
const MEH_CCIP_RECEIVER = process.env.MEH_CCIP_RECEIVER;

//npx hardhat run scripts/ad/reclaim.js --network base
//npx hardhat run scripts/ad/reclaim.js --network basesepolia
async function main() {

    const MehCCIPReceiver = await ethers.getContractFactory("MehCCIPReceiver");
    const mehCCIPReceiver = await MehCCIPReceiver.attach(MEH_CCIP_RECEIVER);

    const [owner] = await ethers.getSigners();

    await mehCCIPReceiver.withdrawMeh();

    console.log("done");

}

main().catch((error) => {
    console.log("error");
    console.error(error);
    process.exitCode = 1;
});