const API_KEY = process.env.API_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const PUBLIC_KEY = process.env.PUBLIC_KEY;
const MEH_TOKEN = process.env.MEH_TOKEN;
const MEH_AD_V2 = process.env.MEH_AD_V2;
const ERC_AD = process.env.ERC_AD;


//npx hardhat run scripts/ad/setad.js --network base
//npx hardhat run scripts/ad/setad.js --network basesepolia
async function main() {
    const Meh = await ethers.getContractFactory("Meh");
    const meh = await Meh.attach(MEH_TOKEN);

    await meh.mint(MEH_AD_V2, "1000000000000000000000000000");


    const ERCAd = await ethers.getContractFactory("ERCAd");
    const ercAd = await ERCAd.attach(ERC_AD);

    const emptyRoot = ethers.constants.HashZero;

    await ercAd.setAd(
        "https://meh.network",
        "https://meh.network",
        emptyRoot,
        emptyRoot
    );

    console.log("done")

}

main();