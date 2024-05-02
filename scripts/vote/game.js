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


    // 1714603104 may 1 now
    // 1714606704 1 hour from now
    // 1714865904 may 4th
    await mehVote.createGame(1714603104, 1714865904);
    console.log("game created");

    await mehVote.addProductToGame(
        1,
        "MEH BAG 01",
        "50000000000000000000000",
        200,
        1714603104,
        1714606704,
        10,
    );

    console.log("product 1 added");


    await mehVote.addProductToGame(
        1,
        "MEH BAG 02",
        "100000000000000000000000",
        100,
        1714603104,
        1714865904,
        10
    );
    console.log("product 2 added");

    await mehVote.addProductToGame(
        1,
        "MEH BAG 03",
        "100000000000000000000000",
        100,
        1714603104,
        1714865904,
        10
    );

    console.log("product 3 added");

    await mehVote.addProductToGame(
        1,
        "MEH HAT 01",
        "1000000000000000000000000",
        25,
        1714603104,
        1714865904,
        25
    );

    console.log("product 4 added");

    await mehVote.addProductToGame(
        1,
        "MEH HAT 02",
        "1000000000000000000000000",
        25,
        1714603104,
        1714865904,
        25
    );

    console.log("product 5 added");

    await mehVote.addProductToGame(
        1,
        "MEH HAT 03",
        "1000000000000000000000000",
        25,
        1714603104,
        1714865904,
        25
    );

    console.log("product 6 added");

    await mehVote.addProductToGame(
        1,
        "MEH SHIRT 01",
        "1000000000000000000000000",
        25,
        1714603104,
        1714865904,
        25
    );

    console.log("product 7 added");

    await mehVote.addProductToGame(
        1,
        "MEH SHIRT 02",
        "1000000000000000000000000",
        25,
        1714603104,
        1714865904,
        25
    );

    console.log("product 8 added");

    await meh.approve(MEH_VOTE, "100000000000000000000000")

    await mehVote.depositPrizeMeh(
        1,
        1,
        "100000000000000000000000",
    );

    console.log("prize meh deposited");

}

main();