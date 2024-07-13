const API_KEY = process.env.API_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const PUBLIC_KEY = process.env.PUBLIC_KEY;
const USDC_TOKEN = process.env.USDC_TOKEN;
const MEH_STORE_V1 = process.env.MEH_STORE_V1;
const MEH_STORE_NFT = process.env.MEH_STORE_NFT;



//npx hardhat run scripts/store/setup.js --network basesepolia
//npx hardhat run scripts/store/setup.js --network base
async function main() {


    const MehStoreV1 = await ethers.getContractFactory("MehStoreV1");
    const mehStoreV1 = await MehStoreV1.attach(MEH_STORE_V1);

    const MehStoreNFT = await ethers.getContractFactory("MehStoreNFT");
    const mehStoreNFT = await MehStoreNFT.attach(MEH_STORE_NFT);

    await mehStoreNFT.setMehStoreV1(MEH_STORE_V1);

    // await mehStoreV1.addProduct(
    //     "1000000",
    //     "MEH Shirt 01",
    //     "Black",
    //     "https://meh.vote/images/vote/id_1.png",
    //     0
    // );

    // await mehStoreV1.addProduct(
    //     "2000000",
    //     "MEH Hat 01",
    //     "Black",
    //     "https://meh.vote/images/vote/id_2.png",
    //     2
    // );

    // const product = await mehStoreV1.products(2);
    // console.log(product);

    console.log("done")

}

main();