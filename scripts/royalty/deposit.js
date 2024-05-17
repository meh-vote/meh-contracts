const API_KEY = process.env.API_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const PUBLIC_KEY = process.env.PUBLIC_KEY;
const MEH_TOKEN = process.env.MEH_TOKEN;
const MEH_VOTE = process.env.MEH_VOTE;
const MEH_ROYALTIES = process.env.MEH_ROYALTIES;

//npx hardhat run scripts/royalty/deposit.js --network base
async function main() {
    const Meh = await ethers.getContractFactory("Meh");
    const meh = await Meh.attach(MEH_TOKEN);

    const MehVote = await ethers.getContractFactory("MehVoteV1");
    const mehVote = await MehVote.attach(MEH_VOTE);

    const MehRoyalties = await ethers.getContractFactory("MehRoyaltyV1");
    const mehRoyalties = await MehRoyalties.attach(MEH_ROYALTIES);


    const [owner] = await ethers.getSigners();


    //
    // await mehVote.depositMehStore(
    //     "16650000000000000000000000000"
    // );

    await meh.approve(MEH_ROYALTIES, "109600000000000000000000000")
    for (let i = 30228; i <= 30229; i++) {
        await mehRoyalties.depositMehToken(
            i,
            "125000000000000000000000"
        );
        console.log(i);
    }



    //16650000000
    //198000000 shirt 01
    //109600000 hat 01
    //28625000 // stickers

}

main();