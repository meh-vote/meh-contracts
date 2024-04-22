const API_KEY = process.env.API_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const PUBLIC_KEY = process.env.PUBLIC_KEY;
const MEH_TOKEN = process.env.MEH_TOKEN;

//npx hardhat run scripts/mint.js --network base
async function main() {
    const Meh = await ethers.getContractFactory("Meh");
    const meh = await Meh.attach(MEH_TOKEN);

    const [owner] = await ethers.getSigners();

    // airdrop 0x05Fa26a8a25B757Bc687cD794D1a196f29Cb96BB
    // austin 0x1434dAB0f668BC64004FF8F7b92FB29A5701549e
    // anthony 0x2C0b158A59355F3AdF30aa1E126Ea8D962F0D786
    // yusuf 0xc2fB492FD515260725AdCfa43eB72ECDcB948836
    // jobu 0x10FeB6f3111197336bC64ad3D0A123F22719D58A
    await meh.mint("0xab701fb9FED237DF682D91f855Ab829888a28039", "10000000000000000000000");
    console.log("done");


}

main();