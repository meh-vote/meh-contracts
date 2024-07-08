const API_KEY = process.env.API_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const PUBLIC_KEY = process.env.PUBLIC_KEY;
const MEH_TOKEN = process.env.MEH_TOKEN;
const MEH_AD_V1 = process.env.MEH_AD_V1;
const MEH_AD_V2 = process.env.MEH_AD_V2;

//npx hardhat run scripts/ad/reclaim.js --network mainnet
//npx hardhat run scripts/ad/reclaim.js --network sepolia
async function main() {
    // const Meh = await ethers.getContractFactory("Meh");
    // const meh = await Meh.attach(MEH_TOKEN);

    const MehAd = await ethers.getContractFactory("MehAdV2");
    const mehAd = await MehAd.attach(MEH_AD_V2);

    const [owner] = await ethers.getSigners();

    await mehAd.signAd(
        1,
        emptyProof
    );

    console.log("done");

}

main().catch((error) => {
    console.log("error");
    console.error(error);
    process.exitCode = 1;
});