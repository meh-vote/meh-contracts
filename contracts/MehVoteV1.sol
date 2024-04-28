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
        mapping(uint256 => Product) products; // products in game
        uint256 numProducts;
    }

    struct Product {
        uint256 id;
        uint256 mehDeposited; // meh currently deposited
        uint256 mehNeeded; // meh needed to list on meh.store
        uint256 prizeMeh; // prize in meh
        uint256 genesisLimit; // genesis product transfered to top depositors into product
        bool mehStore; // event sent to list on meh.store
        uint256 begin;
        uint256 end;
        uint256 mehCost; // meh needed to make product
        uint256 royaltyBase; // [1-100] base percentage available to royalty contract holders
    }

    event MehStore (
        uint256 productId,
        uint256 genesisRun,
        string genesisMerkleRoot,
        string allocatorMerkleRoot,
        uint256 mehCost,
        uint256 royaltyBase
    );

    mapping(uint256 => Game) public games;
    mapping(address => mapping(uint256 => uint256)) public deposits;

    constructor(IERC20Burnable _mehToken) {
        mehToken = _mehToken;
        gameIdCounter.increment();
        productIdCounter.increment();
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

    function addProductToGame(
        uint256 _gameId,
        uint256 _mehNeeded,
        uint256 _genesisLimit,
        uint256 _begin,
        uint256 _end,
        uint256 _mehCost,
        uint256 _royaltyBase
    ) external onlyOwner {
        Game storage game = games[_gameId];
        require(game.id != 0, "game does not exist");

        uint256 productId = productIdCounter.current();
        game.products[productId] = Product({
            id: productId,
            mehDeposited: 0,
            prizeMeh: 0,
            mehNeeded: _mehNeeded,
            mehStore: false,
            genesisLimit: _genesisLimit,
            begin: _begin,
            end: _end,
            mehCost: _mehCost,
            royaltyBase: _royaltyBase
        });

        productIdCounter.increment();
        game.numProducts++;
    }

    function depositMeh(
        uint256 _gameId,
        uint256 _productId,
        uint256 _amt
    ) external nonReentrant {
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
            string memory merkleRoot = "def-001";

            emit MehStore(
                _productId,
                product.genesisLimit,
                merkleRoot,
                merkleRoot,
                product.mehCost,
                product.royaltyBase
            );

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
    ) external nonReentrant {
        Game storage game = games[_gameId];
        require(game.end < block.timestamp, "game not ended");
        require(game.products[_productId].mehStore, "product not in store");

        uint256 deposit = deposits[msg.sender][_productId];
        Product storage product = game.products[_productId];

        // TODO determine ratio and mint royalty contract

        // TODO claim ERC/721 token for limited run
        // TODO claim ERC/721 token for contract

        uint256 payout = (deposit * product.prizeMeh / product.mehDeposited);
        deposits[msg.sender][_productId] = 0;
        mehToken.transfer(msg.sender, payout);
    }
}