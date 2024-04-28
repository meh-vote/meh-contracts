const {fs} = require('file-system');

const ETH_MULTIPLIER = 1000000000000000000;

const MEH_AIRDROP = process.env.MEH_AIRDROP;


async function main() {
    const MehAirdrop = await ethers.getContractFactory("MehAirdropV1");
    const mehAirdrop = await MehAirdrop.attach(MEH_AIRDROP);

    const data = parseAirdrop();

    var airdrops = 0;
    for (let i = 0; i < data.addresses.length; i += 10) {
        const addressChunk = data.addresses.slice(i, i + 10);
        const amountChunk = data.amounts.slice(i, i + 10);
        console.log("sending chunk");
        await mehAirdrop.airdrop(addressChunk, amountChunk);
        airdrops++;
    }

    console.log("airdrop done: " + airdrops);

}


function parseAirdrop() {
    const fileName = "data/airdrop.csv";

    const data = fs.readFileSync(fileName, 'utf8');
    const lines = data.split('\n');

    const addresses = [];
    const amounts = [];

    for (const line of lines) {
        if (line) {  // Check if the line is not empty
            const parts = line.split(',');
            addresses.push(parts[0]);
            amounts.push(parts[1]);
        }
    }

    return {
        addresses: addresses,
        amounts: amounts
    };
}



main();