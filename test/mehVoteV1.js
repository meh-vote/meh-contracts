var chai = require("chai");
const expect = chai.expect;
const { BN, expectEvent, expectRevert } = require("@openzeppelin/test-helpers");
const { solidity } = require("ethereum-waffle");
const { MerkleTree } = require("merkletreejs");
const keccak256 = require("keccak256");
const { time } = require("@nomicfoundation/hardhat-network-helpers");

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
          true,
          "100000000000000000000000"
      );

      let products = await this.mehVote.getProductsByGameId(1);
      expect(products.length).to.equal(1);
      expect(products[0].id.toNumber()).to.equal(1);
      expect(Number(products[0].prizeMeh.toString())).to.equal(100000000000000000000000);

    })


    it("extracts meh for store", async function () {
      const [owner] = await ethers.getSigners();

      await this.meh.approve(this.mehVote.address, "5000000000000000000000000");
      await this.mehVote.depositMeh(
          1,
          1,
          100,
      );

      let mehBalance = await this.meh.balanceOf(owner.address);
      expect(Number(mehBalance.toString())).to.equal(995000000000000000000000000);
      await this.mehVote.depositMehStore(
          "10000000000000000000", // 10 meh
      );

      mehBalance = await this.meh.balanceOf(owner.address);
      expect(Number(mehBalance.toString())).to.equal(995000010000000000000000000);

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
          true,
          "100000000000000000000000"
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
    });

    it("sellout", async function () {
      await this.meh.approve(this.mehVote.address, "5000000000000000000000000");

      await this.mehVote.depositMeh(
          1,
          1,
          100,
      );

      let products = await this.mehVote.getProductsByGameId(1);
      expect(products[0].mehContractsDeposited.toNumber()).to.equal(100);
      expect(products[0].mehStore).to.equal(true);

    });

    it("reverts deposit after sellout", async function () {
      await this.meh.approve(this.mehVote.address, "10000000000000000000000000");

      await this.mehVote.depositMeh(
          1,
          1,
          100,
      );

      let products = await this.mehVote.getProductsByGameId(1);
      expect(products[0].mehContractsDeposited.toNumber()).to.equal(100);
      expect(products[0].mehStore).to.equal(true);

      await expectRevert(
          this.mehVote.depositMeh(
              1,
              1,
              1,
          ),
          "product already listed on meh.store"
      );

    });

  });

  describe("claim", function () {

    beforeEach(async function () {
      const [owner] = await ethers.getSigners();
      await this.meh.mint(owner.address, "1000000000000000000000000000");

      let currentTimestamp = await time.latest();
      let oneDayLaterTimestamp = currentTimestamp + 86400;
      await this.mehVote.createGame(currentTimestamp, oneDayLaterTimestamp);
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
          true,
          "100000000000000000000000"
      );

      let products = await this.mehVote.getProductsByGameId(1);
      expect(products.length).to.equal(1);
      expect(products[0].id.toNumber()).to.equal(1);

      await this.mehVote.addProductToGame(
          1,
          "MEH HAT 02",
          100,
          "50000000000000000000000",
          1714603104,
          1715303900,
          1000,
          true,
          "100000000000000000000000"
      );

      await this.meh.approve(this.mehVote.address, "5000000000000000000000000");

      await this.mehVote.depositMeh(
          1,
          1,
          100,
      );

      products = await this.mehVote.getProductsByGameId(1);
      expect(products[0].mehContractsDeposited.toNumber()).to.equal(100);
      expect(products[0].mehStore).to.equal(true);

      // enable minting of royalty nft
      await this.mehRoyalty.updateMinter(this.mehVote.address);
      await this.mehRoyalty.createProduct(
          1,
          100,
      );
    });

    it("revert claim before meh.store", async function () {
      await expectRevert.unspecified(
          this.mehVote.claim(
              1,
              2,
          )
      );

    });

    it("claims erc/720", async function () {
      const [owner] = await ethers.getSigners();
      await time.increase(172800); // 2 days

      let mehBalance = await this.meh.balanceOf(owner.address);
      await this.mehVote.claim(
          1,
          1,
      );

      mehBalance = await this.meh.balanceOf(owner.address);

      // ownerOfRoyalty100001 = await this.mehRoyalty.ownerOf(100001);
      // console.log("blah owner");
      // console.log(ownerOfRoyalty100001);

    });

    it("revert claim invalid product", async function () {
      await expectRevert.unspecified(
          this.mehVote.claim(
              1,
              20,
          )
      );

    });



  });

});


