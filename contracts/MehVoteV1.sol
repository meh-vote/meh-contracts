// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IERC20Burnable is IERC20 {
    function burn(uint256 amount) external;
}

contract MehVoteV1 is Ownable, ReentrancyGuard {
    IERC20Burnable public immutable mehToken;

    using Counters for Counters.Counter;
    Counters.Counter private gameIdCounter;
    Counters.Counter private productIdCounter;

    struct Game {
        uint256 id;
        uint256 begin;
        uint256 end;
        mapping(uint256 => Product) products; // Nested mapping to hold products directly
        uint256 numProducts; // To keep track of the number of products
    }

    struct Product {
        uint256 id;
        uint256 mehDeposited;
        uint256 mehNeeded;
        uint256 prizeMeh;
        bool isWinner;
    }

    mapping(uint256 => Game) public games;
    mapping(address => mapping(uint256 => uint256)) public userDeposits;

    constructor(IERC20Burnable _mehToken) {
        mehToken = _mehToken;
    }

    // Owner function to create a game
    function createGame(uint256 begin, uint256 end) external onlyOwner {
        uint256 gameId = gameIdCounter.current();
        Game storage game = games[gameId];
        game.id = gameId;
        game.begin = begin;
        game.end = end;
        gameIdCounter.increment();
    }

    // Owner function to add a product to a game
    function addProductToGame(
        uint256 gameId,
        uint256 prizeMeh,
        uint256 mehNeeded
    ) external onlyOwner {
        Game storage game = games[gameId];
        require(game.id != 0, "Game does not exist");

        uint256 productId = productIdCounter.current();
        game.products[productId] = Product({
            id: productId,
            mehDeposited: 0,
            prizeMeh: prizeMeh,
            mehNeeded: mehNeeded,
            isWinner: false
        });

        // Increment counters for product ID and number of products in the game
        productIdCounter.increment();
        game.numProducts++;
    }

    function depositMeh(uint256 gameId, uint256 productId, uint256 amt) external {
        // Access the specific game and product from the nested mapping
        Game storage game = games[gameId];
        Product storage product = game.products[productId];

        // Check for a valid product in the game
        require(product.id != 0, "product does not exist");
        require(!product.isWinner, "product not funded");

        if(product.mehDeposited + amt > product.mehNeeded) {
            amt = product.mehNeeded - product.mehDeposited;
        }

        mehToken.transferFrom(msg.sender, address(this), amt);
        product.mehDeposited += amt;
        if (product.mehDeposited == product.mehNeeded) {
            product.isWinner = true;
        }

        userDeposits[msg.sender][productId] += amt;
    }

    // Function for owner to extract Meh from the contract
    function extractMeh(uint256 amount) external onlyOwner {
        mehToken.transfer(owner(), amount);
    }

    function depositPrizeMeh(uint256 gameId, uint256 productId, uint256 amount) external onlyOwner {
        Game storage game = games[gameId];
        Product storage product = game.products[productId];

        require(product.id != 0, "product does not exist");
        product.prizeMeh += amount;

        mehToken.transferFrom(msg.sender, address(this), amount);
    }

    // OnlyOwner function to update product win status
    function updateProductWinStatus(uint256 gameId, uint256 productId, bool isWinner) external onlyOwner {
        Game storage game = games[gameId];
        Product storage product = game.products[productId];

        if (isWinner) {
            product.isWinner = true;
        } else {
            product.isWinner = false;
            // Directly burn the Meh instead of transferring to address(0)
            uint256 totalMeh = product.mehDeposited + product.prizeMeh;
            if (totalMeh > 0) {
                mehToken.burn(totalMeh);
            }
            product.mehDeposited = 0;
            product.prizeMeh = 0;
        }
    }

    // External claim function
    function claim(uint256 gameId, uint256 productId, bool lock) external {
        Game storage game = games[gameId];
        require(game.end < block.timestamp, "Game not ended yet");
        require(game.products[productId].isWinner, "Product did not win");

        uint256 userDeposit = userDeposits[msg.sender][productId];
        Product storage product = game.products[productId];
        uint256 totalMehInProduct = product.mehDeposited;
        uint256 prizeMeh = product.prizeMeh;

        if (lock) {
            // Lock the funds by zeroing out the user's deposit for this product
            userDeposits[msg.sender][productId] = 0;
        } else {
            // Calculate the payout for the user based on their share of the total deposits
            uint256 payout = userDeposit + (userDeposit * prizeMeh / totalMehInProduct);

            // Transfer the calculated payout to the user and clear their deposit record
            mehToken.transfer(msg.sender, payout);
            userDeposits[msg.sender][productId] = 0;
        }
    }
}