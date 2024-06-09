const API_KEY = process.env.API_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const PUBLIC_KEY = process.env.PUBLIC_KEY;
const MEH_TOKEN = process.env.MEH_TOKEN;
const MEH_AD_V1 = process.env.MEH_AD_V1;

//npx hardhat run scripts/ad/signad.js --network base
//npx hardhat run scripts/ad/signad.js --network basesepolia
async function main() {
    const Meh = await ethers.getContractFactory("Meh");
    const meh = await Meh.attach(MEH_TOKEN);

    const MehAd = await ethers.getContractFactory("MehAdV1");
    const mehAd = await MehAd.attach(MEH_AD_V1);

    const [owner] = await ethers.getSigners();
    const emptyProof = ["0x0000000000000000000000000000000000000000000000000000000000000000"];

    await mehAd.signAd(
        1,
        emptyProof
    );

}

main();