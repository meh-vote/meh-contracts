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
        mapping(uint256 => Product) products;
        uint256 numProducts;
    }

    struct Product {
        uint256 id;
        uint256 mehDeposited;
        uint256 mehNeeded;
        uint256 prizeMeh;
        uint256 limitedRun;
        bool mehStore;
    }

    mapping(uint256 => Game) public games;
    mapping(address => mapping(uint256 => uint256)) public deposits;

    constructor(IERC20Burnable _mehToken) {
        mehToken = _mehToken;
    }

    function createGame(
        uint256 _begin,
        uint256 _end
    ) external onlyOwner {
        uint256 gameId = gameIdCounter.current();
        Game storage game = games[gameId];
        game.id = gameId;
        game.begin = _begin;
        game.end = _end;
        gameIdCounter.increment();
    }

    // Owner function to add a product to a game
    function addProductToGame(
        uint256 _gameId,
        uint256 _prizeMeh,
        uint256 _mehNeeded,
        uint256 _limitedRun
    ) external onlyOwner {
        Game storage game = games[_gameId];
        require(game.id != 0, "game does not exist");

        uint256 productId = productIdCounter.current();
        game.products[productId] = Product({
            id: productId,
            mehDeposited: 0,
            prizeMeh: _prizeMeh,
            mehNeeded: _mehNeeded,
            mehStore: false,
            limitedRun: _limitedRun
        });

        productIdCounter.increment();
        game.numProducts++;
    }

    function depositMeh(
        uint256 _gameId,
        uint256 _productId,
        uint256 _amt
    ) external {
        Game storage game = games[_gameId];
        Product storage product = game.products[_productId];

        require(product.id != 0, "product does not exist");
        require(!product.mehStore, "product already in meh.store");

        uint256 amt = _amt;
        if(product.mehDeposited + amt > product.mehNeeded) {
            amt = product.mehNeeded - product.mehDeposited;
        }

        mehToken.transferFrom(msg.sender, address(this), amt);
        product.mehDeposited += amt;
        if (product.mehDeposited == product.mehNeeded) {
            product.mehStore = true;
        }

        deposits[msg.sender][_productId] += amt;
    }

    function depositMehStore(uint256 _amount) external onlyOwner {
        mehToken.transfer(owner(), _amount);
    }

    function depositPrizeMeh(
        uint256 _gameId,
        uint256 _productId,
        uint256 _amount
    ) external onlyOwner {
        Game storage game = games[_gameId];
        Product storage product = game.products[_productId];

        require(product.id != 0, "product does not exist");
        product.prizeMeh += _amount;

        mehToken.transferFrom(msg.sender, address(this), _amount);
    }

    function burnLoserMeh(
        uint256 _gameId,
        uint256 _productId
    ) external onlyOwner {
        Game storage game = games[_gameId];
        Product storage product = game.products[_productId];
        require(!product.mehStore, "product in store");

        uint256 totalMeh = product.mehDeposited + product.prizeMeh;
        if (totalMeh > 0) {
            mehToken.burn(totalMeh);
        }
    }

    function claim(
        uint256 _gameId,
        uint256 _productId
    ) external {
        Game storage game = games[_gameId];
        require(game.end < block.timestamp, "game not ended");
        require(game.products[_productId].mehStore, "product not in store");

        uint256 deposit = deposits[msg.sender][_productId];
        Product storage product = game.products[_productId];

        // TODO claim ERC/721 token for limited run
        // TODO claim ERC/721 token for contract

        uint256 payout = (deposit * product.prizeMeh / product.mehDeposited);
        deposits[msg.sender][_productId] = 0;
        mehToken.transfer(msg.sender, payout);
    }
}