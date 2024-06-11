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
    this.MehAdV1 = await ethers.getContractFactory("MehAdV1");
  });

  beforeEach(async function () {
    const [owner] = await ethers.getSigners();
    this.meh = await this.Meh.deploy();
    await this.meh.deployed();

    this.mehAd = await this.MehAdV1.deploy(
      "MehAdV1",
      "SIG",
      this.meh.address
    );
    await this.mehAd.deployed();

  });

  describe.only("sign ad", function () {

    beforeEach(async function () {
      const [owner] = await ethers.getSigners();
      await this.meh.mint(this.mehAd.address, "100000000000000000000000000");

      let currentTimestamp = await time.latest();
      let oneDayLaterTimestamp = currentTimestamp + 86400;

      const emptyRoot = ethers.constants.HashZero;

      await this.mehAd.setAd(
          "https://meh.network",
          "https://meh.network",
          emptyRoot,
          emptyRoot
      );

    });

    it("signs ad", async function () {
      const emptyProof = ["0x0000000000000000000000000000000000000000000000000000000000000000"];

      await this.mehAd.signAd(
          1,
          emptyProof
      );

      let [var1, var2] = await this.mehAd.adAmt();
      console.log(var1, var2);
      //9999989366530218668469

    });


  });

});


