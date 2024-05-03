const API_KEY = process.env.API_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const PUBLIC_KEY = process.env.PUBLIC_KEY;
const MEH_TOKEN = process.env.MEH_TOKEN;
const MEH_VOTE = process.env.MEH_VOTE;
const MEH_ROYALTIES = process.env.MEH_ROYALTIES;

//npx hardhat run scripts/vote/game.js --network basesepolia
async function main() {
    const Meh = await ethers.getContractFactory("Meh");
    const meh = await Meh.attach(MEH_TOKEN);

    const MehVote = await ethers.getContractFactory("MehVoteV1");
    const mehVote = await MehVote.attach(MEH_VOTE);

    const MehRoyalties = await ethers.getContractFactory("MehRoyaltyV1");
    const mehRoyalties = await MehRoyalties.attach(MEH_ROYALTIES);


    const [owner] = await ethers.getSigners();


    // 1714603104 may 1 now
    // 1715303900 may 10th
    await mehVote.createGame(1714603104, 1715303900);
    console.log("game created");

    await mehVote.addProductToGame(
        1,
        "MEH HAT 01",
        100,
        "50000000000000000000000",
        1714603104,
        1715303900,
        1000,
        true
    );

    console.log("product 1 added");


    await mehVote.addProductToGame(
        1,
        "MEH SHIRT 01",
        25,
        "25000000000000000000000000",
        1714603104,
        1715303900,
        1000,
        false
    );
    console.log("product 2 added");

    await mehVote.addProductToGame(
        1,
        "MEH DIGITAL STICKERS 01",
        250,
        "1000000000000000000000000",
        1714603104,
        1715303900,
        1000,
        true
    );
    console.log("product 2 added");

    await mehVote.addProductToGame(
        1,
        "MEH STICKERS 01",
        250,
        "1000000000000000000000000",
        1714603104,
        1715303900,
        1000,
        true
    );

    console.log("product 4 added");

    await mehVote.addProductToGame(
        1,
        "MEH BAG 01",
        250,
        "1000000000000000000000000",
        1714603104,
        1715303900,
        1000,
        true
    );

    console.log("product 5 added");

    await mehVote.addProductToGame(
        1,
        "MEH BAG 02",
        250,
        "1000000000000000000000000",
        1714603104,
        1715303900,
        1000,
        true
    );

    console.log("product 6 added");

    await mehVote.addProductToGame(
        1,
        "MEH HOODIE 01",
        25,
        "25000000000000000000000000",
        1714603104,
        1715303900,
        1000,
        false
    );

    console.log("product 7 added");

    await mehVote.addProductToGame(
        1,
        "MEH DECK 01",
        250,
        "1000000000000000000000000",
        1714603104,
        1715303900,
        1000,
        true
    );

    console.log("product 8 added");

    await meh.approve(MEH_VOTE, "100000000000000000000000")

    await mehVote.depositPrizeMeh(
        1,
        1,
        "100000000000000000000000",
    );

    console.log("prize meh deposited");

    await mehRoyalties.updateMinter(MEH_VOTE);

    console.log("minter updated");

}

main();