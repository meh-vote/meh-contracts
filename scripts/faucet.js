const API_KEY = process.env.API_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const PUBLIC_KEY = process.env.PUBLIC_KEY;
const MEH_TOKEN = process.env.MEH_TOKEN;
const MEH_FAUCET = process.env.MEH_FAUCET;

//npx hardhat run scripts/faucet.js --network base
async function main() {
    const Meh = await ethers.getContractFactory("Meh");
    const meh = await Meh.attach(MEH_TOKEN);

    const MehFaucet = await ethers.getContractFactory("MehFaucetV1");
    const mehFaucet = await MehFaucet.attach(MEH_FAUCET);

    const [owner] = await ethers.getSigners();


    // await meh.mint(MEH_FAUCET, "50000000000000000000000000"); // 50M
    // console.log("mint done");

    await mehFaucet.toggleFaucet();
    console.log("faucet toggled");

    // await mehFaucet.faucet();
    // console.log("faucet");

}

main();