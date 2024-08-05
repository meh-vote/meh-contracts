const API_KEY = process.env.API_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const PUBLIC_KEY = process.env.PUBLIC_KEY;
const USDC_TOKEN = process.env.USDC_TOKEN;
const MEH_STORE_V1 = process.env.MEH_STORE_V1;



//npx hardhat run scripts/store/purchase.js --network basesepolia
//npx hardhat run scripts/store/purchase.js --network base
async function main() {


    const MehStoreV1 = await ethers.getContractFactory("MehStoreV1");
    const mehStoreV1 = await MehStoreV1.attach(MEH_STORE_V1);

    const USDC = await ethers.getContractFactory("ERC20");
    const usdc = await USDC.attach(USDC_TOKEN);

    await usdc.approve(MEH_STORE_V1, "10000000");

    await mehStoreV1.purchaseProduct(
        1,
        "",
        false
    );

    
    // console.log("done");

    const purchase = await mehStoreV1.sales(0);
    console.log(purchase);

}

main();