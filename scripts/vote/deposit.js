const API_KEY = process.env.API_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const PUBLIC_KEY = process.env.PUBLIC_KEY;
const MAX_PRIVATE = process.env.MAX_PRIVATE;
const MAX_PUBLIC = process.env.MAX_PUBLIC;
const MEH_TOKEN = process.env.MEH_TOKEN;
const MEH_VOTE = process.env.MEH_VOTE;

//npx hardhat run scripts/vote/deposit.js --network basesepolia
//npx hardhat run scripts/vote/deposit.js --network base
async function main() {
    const Meh = await ethers.getContractFactory("Meh");
    const meh = await Meh.attach(MEH_TOKEN);

    const MehVote = await ethers.getContractFactory("MehVoteV1");
    const mehVote = await MehVote.attach(MEH_VOTE);


    const [owner] = await ethers.getSigners();
    await meh.approve(MEH_VOTE, "852500000000000000000000000")
    let balance = await meh.balanceOf(owner.address);
    console.log(balance)
//186285798
//     await mehVote.depositMeh(
//         1,
//         7,
//         341,
//     );

    await mehVote.claim(
        1,
        7,
    );


    console.log("done");

    //let games = await mehVote.getProductsByGameId(1);
    //console.log(games[0]);
    // console.log(games[1]);
    // console.log(games[2]);

}

main();