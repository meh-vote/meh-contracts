const API_KEY = process.env.API_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const PUBLIC_KEY = process.env.PUBLIC_KEY;
const MEH_ROYALTY = process.env.MEH_ROYALTIES;

//npx hardhat run scripts/royalty/baseuri.js --network base
async function main() {
    const MehRoyalty = await ethers.getContractFactory("MehRoyaltyV1");
    const mehRoyalty = await MehRoyalty.attach(MEH_ROYALTY);

    await mehRoyalty.setBaseTokenURI(
        "https://gateway.pinata.cloud/ipfs/Qmb3xsABBPfugt6CrumZuKQWPF381rpMAdfdpkHW6XVDsf/"
    );


}

main();