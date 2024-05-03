const API_KEY = process.env.API_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const PUBLIC_KEY = process.env.PUBLIC_KEY;
const MEH_TOKEN = process.env.MEH_TOKEN;

//npx hardhat run scripts/mint.js --network base
//npx hardhat run scripts/mint.js --network basesepolia
async function main() {
    const Meh = await ethers.getContractFactory("Meh");
    const meh = await Meh.attach(MEH_TOKEN);

    const [owner] = await ethers.getSigners();

    // airdrop 0x05Fa26a8a25B757Bc687cD794D1a196f29Cb96BB
    // austin 0x1434dAB0f668BC64004FF8F7b92FB29A5701549e
    // anthony 0x2C0b158A59355F3AdF30aa1E126Ea8D962F0D786
    // yusuf 0xc2fB492FD515260725AdCfa43eB72ECDcB948836
    // jobu 0x10FeB6f3111197336bC64ad3D0A123F22719D58A
    // vinyls
    // josh 0x17b0C91e4F925F9f7522949835e1DC3B202cd838
    await meh.mint("0xaE2AB19415FeF7f3ACdFDD0295feEDFE7CAE8600", "1000000000000000000000000000");
    console.log("done");


}

main();