const API_KEY = process.env.API_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const PUBLIC_KEY = process.env.PUBLIC_KEY;
const USDC_TOKEN = process.env.USDC_TOKEN;
const MEH_STORE_V1 = process.env.MEH_STORE_V1;
const MEH_STORE_NFT = process.env.MEH_STORE_NFT;


const CryptoJS = require('crypto-js');

//npx hardhat run scripts/store/nft.js --network basesepolia
//npx hardhat run scripts/store/nft.js --network base
async function main() {

    const address = '123 Main St, Bozeman MT 88888';
    const secretKey = 'that-gum-you-like-is-coming-back-in-style';

    const encrypted = CryptoJS.AES.encrypt(address, secretKey).toString();

    console.log('encrypted:', encrypted);


    const MehStoreNFT = await ethers.getContractFactory("MehStoreNFT");
    const mehStoreNFT = await MehStoreNFT.attach(MEH_STORE_NFT);

    await mehStoreNFT.enterDeliveryAddress(
        0,
        encrypted
    );

    const details = await mehStoreNFT.getNFTDetails(0);
    console.log(details);

    const bytes = CryptoJS.AES.decrypt(details.deliveryAddress, secretKey);
    const decryptedString = bytes.toString(CryptoJS.enc.Utf8);

    console.log(decryptedString);

}

main();