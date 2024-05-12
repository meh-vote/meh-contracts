const API_KEY = process.env.API_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const PUBLIC_KEY = process.env.PUBLIC_KEY;
const MEH_TOKEN = process.env.MEH_TOKEN;
const MEH_VOTE = process.env.MEH_VOTE;
const MEH_ROYALTIES = process.env.MEH_ROYALTIES;

//npx hardhat run scripts/vote/game.js --network basesepolia
//npx hardhat run scripts/vote/game.js --network base
async function main() {
    const Meh = await ethers.getContractFactory("Meh");
    const meh = await Meh.attach(MEH_TOKEN);

    const MehVote = await ethers.getContractFactory("MehVoteV1");
    const mehVote = await MehVote.attach(MEH_VOTE);

    const MehRoyalties = await ethers.getContractFactory("MehRoyaltyV1");
    const mehRoyalties = await MehRoyalties.attach(MEH_ROYALTIES);


    const [owner] = await ethers.getSigners();

    // wed 7PM 1715220000
    // today 7PM 1714960800
    // sat 7PM 1715479200
    // 1714603104 may 1 now
    // 1715303900 may 10th
    // await mehVote.createGame(1714960800, 1715479200);
    // console.log("game created");
    //
    // await mehVote.addProductToGame(
    //     1,
    //     "MEH SHIRT 01",
    //     75,
    //     "10000000000000000000000000",
    //     1715220000,
    //     1715479200,
    //     1000,
    //     false,
    //     "25000000000000000000000000",
    // );
    //
    // console.log("MEH SHIRT 01 added");
    //
    //
    // await mehVote.addProductToGame(
    //     1,
    //     "MEH HAT 01",
    //     150,
    //     "2500000000000000000000000",
    //     1715220000,
    //     1715479200,
    //     2000,
    //     false,
    //     "10000000000000000000000000",
    // );
    // console.log("MEH HAT 01 added");
    //
    // await mehVote.addProductToGame(
    //     1,
    //     "MEH DIGITAL STICKERS 01",
    //     250,
    //     "100000",
    //     1715220000,
    //     1715479200,
    //     250,
    //     true,
    //     "1000000",
    // );
    // console.log("MEH DIGITAL STICKERS 01 added");
    //
    // await mehVote.addProductToGame(
    //     1,
    //     "MEH DECK 01",
    //     25,
    //     "50000000000000000000000000",
    //     1715220000,
    //     1715720400,
    //     25,
    //     true,
    //     "100000000000000000000000000",
    // );
    //
    // console.log("MEH DECK 01 added");
    //
    // await mehVote.addProductToGame(
    //     1,
    //     "MEH SHIRT 02",
    //     250,
    //     "50000000000000000000000000",
    //     1715392800,
    //     1715720400,
    //     1000,
    //     false,
    //     "100000000000000000000000000",
    // );
    //
    // console.log("MEH SHIRT 02 added");
    //
    // await mehVote.addProductToGame(
    //     1,
    //     "MEH HOODIE ERC-721",
    //     50,
    //     "10000000000000000000000000",
    //     1715220000,
    //     1715720400,
    //     50,
    //     true,
    //     "50000000000000000000000000",
    // );
    //
    // console.log("MEH HOODIE ERC-721 added");
    //
    // await mehVote.addProductToGame(
    //     1,
    //     "MEH HAT ERC-721",
    //     500,
    //     "2500000000000000000000000",
    //     1715547600,
    //     1715720400,
    //     2000,
    //     false,
    //     "5000000000000000000000000",
    // );
    //
    // console.log("MEH HAT ERC-721 added");
    //
    // await mehRoyalties.updateMinter(MEH_VOTE);
    //
    // console.log("minter updated");

    await mehVote.addProductToGame(
        1,
        "MEH HOODIE 01",
        100,
        "250000000000000000000000",
        1715608800,
        1715781600,
        1000,
        false,
        "2500000000000000000000000",
    );

}

main();