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
                3,
            );


        });

        it("mint", async function () {
            const [owner] = await ethers.getSigners();

            await this.mehRoyalty.mint(
                1,
                owner.address,
            );

            tokenId = 10001
            ownerOfRoyalty10001 = await this.mehRoyalty.ownerOf(tokenId);
            expect(ownerOfRoyalty10001).to.equal(owner.address);

        });

        it("reverts after mintout", async function () {
            const [owner] = await ethers.getSigners();

            for(i=1; i <= 3; i++) {
                tokenId = 10000 + i;
                await this.mehRoyalty.mint(
                    1,
                    owner.address,
                );

                ownerOfRoyalty = await this.mehRoyalty.ownerOf(tokenId);
                expect(ownerOfRoyalty).to.equal(owner.address);
            }

            await expectRevert(
                this.mehRoyalty.mint(
                    1,
                    owner.address,
                ),
                'all tokens minted for this product'
            );
        });

        it("reverts mint from non minter", async function () {
            const [owner, addr1] = await ethers.getSigners();

            await expectRevert(
                this.mehRoyalty.connect(addr1).mint(
                    1,
                    owner.address,
                ),
                'mint can only be called by minter'
            );
        });

    });

    describe("deposit & extract", function () {

        beforeEach(async function () {
            const [owner] = await ethers.getSigners();
            await this.meh.mint(owner.address, "1000000000000000000000000000");

            await this.mehRoyalty.updateMinter(owner.address);
            await this.mehRoyalty.createProduct(
                1,
                10,
            );

            await this.mehRoyalty.mint(
                1,
                owner.address,
            );
        });

        it("deposit", async function () {
            const [owner, addr1] = await ethers.getSigners();

            let tokenId = 10001;
            let depositAmt = await this.mehRoyalty.deposits(tokenId);
            expect(Number(depositAmt.toString())).to.equal(0);

            await this.meh.approve(this.mehRoyalty.address, "100000000000000000000");

            await this.mehRoyalty.depositMehToken(
                tokenId,
                "100000000000000000000",
            );

            depositAmt = await this.mehRoyalty.deposits(tokenId);
            expect(Number(depositAmt.toString())).to.equal(100000000000000000000);

        });

        it("extract", async function () {
            const [owner, addr1] = await ethers.getSigners();

            let tokenId = 10001;
            await this.meh.approve(this.mehRoyalty.address, "100000000000000000000");

            await this.mehRoyalty.depositMehToken(
                tokenId,
                "100000000000000000000",
            );

            let depositAmt = await this.mehRoyalty.deposits(tokenId);
            expect(Number(depositAmt.toString())).to.equal(100000000000000000000);

            // fast forward 1 year
            await time.increase(31536000); // 1 year
            await this.mehRoyalty.extractMehToken(
                tokenId,
                "100000000000000000000",
            );

            depositAmt = await this.mehRoyalty.deposits(tokenId);
            expect(Number(depositAmt.toString())).to.equal(0);

        });


        it("extract revert", async function () {
            const [owner, addr1] = await ethers.getSigners();

            let tokenId = 10001;
            await this.meh.approve(this.mehRoyalty.address, "100000000000000000000");

            await this.mehRoyalty.depositMehToken(
                tokenId,
                "100000000000000000000",
            );

            let depositAmt = await this.mehRoyalty.deposits(tokenId);
            expect(Number(depositAmt.toString())).to.equal(100000000000000000000);

            // fast forward 1 year
            await time.increase(31536000); // 1 year
            await expectRevert(
                this.mehRoyalty.connect(addr1).extractMehToken(
                    tokenId,
                    "100000000000000000000",
                ),
                "caller is not the owner of the token",
            );

            await expectRevert(
                this.mehRoyalty.extractMehToken(
                    tokenId,
                    "200000000000000000000",
                ),
                "insufficient meh",
            );

            depositAmt = await this.mehRoyalty.deposits(tokenId);
            expect(Number(depositAmt.toString())).to.equal(100000000000000000000);

        });

    });

});
