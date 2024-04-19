var chai = require("chai");
const expect = chai.expect;
const { BN, expectEvent, expectRevert } = require("@openzeppelin/test-helpers");
const { solidity } = require("ethereum-waffle");
const { MerkleTree } = require("merkletreejs");
const keccak256 = require("keccak256");

chai.use(solidity);

describe("meh game", function () {

  before(async function () {
    this.MehGame = await ethers.getContractFactory("MehGame");
  });

  beforeEach(async function () {
    const [owner] = await ethers.getSigners();
    this.meh = await this.MehGame.deploy();
    await this.meh.deployed();


  });

  describe("game", function () {

    it("should call meh", async function () {
    });

    });

});


