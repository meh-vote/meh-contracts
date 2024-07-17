const API_KEY = process.env.API_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const PUBLIC_KEY = process.env.PUBLIC_KEY;
const USDC_TOKEN = process.env.USDC_TOKEN;
const MEH_STORE_V1 = process.env.MEH_STORE_V1;
const MEH_STORE_NFT = process.env.MEH_STORE_NFT;



//npx hardhat run scripts/store/nft.js --network basesepolia
//npx hardhat run scripts/store/nft.js --network base
async function main() {


    const MehStoreNFT = await ethers.getContractFactory("MehStoreNFT");
    const mehStoreNFT = await MehStoreNFT.attach(MEH_STORE_NFT);

    await mehStoreNFT.enterDeliveryAddress(
        0,
        "1347 Skyline Drive, Winona MN 55987"
    );

    const details = await mehStoreNFT.nftDetails(0);
    console.log(details);

}

main();