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
        const tokenId = 10000 + i;
        contract = {
            "name": "MEH SHIRT 01",
            "description": "Meh Royalty Contract (MR1) for meh.store",
            "productId": 1,
            "tokenId": tokenId,
            "image": "https://gateway.pinata.cloud/ipfs/QmRizCkUTuPVcqqDBqU5nUd7jVRM3uJryQyhHBVTpdpAn8"
        };
        const fileName = "data/mr1/" + tokenId;
        fs.writeFileSync(fileName, JSON.stringify(contract));
    }
}





main();