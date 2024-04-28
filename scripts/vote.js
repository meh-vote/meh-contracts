const API_KEY = process.env.API_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const PUBLIC_KEY = process.env.PUBLIC_KEY;
const MEH_TOKEN = process.env.MEH_TOKEN;
const MEH_VOTE = process.env.MEH_VOTE;

//npx hardhat run scripts/vote.js --network basesepolia
async function main() {
    const Meh = await ethers.getContractFactory("Meh");
    const meh = await Meh.attach(MEH_TOKEN);

    const MehVote = await ethers.getContractFactory("MehVoteV1");
    const mehVote = await MehVote.attach(MEH_VOTE);


    const [owner] = await ethers.getSigners();

    // 1714317430 apr 28th 8AM
    // 1714576622 may 1
    // await mehVote.createGame(1714317430, 1714576622);
    // console.log("game created");

    // await mehVote.addProductToGame(
    //     1,
    //     "10000000000000000000000000",
    //     "10000000000000000000000000",
    //     10,
    //     1714317430,
    //     1714576622
    // );


    // await mehVote.addProductToGame(
    //     1,
    //     "5000000000000000000000000",
    //     "2000000000000000000000000",
    //     50,
    //     1714317430,
    //     1714432622
    // );

    await meh.approve(MEH_VOTE, "100000000000000000000000")

    await mehVote.depositMeh(
        1,
        1,
        "100000000000000000000000",
    );

}

main();