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

describe("meh royalty", function () {

    before(async function () {
        this.Meh = await ethers.getContractFactory("Meh");
        this.MehRoyalty = await ethers.getContractFactory("MehRoyaltyV1");
    });

    beforeEach(async function () {
        const [owner] = await ethers.getSigners();
        this.meh = await this.Meh.deploy();
        await this.meh.deployed();

        this.mehRoyalty = await this.MehRoyalty.deploy(
            this.meh.address
        );
        await this.mehRoyalty.deployed();


    });

    describe("administration", function () {

        beforeEach(async function () {
            const [owner] = await ethers.getSigners();
            await this.meh.mint(owner.address, "1000000000000000000000000000");


        });

        it("extracts meh for store", async function () {

        });

    });

    describe("mint", function () {

        beforeEach(async function () {
            const [owner] = await ethers.getSigners();
            await this.meh.mint(owner.address, "1000000000000000000000000000");

            await this.mehRoyalty.updateMinter(owner.address);
            await this.mehRoyalty.createProduct(
                1,
                100,
            );


        });

        it("mint", async function () {

        });


    });



});
