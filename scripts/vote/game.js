const API_KEY = process.env.API_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const PUBLIC_KEY = process.env.PUBLIC_KEY;
const MEH_TOKEN = process.env.MEH_TOKEN;
const MEH_VOTE = process.env.MEH_VOTE;

//npx hardhat run scripts/vote/game.js --network basesepolia
async function main() {
    const Meh = await ethers.getContractFactory("Meh");
    const meh = await Meh.attach(MEH_TOKEN);

    const MehVote = await ethers.getContractFactory("MehVoteV1");
    const mehVote = await MehVote.attach(MEH_VOTE);


    const [owner] = await ethers.getSigners();

    // 1714317430 apr 28th 8AM
    // 1714576622 may 1
    await mehVote.createGame(1714317430, 1714576622);
    console.log("game created");

    await mehVote.addProductToGame(
        1,
        "MEH BAG 01",
        "10000000000000000000000000",
        1714317430,
        1714576622,
        10
    );

    console.log("product 1 added");


    await mehVote.addProductToGame(
        1,
        "MEH BAG 02",
        "20000000000000000000000000",
        1714317430,
        1714576622,
        10
    );
    console.log("product 2 added");

    await mehVote.addProductToGame(
        1,
        "MEH BAG 03",
        "30000000000000000000000000",
        1714317430,
        1714576622,
        30
    );

    console.log("product 3 added");

    await mehVote.addProductToGame(
        1,
        "MEH HAT 01",
        "10000000000000000000000000",
        1714317430,
        1714576622,
        50
    );

    console.log("product 4 added");

    await mehVote.addProductToGame(
        1,
        "MEH HAT 02",
        "20000000000000000000000000",
        1714317430,
        1714576622,
        50
    );

    console.log("product 5 added");

    await mehVote.addProductToGame(
        1,
        "MEH HAT 03",
        "30000000000000000000000000",
        1714317430,
        1714576622,
        30
    );

    console.log("product 6 added");

    await mehVote.addProductToGame(
        1,
        "MEH SHIRT 01",
        "5000000000000000000000000",
        1714317430,
        1714576622,
        5
    );

    console.log("product 7 added");

    await mehVote.addProductToGame(
        1,
        "MEH SHIRT 02",
        "7000000000000000000000000",
        1714317430,
        1714576622,
        7
    );

    console.log("product 8 added");

    await meh.approve(MEH_VOTE, "100000000000000000000000")

    await mehVote.depositMeh(
        1,
        1,
        "100000000000000000000000",
    );

}

main();