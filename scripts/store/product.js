const API_KEY = process.env.API_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const PUBLIC_KEY = process.env.PUBLIC_KEY;
const USDC_TOKEN = process.env.USDC_TOKEN;
const MEH_STORE_V1 = process.env.MEH_STORE_V1;
const MEH_STORE_NFT = process.env.MEH_STORE_NFT;



//npx hardhat run scripts/store/product.js --network basesepolia
//npx hardhat run scripts/store/product.js --network base
async function main() {

    const MehStoreV1 = await ethers.getContractFactory("MehStoreV1");
    const mehStoreV1 = await MehStoreV1.attach(MEH_STORE_V1);

    const MehStoreNFT = await ethers.getContractFactory("MehStoreNFT");
    const mehStoreNFT = await MehStoreNFT.attach(MEH_STORE_NFT);


    await mehStoreV1.updateProduct(
        2,
        "1000000",
        "MEH ERC-721 Black Hoodie", 
        "https://meh.store/images/meh.png"
    );

    console.log("done")

}

main();