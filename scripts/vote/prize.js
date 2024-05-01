const API_KEY = process.env.API_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const PUBLIC_KEY = process.env.PUBLIC_KEY;
const MEH_TOKEN = process.env.MEH_TOKEN;
const MEH_VOTE = process.env.MEH_VOTE;

//npx hardhat run scripts/vote/deposit.js --network basesepolia
async function main() {
    const Meh = await ethers.getContractFactory("Meh");
    const meh = await Meh.attach(MEH_TOKEN);

    const MehVote = await ethers.getContractFactory("MehVoteV1");
    const mehVote = await MehVote.attach(MEH_VOTE);


    const [owner] = await ethers.getSigners();


    await meh.approve(MEH_VOTE, "300000000000000000000000")

    await mehVote.depositPrizeMeh(
        1,
        1,
        "300000000000000000000000",
    );

    let games = await mehVote.getProductsByGameId(1);
    console.log(games[1]);

}

main();