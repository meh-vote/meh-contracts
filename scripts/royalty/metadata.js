const {fs} = require('file-system');

const MEH_SHIRT_01 = 1000;
const MEH_HAT_01 = 2000;
const MEH_DS_01 = 250;

const MEH_DECK_01 = 50;
const MEH_SHIRT_02 = 250;
const MEH_HOODIE_ERC721 = 50;
const MEH_HAT_ERC721 = 2000;
const MEH_HOODIE_01 = 100;


//npx hardhat run scripts/royalty/metadata.js --network base
function main() {
    for (let i = 0; i < MEH_DS_01; i++) {
        const tokenId = 30000 + i;
        contract = {
            "name": "MEH DIGITAL STICKERS 01",
            "description": "Meh Royalty Contract (MR1) for meh.store",
            "productId": 3,
            "tokenId": tokenId,
            "image": "https://gateway.pinata.cloud/ipfs/QmdHWAPKHtUGM9S43uKoGAUr5o6UNxKUg19e66x47FYvnw"
        };
        const fileName = "data/mr1/" + tokenId;
        fs.writeFileSync(fileName, JSON.stringify(contract));
    }
}





main();