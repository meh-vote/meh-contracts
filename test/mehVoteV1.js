var chai = require("chai");
const expect = chai.expect;
const { BN, expectEvent, expectRevert } = require("@openzeppelin/test-helpers");
const { solidity } = require("ethereum-waffle");
const { MerkleTree } = require("merkletreejs");
const keccak256 = require("keccak256");

require('@openzeppelin/test-helpers/configure')({
  provider: 'http://127.0.0.1:8545',
});

chai.use(solidity);

describe("meh vote", function () {

  before(async function () {
    this.Meh = await ethers.getContractFactory("Meh");
    this.MehRoyalty = await ethers.getContractFactory("MehRoyaltyV1");
    this.MehVote = await ethers.getContractFactory("MehVoteV1");
  });

  beforeEach(async function () {
    const [owner] = await ethers.getSigners();
    this.meh = await this.Meh.deploy();
    await this.meh.deployed();

    this.mehRoyalty = await this.MehRoyalty.deploy(
      this.meh.address
    );
    await this.mehRoyalty.deployed();

    this.mehVote = await this.MehVote.deploy(
        this.meh.address,
        this.mehRoyalty.address
    );
    await this.mehVote.deployed();

  });

  describe("administration", function () {

    beforeEach(async function () {
      const [owner] = await ethers.getSigners();
      await this.meh.mint(owner.address, "1000000000000000000000000000");

      let currentTimestamp = Math.floor(Date.now() / 1000);
      let oneYearLaterTimestamp = currentTimestamp + 31536000;
      await this.mehVote.createGame(currentTimestamp, oneYearLaterTimestamp);
      let game = await this.mehVote.games(1);
      expect(game.id.toNumber()).to.equal(1);


      await this.mehVote.addProductToGame(
          1,
          "MEH HAT 01",
          100,
          "50000000000000000000000",
          1714603104,
          1715303900,
          1000,
          true
      );

      let products = await this.mehVote.getProductsByGameId(1);
      expect(products.length).to.equal(1);
      expect(products[0].id.toNumber()).to.equal(1);

    });

    it("deposits prize meh", async function () {
      await this.meh.approve(this.mehVote.address, "100000000000000000000000");

      await this.mehVote.depositPrizeMeh(
          1,
          1,
          "100000000000000000000000",
      );

      let products = await this.mehVote.getProductsByGameId(1);
      expect(products[0].id.toNumber()).to.equal(1);
      expect(Number(products[0].prizeMeh.toString())).to.equal(100000000000000000000000);

    });

  });

  describe("deposit", function () {

    beforeEach(async function () {
      const [owner] = await ethers.getSigners();
      await this.meh.mint(owner.address, "1000000000000000000000000000");

      let currentTimestamp = Math.floor(Date.now() / 1000);
      let oneYearLaterTimestamp = currentTimestamp + 31536000;
      await this.mehVote.createGame(currentTimestamp, oneYearLaterTimestamp);
      let game = await this.mehVote.games(1);
      expect(game.id.toNumber()).to.equal(1);


      await this.mehVote.addProductToGame(
          1,
          "MEH HAT 01",
          100,
          "50000000000000000000000",
          1714603104,
          1715303900,
          1000,
          true
      );

      let products = await this.mehVote.getProductsByGameId(1);
      expect(products.length).to.equal(1);
      expect(products[0].id.toNumber()).to.equal(1);

    });

    it("deposits meh", async function () {
      await this.meh.approve(this.mehVote.address, "50000000000000000000000");

      await this.mehVote.depositMeh(
          1,
          1,
          1,
      );

      let products = await this.mehVote.getProductsByGameId(1);
      expect(products[0].mehContractsDeposited.toNumber()).to.equal(1);
      //expect(Number(products[0].prizeMeh.toString())).to.equal(100000000000000000000000);

    });

  });

});


