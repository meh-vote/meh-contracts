const API_KEY = process.env.API_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const PUBLIC_KEY = process.env.PUBLIC_KEY;
const USDC_TOKEN = process.env.USDC_TOKEN;
const MEH_STORE_V1 = process.env.MEH_STORE_V1;
const MEH_STORE_NFT = process.env.MEH_STORE_NFT;


const CryptoJS = require('crypto-js');

//npx hardhat run scripts/store/nft-address.js --network basesepolia
//npx hardhat run scripts/store/nft-address.js --network base
async function main() {
    const MehStoreNFT = await ethers.getContractFactory("MehStoreNFT");
    const mehStoreNFT = await MehStoreNFT.attach(MEH_STORE_NFT);

    const details = await mehStoreNFT.getNFTDetails(2);
    console.log(details);

    // const bytes = CryptoJS.AES.decrypt(details.deliveryAddress, secretKey);
    // const decryptedString = bytes.toString(CryptoJS.enc.Utf8);

    // console.log(decryptedString);

}

main();