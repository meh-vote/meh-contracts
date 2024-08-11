const API_KEY = process.env.API_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const PUBLIC_KEY = process.env.PUBLIC_KEY;
const USDC_TOKEN = process.env.USDC_TOKEN;
const MEH_STORE_V1 = process.env.MEH_STORE_V1;
const MEH_STORE_NFT = process.env.MEH_STORE_NFT;
const MEH_TOKEN = process.env.MEH_TOKEN;


//npx hardhat run scripts/store/setup.js --network basesepolia
//npx hardhat run scripts/store/setup.js --network base
async function main() {

    const Meh = await ethers.getContractFactory("Meh");
    const meh = await Meh.attach(MEH_TOKEN);

    const MehStoreV1 = await ethers.getContractFactory("MehStoreV1");
    const mehStoreV1 = await MehStoreV1.attach(MEH_STORE_V1);

    const MehStoreNFT = await ethers.getContractFactory("MehStoreNFT");
    const mehStoreNFT = await MehStoreNFT.attach(MEH_STORE_NFT);

    await mehStoreNFT.setMehStoreV1(MEH_STORE_V1);

    await meh.mint(MEH_STORE_V1, "50000000000000000000000000"); // 500M
    console.log("mint done");

    await mehStoreV1.addProduct(
        "1000000",
        "MEH Shirt 01",
        "https://meh.store/images/meh.png"
    );

    await mehStoreV1.addProductSize(
        0,
        "Small"
    );

    await mehStoreV1.addProductSize(
        0,
        "Medium"
    );

    await mehStoreV1.addProductSize(
        0,
        "Large"
    );

    await mehStoreV1.addProductSize(
        0,
        "X-Large"
    );

    let product = await mehStoreV1.products(0);
    console.log(product);
    await sleep(1000);

    // product 1
    await mehStoreV1.addProduct(
        "2000000",
        "MEH Eco Trucker Hat Embroidered",
        "https://meh.store/images/meh.png"
    );

    product = await mehStoreV1.products(1);
    console.log(product);
    await sleep(1000);


    // product 2
    await mehStoreV1.addProduct(
        "100000000", // 100 USDC
        "MEH ERC-721 Black Hoodie",
        "https://meh.store/images/meh.png"
    );

    await mehStoreV1.addProductSize(
        2,
        "Small"
    );

    await mehStoreV1.addProductSize(
        2,
        "Medium"
    );

    await mehStoreV1.addProductSize(
        2,
        "Large"
    );

    await mehStoreV1.addProductSize(
        2,
        "X-Large"
    );

    product = await mehStoreV1.products(2);
    console.log(product);
    await sleep(1000);

    // product 3
    await mehStoreV1.addProduct(
        "40000000", // 40 USDC
        "MEH Shirt 01 Embroidered",
        "https://meh.store/images/meh.png"
    );

    await mehStoreV1.addProductSize(
        3,
        "Small"
    );

    await mehStoreV1.addProductSize(
        3,
        "Medium"
    );

    await mehStoreV1.addProductSize(
        3,
        "Large"
    );

    await mehStoreV1.addProductSize(
        3,
        "X-Large"
    );

    product = await mehStoreV1.products(3);
    console.log(product);
    await sleep(1000);

    // product 4
    await mehStoreV1.addProduct(
        "40000000", // 40 USDC
        "MEH Eco Trucker Hat Embroidered",
        "https://meh.store/images/meh.png"
    );

    product = await mehStoreV1.products(4);
    console.log(product);
    await sleep(1000);

    // product 5
    await mehStoreV1.addProduct(
        "125000000", // 125 USDC
        "MEH Heritage Pullover Hoodie",
        "https://meh.store/images/meh.png"
    );

    await mehStoreV1.addProductSize(
        5,
        "Small"
    );

    await mehStoreV1.addProductSize(
        5,
        "Medium"
    );

    await mehStoreV1.addProductSize(
        5,
        "Large"
    );

    await mehStoreV1.addProductSize(
        5,
        "X-Large"
    );

    product = await mehStoreV1.products(5);
    console.log(product);
    await sleep(1000);

    console.log("done");


}

function sleep(ms) {
    console.log("sleeping 1 second");
    return new Promise(resolve => setTimeout(resolve, ms));
  }

main();